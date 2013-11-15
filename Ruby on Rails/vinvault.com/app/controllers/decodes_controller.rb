class DecodesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_decode, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :except => [:create]


  #GET /decodes
  #GET /decodes.json
  def index
    @decodes = Decode.where(user: current_user)
  end

  # GET /decodes/1
  # GET /decodes/1.json
  def show
  end

  # GET /decodes/new
  def new
    @decode = Decode.new
  end

  # GET /decodes/1/edit
  def edit
  end

  #def decode
  #  @vin = params[:vin]
  #  @pattern = Pattern.find_by_value(Pattern.vin_to_pattern(@vin))
  #  respond_to do |format|
  #    if @pattern.nil?
  #      format.xml { render action: 'show'}
  #      format.json { render action: 'show'}
  #    else
  #      format.xml { render xml: @pattern.errors, status: :unprocessable_entity }
  #      format.json { render json: @pattern.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # POST /decodes
  # POST /decodes.json
  def create
    # look to see if it already exists
    if !decode_params.nil? && !decode_params[:vin].nil? # make sure there's a vin parameter before doing a lookup
      @decode = Decode.where('user_id = ? and vin = ?', current_user.id, decode_params[:vin]).first
    end
    @decode = Decode.new(decode_params) if @decode.nil?
    # Assign current user to decode
    @decode.user = current_user
    #DT.p "Current user: #{current_user.inspect}"
    # @decode.assign_pattern
    respond_to do |format|
      if @decode.save
        log_decode(@decode)
        format.html { redirect_to @decode, notice: 'Decode was successfully created.' }
        format.json { render json: Hash.from_xml(@decode.to_xml).as_json, status: :created, location: @decode }
        format.xml { render xml: @decode, status: :created }
      else
        format.html { render action: 'new', alert: 'Unable to decode vehicle.' }
        format.json { render json: @decode.errors, status: :unprocessable_entity }
        format.xml { render xml: @decode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /decodes/1
  # PATCH/PUT /decodes/1.json
  def update
    respond_to do |format|
      if @decode.update(decode_params)
        log_decode(@decode)
        format.html { redirect_to @decode, notice: 'Decode was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @decode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /decodes/1
  # DELETE /decodes/1.json
  def destroy
    @decode.destroy
    respond_to do |format|
      format.html { redirect_to decodes_url, notice: 'Decode deleted successfully.' }
      format.json { head :no_content }
    end
  end

  private

  def log_decode(decode)
    # Save the decode to the log
    @remote_ip =  request.remote_ip # Assign the IP of the remote request.  Proxy issues?
    # DT.p "remote_ip: #{@remote_ip}"
    DecoderLog.create(decode_id: decode.id, ip_address: @remote_ip, user_id: current_user.id)
  end

  # Use callbacks to share common setup or constraints between actions.
    def set_decode
      @decode = Decode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def decode_params
      params.require(:decode).permit(:vin)
    rescue ActionController::ParameterMissing
      nil
    end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url, alert: 'Access denied.' }
      format.xml { render :xml => '<error>ACCESS_DENIED</error>', :status => :forbidden }
      format.json { render :json => {errors: 'access denied'}}
    end
  end
end
