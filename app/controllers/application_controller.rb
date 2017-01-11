class ApplicationController < ActionController::Base
  # include Knock::Authenticable

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  def standard_error_message(error)
    logger.error error.message
    render json: error.to_json, status: 500
  end
end