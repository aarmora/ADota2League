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
    t ? t.strftime("%-m/%-d/%y") : ""
  end

  def format_datetime(t)
    t ? t.strftime("%-m/%-d/%y %l:%M%p") : ""
  end

  def format_price(price_cents)
    price_cents == 0 ? "Free!" : "$" + "%.2f" % (price_cents / 100.0)
  end
end
