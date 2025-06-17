module Api
  class ApiController < ActionController::Base
    skip_before_action :verify_authenticity_token
    rescue_from StandardError, with: :render_internal_server_error_response # Catch-all for other errors
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing_response
    rescue_from ActionController::UnknownFormat, with: :render_unacceptable_format_response
    rescue_from ActiveRecord::StatementInvalid, with: :render_constraint_error_response
    before_action :check_json_content_type

    private

    def render_not_found_response
      render json: { error: "Resource not found" }, status: :not_found
    end

    def render_parameter_missing_response(exception)
      render json: { error: exception.message }, status: :bad_request
    end

    # Generic error handler for any other unhandled exceptions.
    # added to avoid html responses when testing in dev
    def render_internal_server_error_response(exception)
      error_response = { error: "Internal Server Error" }

      unless Rails.env.production?
        error_response[:details] = exception.message # Can be sensitive in prod environs
      end

      render json: error_response, status: :internal_server_error
    end

    def render_unacceptable_format_response
      render json: { error: "Not Acceptable", details: "The requested format is not supported. Please request 'application/json'." }, status: :not_acceptable
    end

    def render_constraint_error_response(exception)
      render json: { error: "Constraint Violation", details: exception.message }, status: :unprocessable_entity
    end

    def check_json_content_type
      unless request.content_type == 'application/json'
        render json: {
          error: "Unsupported Media Type",
          details: "Please ensure Content-Type header is 'application/json' for endpoints under /api"
        }, status: :unsupported_media_type
        return false # false prevents continued processing
      end
    end
  end
end