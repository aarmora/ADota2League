module ApplicationHelper
  def cache_unless_admin *args
    m = args.shift
    if m && m.is_admin?
      yield
    else
      cache args do
        yield
      end
    end
  end

  def format_date(t)
    tz = @current_user.time_zone if @current_user
    tz ||= "Eastern Time (US & Canada)"
    t ? t.in_time_zone(tz).strftime("%-m/%-d/%y") : ""
  end

  def format_datetime(t)
    tz = @current_user.time_zone if @current_user
    tz ||= "Eastern Time (US & Canada)"
    t ? t.in_time_zone(tz).strftime("%-m/%-d/%y %l:%M%p %Z") : ""
  end

  def format_price(price_cents)
    price_cents == 0 ? "Free!" : "$" + "%.2f" % (price_cents / 100.0)
  end
end
