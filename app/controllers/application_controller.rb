class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_locale

  private

  def set_locale
    locale = cookies[:locale]&.to_sym
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)
    I18n.locale = locale
  end
end
