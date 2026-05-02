class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_locale

  private

  def with_user_game_lock(user_game = @user_game)
    RedisLockService.new(key: "lock:user_game:#{user_game.id}", timeout: 10).call_without_lock do
      yield UserGame.find(user_game.id)
    end
  end

  def set_locale
    locale = cookies[:locale]&.to_sym
    locale = I18n.default_locale unless I18n.available_locales.include?(locale)
    I18n.locale = locale
  end
end
