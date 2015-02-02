class UnemploymentProofsController < ApplicationController
  before_filter :authenticate_user!

  # GET /unemployment_proofs
  # GET /unemployment_proofs.json
  def index
    # debugger
    @unemployment_proofs = UnemploymentProof.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unemployment_proofs }
    end
  end

  # GET /unemployment_proofs.js
  def new
    # debugger
    @unemployment_proof = UnemploymentProof.new
  end

  def create
    @unemployment_proof = UnemploymentProof.new(params[:unemployment_proof])
    @unemployment_proof.save
    @unemployment_proofs = UnemploymentProof.all
  end

  def destroy
    @unemployment_proof = UnemploymentProof.find(params[:id])
    @unemployment_proof.destroy
  end
end
