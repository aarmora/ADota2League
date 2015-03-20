Forem::ApplicationController.class_eval do
  def forem?
    true
  end

  helper_method :forem?
end