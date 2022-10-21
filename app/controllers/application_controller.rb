# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :validate_jwt

  rescue_from StandardError do |exception|
    Rails.logger.error exception.backtrace.inspect if Rails.env.development?

    render json: { error: exception.message }, status: :internal_server_error
  end

  rescue_from Aserto::AccessDenied do |exception|
    render json: { error: exception.message }, status: :forbidden
  end

  private

  def validate_jwt
    Auth::VerifyJwt.call(request.headers["Authorization"].split.last)
  end
end
