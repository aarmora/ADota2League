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

  def format_price(price_cents)
    price_cents == 0 ? "Free!" : "$" + "%.2f" % (price_cents / 100.0)
  end
end
