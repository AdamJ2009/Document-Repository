class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  def require_admin!
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  private

  def current_user
    Current.user
  end
end
