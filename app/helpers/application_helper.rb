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
end
