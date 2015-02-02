class KlassCertificatesController < ApplicationController
  before_filter :authenticate_user!

  # GET /klass_certificates/new
  # GET /klass_certificates/new.json
  def new
    klass = Klass.find(params[:klass_id])
    @klass_certificate = klass.klass_certificates.build
    authorize @klass_certificate

    respond_to do |format|
      format.js
      format.json { render json: @klass_certificate }
    end
  end

  # POST /klass_certificates
  # POST /klass_certificates.json
  def create
    @klass_certificate = KlassCertificate.new(params[:klass_certificate])
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
end
