class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_filter :flash_to_headers
  prepend_before_action :set_locale

  private
    def set_locale
      params[:locale] ||= :de
    end

    def check_transfair
      unless current_user.is_intern?
        redirect_to root_path
      end
    end

    def flash_to_headers
      return if !request.xhr? || request.env["REQUEST_PATH"] == "/jobs_ajax/show_regular_jobs" ||
        request.env["REQUEST_PATH"] == "/jobs_ajax/show_all" ||  request.env["REQUEST_PATH"] == "/datatable_i18n"
      response.headers['X-Message'] = flash_message
      response.headers["X-Message-Type"] = flash_type.to_s
      logger.info "===================================="
      logger.info request.env["REQUEST_PATH"]
      logger.info flash.inspect
      logger.info response.headers['X-Message']
      logger.info "===================================="
      flash.discard # don't want the flash to appear when you reload page
    end

    def flash_message
      [:error, :warning, :notice].each do |type|
        return flash[type] unless flash[type].blank?
      end
      return ""
    end

    def flash_type
      [:error, :warning, :notice].each do |type|
        return type unless flash[type].blank?
      end
      return ""
    end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :first_name, :last_name, :company_id, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :first_name, :last_name, :company_id, :password, :password_confirmation, :current_password) }
    devise_parameter_sanitizer.for(:accept_invitation).concat [ :first_name, :last_name, :email, :username ]
  end
end
