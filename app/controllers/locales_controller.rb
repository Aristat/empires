class LocalesController < ApplicationController
  def update
    locale = params[:locale].to_sym
    if I18n.available_locales.include?(locale)
      cookies.permanent[:locale] = locale
    end
    redirect_back(fallback_location: root_path)
  end
end
