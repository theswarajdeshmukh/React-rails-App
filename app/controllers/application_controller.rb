# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user_using_x_auth_token
  protect_from_forgery

  include Pundit::Authorization

  rescue_from StandardError, with: :handle_api_exception
  rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error

  def handle_api_exception(exception)
    case exception
    when -> (e) { e.message.include?("PG::") || e.message.include?("SQLite3::") }
      handle_database_level_exception(exception)

    when Pundit::NotAuthorizedError
      handle_authorization_error

    when ActionController::ParameterMissing
      respond_with_error(exception, :internal_server_error)

    when ActiveRecord::RecordNotFound
      respond_with_error("Couldn't find #{exception.model}")

    when ActiveRecord::RecordNotUnique
      respond_with_error(exception.message)

    when ActiveModel::ValidationError, ActiveRecord::RecordInvalid, ArgumentError
      error_message = exception.message.gsub("Validation failed: ", "")
      respond_with_error(error_message, :unprocessable_entity)

    else
      handle_generic_exception(exception)
    end
  end

  def handle_database_level_exception(exception)
    handle_generic_exception(exception, :unprocessable_entity)
  end

  def handle_authorization_error
    respond_with_error("Access denied. You are not authorized to perform this action.", :forbidden)
  end

  def handle_generic_exception(exception, status = :internal_server_error)
    log_exception(exception) unless Rails.env.test?
    error = Rails.env.production? ? t("generic_error") : exception
    respond_with_error(error, status)
  end

  def log_exception(exception)
    Rails.logger.info exception.class.to_s
    Rails.logger.info exception.to_s
    Rails.logger.info exception.backtrace.join("\n")
  end

  def respond_with_error(error, status = :unprocessable_entity, context = {})
    error_message = error
    is_exception = error.kind_of?(StandardError)
    if is_exception
      is_having_record = error.methods.include? "record"
      error_message = is_having_record ? message.record&.errors.full_messages.to_sentence : error.message
    end
    render status: status, json: { error: error_message }.merge(context)
  end

  def respond_with_success(message, status = :ok, context = {})
    render status: status, json: { notice: message }.merge(context)
  end

  def respond_with_json(json = {}, status = :ok)
    render status: status, json: json
  end

  private

    def authenticate_user_using_x_auth_token
      user_email = request.headers["X-Auth-Email"].presence
      # Calling the presence method on request.headers["X-Auth-Email"] will return the value of X-Auth-Email
      # if it is not nil otherwise it will return nil
      auth_token = request.headers["X-Auth-Token"].presence
      user = user_email && User.find_by!(email: user_email)
      is_valid_token = user && auth_token && ActiveSupport::SecurityUtils.secure_compare(
        user.authentication_token,
        auth_token)
      if is_valid_token
        @current_user = user
      else
        respond_with_error(t("session.could_not_auth"), :unauthorized)
      end
    end

    def handle_authorization_error
      respond_with_error(t("authorization.denied"), :forbidden)
    end

    def current_user
      @current_user
    end
end
