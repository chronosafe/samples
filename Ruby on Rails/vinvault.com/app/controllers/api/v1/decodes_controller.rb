module API
  module V1
    class DecodesController < ApplicationController

      # Constants
      API_VERSION  = 1
      API_BASIC    = 1
      API_ADVANCED = 2

      # Exceptions
      class AuthenticationError < StandardError; end

      class AuthorizationError < StandardError; end

      class FormatError < StandardError; end

      class ExpiredAccountError < StandardError
      end

      # Exception Handlers
      rescue_from ActionController::UnknownFormat, with: :unknown_format_response
      rescue_from AuthenticationError,             with: :authentication_response
      rescue_from AuthorizationError,              with: :authorization_response
      rescue_from FormatError,                     with: :format_render_response
      rescue_from ExpiredAccountError,             with: :expired_account_response

      before_filter :sample_check

      respond_to :json, :xml, :js

      # Actions

      def index
        current_user, type = authenticate_token(params[:auth_token], 1)
        @decodes = Decode.this_month.where(user: current_user)
      end

      def show
        current_user, type = authenticate_token(params[:auth_token], params[:type])
        @decode = Decode.find(params[:id].to_i)
        # Unauthorized if user isn't the one that created the decode
        not_allowed = @decode.nil? || (@decode.user != current_user)
        # Admins are authorized to view all records
        not_allowed = false if current_user.has_role? :admin
        raise AuthorizationError if not_allowed
        success = !@decode.nil?
        if type == API_BASIC
          respond_with_basic(success)
        else
          respond_with_advanced(success)
        end
      end

      #noinspection RubyResolve
      def create
        type = params[:type].nil? ? nil : params[:type].to_i
        current_user, type = authenticate_token(params[:auth_token], type)
        # look to see if it already exists
        @decode = Decode.where('user_id = ? and vin = ?', current_user.id, params[:vin]).first
        success = false
        success = true if !@decode.nil?
        if @decode.nil?
          @decode = Decode.new(decode_params)
          # Assign current user to decode
          @decode.user = current_user
          @decode.version = API_VERSION
          @decode.pattern = @decode.assign_pattern
          success = @decode.save
        end

        # type should be 1 or 2 by now
        raise FormatError unless type == API_BASIC || type == API_ADVANCED
        log_decode(@decode, type) if success # only log the decode if it created a successful decode
        if type == 1
          respond_with_basic(success)
        else
          respond_with_advanced(success)
        end
      end

      def bulk
        @decode = Decode.new(vin: params[:vin])
        # Assign current user to decode
        @decode.user = current_user
        @decode.version = API_VERSION
        # @decode.assign_pattern
        respond_to do |format|
          if @decode.save
            format.json { render json: Hash.from_xml(@decode.to_xml).as_json, status: :created, location: @decode }
            format.xml { render xml: @decode, status: :created }
          else
            format.json { render json: @decode.errors, status: :unprocessable_entity }
            format.xml { render xml: @decode.errors, status: :unprocessable_entity }
          end
        end
      end

      def vinhunter
        @decode = Decode.new(vin: params[:vin])
        # Assign current user to decode
        @decode.user = current_user
        @decode.version = API_VERSION
        respond_to do |format|
          if @decode.save
            format.json { render json: Hash.from_xml(@decode.to_xml).as_json, status: :created, location: @decode }
            format.xml   { render template: 'api/v1/vinhunter' }# render xml: @decode, status: :created }
            format.js { render json: @decode, :callback => params[:callback], status: :created}
          else
            format.json { render json: @decode.errors, status: :unprocessable_entity }
            format.xml { render xml: @decode.errors, status: :unprocessable_entity }
            format.js { render json: @decode, :callback => params[:callback]}
          end
        end
      end

      private

      def status_code(decode)
        action = params[:action]
        code = action == 'show' ? :ok : :created
        decode.pattern.nil? ? :not_found : code
      end

      def respond_with_basic(success)
        respond_to do |format|
          if success
            format.json { render json: Hash.from_xml(@decode.to_basic_xml).as_json, status: status_code(@decode), location: @decode }
            format.xml { render xml: @decode.to_basic_xml, status: status_code(@decode) }
            format.js { render json: Hash.from_xml(@decode.to_basic_xml).as_json, :callback => params[:callback], status: status_code(@decode)}
          else
            format.json { render json: @decode.errors, status: :unprocessable_entity }
            format.xml { render xml: @decode.errors, status: :unprocessable_entity }
            format.js { render json: @decode, :callback => params[:callback], status: status_code(@decode) }
          end
        end
      end

      def respond_with_advanced(success)
        respond_to do |format|
          if success
            format.json { render json: Hash.from_xml(@decode.to_xml).as_json, status: status_code(@decode), location: @decode }
            format.xml { render xml: @decode.to_xml, status: status_code(@decode) }
            format.js { render json:Hash.from_xml(@decode.to_xml).as_json, :callback => params[:callback], status: status_code(@decode)}
          else
            format.json { render json: @decode.errors, status: :unprocessable_entity }
            format.xml { render xml: @decode.errors, status: :unprocessable_entity }
            format.js { render json: @decode, :callback => params[:callback], status: status_code(@decode) }
          end
        end
      end

      def authenticate_token(token, type)
        current_user = nil
        current_user = User.where(authentication_token: token).first if !token.nil?
        # Check to see if the user is authenticated
        raise AuthenticationError if current_user.nil? # No user found
        # The user is expired or canceled
        raise ExpiredAccountError if current_user.subscription.nil? || !current_user.subscription.active?
        # Check to make sure the user is authorized to use the service
        if current_user.has_role? :admin # Allow Admins both decode types
          user_type = API_ADVANCED
        else
          user_type = current_user.plan.decode_type == 'Basic' ? API_BASIC : API_ADVANCED
        end

        # if type is nil set it to the default type for the plan
        if type.nil?
          type = user_type
        end

        # Allow type to override user_type when plan is Advanced
        if user_type == API_ADVANCED && type.nil?
          type = user_type
        end
        authorize_user(current_user, type == API_BASIC ? :basic : :advanced)
        return current_user, type
      end

      def authorize_user(current_user, service_type)
        if current_user.roles.count > 0
          plan = Plan.where(role: current_user.roles.first).first
        else
          plan = nil
        end
        return if current_user.has_role? :admin # allow an admin to do everything (regardless of plan)
        raise AuthorizationError unless plan.present? && plan.authorize(current_user, service_type)
      end

      def log_decode(decode, decode_type)
        #Thread.new do
          # Save the decode to the log
          remote_ip =  request.remote_ip
          d = DecoderLog.new(ip_address: remote_ip, user_id: decode.user_id, decode_id: decode.id)
          d.decode_type = decode_type
          d.save
        #end
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def decode_params
        params.permit(:vin)
      rescue ActionController::ParameterMissing
        nil
      end

      # Handle Exceptions

      # Authentication Failure (Bad or missing auth_token)
      def authentication_response
        render text: 'Authentication failure', status: :forbidden
      end

      # Authorization Failure (User not authorized for service)
      def authorization_response
        render text: 'Authorization failure', status: :unauthorized
      end

      # Unknown Format
      def unknown_format_response
        render text: 'Format unknown.  Accepts .json (default), .xml, and .js (JSONP)', status: :not_found
      end

      def format_render_response
        render text: 'Unrecognized decode output format. Valid values are 1 (Basic) or 2 (Advanced)', status: :forbidden
      end

      def expired_account_response
        render text: 'Your account is no longer active.', status: :forbidden
      end

      def sample_check
        if params[:auth_token] == ENV['SAMPLE_TOKEN']
          params[:vin] = ENV['SAMPLE_VIN']
        end
      end
    end
  end
end