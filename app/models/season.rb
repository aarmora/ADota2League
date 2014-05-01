class Season < ActiveRecord::Base
	has_many :team_seasons, :dependent => :delete_all
	has_many :teams, :through => :team_seasons
	has_many :matches

  attr_accessible :title, :league_id, :registration_open, :active, :late_fee_start, :price_cents, :late_price_cents, :exclusive_group, :start_date, :as => :admin

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
end
