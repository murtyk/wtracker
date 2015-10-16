class KlassCertificatesController < ApplicationController
  before_filter :authenticate_user!

  # GET /klass_certificates/new
  # GET /klass_certificates/new.json
  def new
    klass = Klass.find(params[:klass_id])
    @klass_certificate = klass.klass_certificates.new
    authorize @klass_certificate

    respond_to do |format|
      format.js
      format.json { render json: @klass_certificate }
    end
  end

  # POST /klass_certificates
  # POST /klass_certificates.json
  def create
    @klass_certificate = KlassCertificate.new(klass_certificate_params)
    authorize @klass_certificate

    respond_to do |format|
      if @klass_certificate.save
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  private

  def klass_certificate_params
    params.require(:klass_certificate)
      .permit(:description, :name, :klass_id, :certificate_category_id)
  end
end
