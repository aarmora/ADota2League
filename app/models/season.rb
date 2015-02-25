class Season < ActiveRecord::Base
	has_many :team_seasons, :dependent => :destroy
	has_many :participants, :through => :team_seasons
	has_many :matches, :dependent => :destroy
  has_many :permissions, :class_name => "Permission", :foreign_key => "season_id"

  enum season_type: [ :round_robin, :single_elim, :double_elim ]
  attr_accessible :title, :league_id, :registration_open, :active, :late_fee_start, :price_cents, :late_price_cents, :exclusive_group, :start_date, :challonge_url, :description, :team_tourney, :season_type, :as => :admin

  def current_price
    self.late_fee_start && self.late_fee_start < Time.now ? self.late_price_cents : self.price_cents
  end

  def late_fee_applies
    self.late_fee_start && self.late_fee_start < Time.now
  end

  def price_string
    if self.late_fee_applies
      self.late_price_cents == 0 ? "Free!" : "$" + "%.2f" % (self.late_price_cents / 100.0) + " incl. Late Fee"
    else
      self.price_cents == 0 ? "Free!" : "$" + "%.2f" % (self.price_cents / 100.0)
    end
  end

  def challonge_tournament
    begin
      @challonge_tournament ||= self.challonge_id.nil? ? nil : Challonge::Tournament.find(self.challonge_id)
    rescue
      nil
    end
  end

  def check_in_available?
    if self.start_date
      Time.now > (self.start_date - 30.minutes) && !self.round_robin?
    else
      Time.now
    end
  end

  # A tournament is started if it's not a round robin and matches are scheduled
  # We can reset the scheduling (re-seeding, dropouts, etc.) by dropping all matches
  # This is used to check if we are in a "locked" mode in that sense
  def tournament_started?
    !self.round_robin? && self.matches.count > 0
  end

  # No start date implies that we are running it ASAP or anything but weekly
  def setup_tournament_matches(start_date = nil, utc_offset = nil)
    # verify all this shit and blah blah blah
    teams = self.team_seasons.where(paid: true, checked_in: true).sort_by {|ts| ts.division.to_i }.map {|ts| {participant: ts.participant, seed_order: ts.division} }

    # Add in Byes
    bracket_size = 2 ** Math.log(teams.length,2).ceil
    bracket = BracketTree::Bracket::SingleElimination.by_size bracket_size
    seeds = Season.seed_mappings(bracket_size)
    teams = teams.fill({participant: nil}, teams.length...bracket_size)

    seeded_teams = seeds.map{|i| teams[i-1]}
    bracket.seed seeded_teams
    matches = transform_from_bracket(bracket)

    # loop and create the matches...keep a mapping of psuedo-ids to real ids so we can relink in a second pass
    mapping = {}
    matches.each do |pseudo_match|
      match_data = {
        :home_participant => pseudo_match[:team1] ? pseudo_match[:team1][:participant] : nil,
        :away_participant => pseudo_match[:team2] ? pseudo_match[:team2][:participant] : nil,
        :week => pseudo_match[:round],
      }
      if start_date
        time = DOTA_GAME_TIMES.sample
        date = start_date + (pseudo_match[:round] - 1) * 7
        tz = utc_offset
        self.logger.info(tz)
        match_data[:date] = "#{date} #{time} #{tz}"
        self.logger.info(match_data[:date])
      else
        match_data[:date] = Time.now + ((pseudo_match[:round] - 1) * 1.5).hours
      end

      m = self.matches.create!(match_data, :without_protection => true)
      mapping[pseudo_match[:id]] = m.id
    end

    # Add in the mappings now
    matches.each do |pseudo_match|
      m = self.matches.find(mapping[pseudo_match[:id]])
      m.winner_match_id = mapping[pseudo_match[:winner_to]]
      m.loser_match_id = mapping[pseudo_match[:loser_to]]
      m.save!

      # If a bye, progress immediately
      if m.week == 1 && !!m.home_participant ^ !!m.away_participant
        m2 = Match.find(m.winner_match_id)
        m2.add_participant(m.home_participant || m.away_participant)
      end
    end

    self.matches
  end

  # Take a Bracket Tree bracket and make the format more useful
  def transform_from_bracket(bracket)
    # Note this only works for the initial transformation, otherwise it won't be able to figure out the payloads right
    # Also only works for singles as doubles also have enpty nodes
    seats_with_players = bracket.seats.select { |node| node.payload }.map { |node| node.position }
    game_seats = bracket.seats.reject { |node| node.payload }.map { |node| node.position }

    # remap the matches because they suck
    ided_matches = []
    matches_useful = bracket.matches.each_with_index do |match, i|
      teams = match.seats.map {|i| bracket.at(i).payload }.compact
      ided_matches << {id: i, seats: match.seats, winner_to: match.winner_to, loser_to: match.loser_to, team1: teams.first, team2: teams.last}
    end

    useful_matches = []
    matches_useful = ided_matches.each do |match|
      useful_matches << {
        id: match[:id],
        from_matches: match[:seats].map do |n|
          from_match = ided_matches.detect{ |m| m[:winner_to] == n || m[:loser_to] == n}
          from_match ? from_match[:id] : nil
        end.compact,
        winner_to: match[:winner_to] ? ided_matches.detect{|m| m[:seats].include? match[:winner_to]}[:id] : nil,
        loser_to: match[:loser_to] ? ided_matches.detect{|m| m[:seats].include? match[:loser_to]}[:id] : nil,
        team1: match[:team1],
        team2: match[:team2]
      }
    end

    # Figure out the optimal "rounds" to set
    def setRound(useful_matches, match)
      match[:round] = 1 if match[:from_matches].empty?
      match[:round] ||= match[:from_matches].map { |i| setRound(useful_matches, useful_matches.detect{ |m| m[:id] == i})}.max + 1
    end
    useful_matches.each do |match|
      setRound(useful_matches, match)
    end
    useful_matches
  end

  # subroutine for doign a round
  def self.nextLayer (pls)
    out = []
    length = pls.length * 2 + 1;
    pls.each do |d|
      out << d
      out << length - d
    end
    out
  end

  def self.seed_mappings(size)
    rounds = Math.log(size)/Math.log(2)-1;
    # Work backwards to ensure right people would meet in the finals
    pls = [1,2];
    (0...rounds).each do
      pls = Season.nextLayer(pls);
    end

    pls
  end


end
