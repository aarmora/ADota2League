namespace :dota do
 desc "Generate Matches for a given league and week"
  task :matchups => :environment do
    puts "Making matches!"
    load 'roomie.rb'
    require 'set'



    # Helper methods to do stuff not built in to Ruby
    # this part makes it need Ruby 1.9 +

    module Enumerable

        def sum
          self.inject(0){|accum, i| accum + i }
        end

        def mean
          self.sum/self.length.to_f
        end

        def sample_variance
          m = self.mean
          sum = self.inject(0){|accum, i| accum +(i-m)**2 }
          sum/(self.length - 1).to_f
        end

        def standard_deviation
          return Math.sqrt(self.sample_variance)
        end

    end

    class Array
      def groups_of_size(n)
        Enumerator.new do |yielder|
          if self.empty?
            yielder.yield([])
          else
            self.drop(1).combination(n-1).map { |vs| [self.first] + vs }.each do |values|
              (self - values).groups_of_size(n).each do |group|
                yielder.yield([values] + group)
              end
            end
          end
        end
      end
    end

    ################ Data functions, this would hook into SQL ####################

    def teams_by_region_and_divison
      teams.group_by { |team| [team[:Region], team[:Division]] }
      #teams_fixed.group_by { |team| [team[:Region], team[:Division]] }
    end


    ################ Biznass logic AKA dat algorithm ####################
    # def sort_and_match(usable_teams)

    #   all_possible_scenarios = usable_teams.groups_of_size(2).to_a


    #   puts "Total scenarios to process: " + all_possible_scenarios.length.to_s
    #   puts "Removing instances where teams have played before:"
    #   all_possible_scenarios.delete_if do |matchups|
    #     matchups = matchups.to_a
    #     matchup_count = matchups.length
    #     valid_matchups = matchups.map { |a,b| [a[:TeamKey], b[:TeamKey]] } - previous_matchups - previous_matchups.map(&:reverse)

    #     # If any single one of the games has been played before, we remove this scenario
    #     # In the future, we could use this to rank too and just prefer less rematches
    #     valid_matchups.length != matchup_count
    #   end
    #   puts "Scenarios Remaining: " + all_possible_scenarios.length.to_s

    #   puts "Evaluating scenarios based on MMR differential"
    #   matchups = all_possible_scenarios.map do |matchups|
    #     spreads = matchups.map { |a,b| (a[:mmr] - b[:mmr]).abs }
    #     {:spread_sum => spreads.sum, :spread_variance => spreads.sample_variance, :matchups => matchups}
    #   end


    #   # NOTE: This should include variance somehow, but I'm not totally sure what is best
    #   # Example: higher variance means that fewer games will be totally unbalanced, but those that are will be more unbalanced
    #   # So what's better? (Use negative for higher variance, positive for lower)
    #   matchups = matchups.sort_by { |matchup| [matchup[:spread_sum],  matchup[:spread_variance]] }
    #   puts "Top ten scenario scores:"
    #   # NOTE: If these look really close with real data, we may want to re-examine how we are doing this
    #   matchups.first(10).each do |matchup|
    #     puts "Sum: #{matchup[:spread_sum]}, Variance: #{matchup[:spread_variance]}"
    #   end

    #   puts "Choosing Top Result"
    #   matchups = matchups.first[:matchups].to_a

    #   puts "Randomizing home and away teams"
    #   matchups.map { |matchup| matchup.shuffle }
    # end

    def sort_and_match_roommates(usable_teams)
      preferences = usable_teams.each_with_index.map do |team, my_i|
        diffs = usable_teams.each_with_index.map do |other_team, i|
          has_played = previous_matchups.include?([team[:TeamKey], other_team[:TeamKey]].to_set)
          # puts "Already seen matchup: #{team} ----- #{other_team}" if has_played
          {:diff => (team[:MMR] - other_team[:MMR]).abs, :i => i, :has_played => has_played}
        end
        # remove self
        diffs.delete_if {|item| item[:i] == my_i}
        # add in matches played already

        diffs.sort_by{|item| item[:diff] + (item[:has_played] ? 750 : 0)}.map{|item| item[:i]}
      end

      roomies = Shadchan::Roomie.new *preferences
      matches = roomies.match.each_with_index.map {|i,target| [i,target].to_set}.uniq
      matches.map {|set| [usable_teams[set.to_a[0]], usable_teams[set.to_a[1]]]}
    end





    ################ Run!!! ####################

    puts "What Season ID are we generating matches for? "
    @season = Season.find(STDIN.gets.chomp.to_i)

    puts "What week are we generating matches for? "
    week_number = STDIN.gets.chomp.to_i
    if week_number < 1 || week_number > 15
      raise "This appears to be an invalid week"
    end

    raise "Right now we cannot setup weeks for which there are already games. Ask Charlie to fix this" if @season.matches.where(:week => week_number).exists?

    # Fixed to here

    @season.teams.where(:active => true).group_by

      all_matchups = teams_by_region_and_divison.map do |keys, teams|

        puts "Setting up matchups for: #{keys.inspect}"

        # jiggle the MMR repeatedly to try and optimize the algorithm and break ties
        best_seen = [100000000, 1000000000]
        best_matchups = []
        20.times do
          this_run_teams = teams.map do |item|
            new_item = item.clone
            new_item[:MMR] = new_item[:MMR] - rand(20)
            new_item
          end

          begin
            matchups = sort_and_match_roommates(this_run_teams)
          rescue
            next
          end
          spreads = matchups.map { |a,b| (a[:MMR] - b[:MMR]).abs }
          puts "Sum: #{spreads.sum}, Variance: #{spreads.sample_variance}"
          stats = [spreads.sum / 75,spreads.sample_variance]
          if (stats <=> best_seen) == -1
            best_matchups = matchups
            best_seen = stats
          end
        end

        puts "-----------best----------"
        puts "Sum: #{best_seen[0]}, Variance: #{best_seen[1]}"



        # puts best_matchups.inspect
        puts "Matchups for #{keys.inspect}: #{best_matchups.size}"
        puts "\n\n"
        # Sorry about this...whatever
        best_matchups.map { |matchup| matchup.map { |entry| [entry[:TeamKey],entry[:name],entry[:MMR]]} }.each { |matchup| puts matchup.first[0].to_s + "," + matchup.last[0].to_s + " ------> " + matchup.first[1].to_s + " (#{matchup.first[2]})    vs.    #{matchup.last[1].to_s} (#{matchup.last[2]})"}
        puts "\n\n"
        best_matchups
      end

      puts "Did I do OK? Type 'yes charles' if you'd like to insert these. Anything else will breakout. "
      ok_to_insert = STDIN.gets.chomp == "yes charles"
      raise "Later days!" if !ok_to_insert

      puts "Last thing, need a date for these matches (i.e. 2014-03-06) in that EXACT format"
      date = STDIN.gets.chomp

      # drop regions and shuffle for purposes of assigning random times
      all_matchups = all_matchups.flatten(1).shuffle

      all_matchups.each_with_index.each do |matchup, i|
        time = i < all_matchups.length / 2 ? "20:30:00 -0800" : "22:00:00"
        datetime = "#{date} #{time}"
        query = "INSERT INTO AD2L.aarmora.MatchTable (HomeTeamKey, AwayTeamKey, Week, MatchDate) VALUES (#{matchup.first[:TeamKey]},#{matchup.last[:TeamKey]}, #{week_number}, '#{datetime}');"
        result = @client.execute(query)
        new_id = result.insert
        puts "Created match: #{new_id}"
      end
  end
end