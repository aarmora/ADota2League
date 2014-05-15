module ApplicationHelper
  def cache_unless *args
    m = args.shift
    if m
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

  def format_date_month(t)
    tz = @current_user.time_zone if @current_user
    tz ||= "Eastern Time (US & Canada)"
    t ? t.in_time_zone(tz).strftime("%-B %-d, %Y") : ""
  end

  def format_datetime(t)
    tz = @current_user.time_zone if @current_user
    tz ||= "Eastern Time (US & Canada)"
    t ? t.in_time_zone(tz).strftime("%-m/%-d/%y %l:%M%p %Z") : ""
  end

  def format_datetime_month(t)
    tz = @current_user.time_zone if @current_user
    tz ||= "Eastern Time (US & Canada)"
    t ? t.in_time_zone(tz).strftime("%-B %-d, %Y %l:%M%p %Z") : ""
  end

  def format_price(price_cents)
    price_cents == 0 ? "Free!" : "$" + "%.2f" % (price_cents / 100.0)
  end
end
