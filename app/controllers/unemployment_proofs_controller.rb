# frozen_string_literal: true

class UnemploymentProofsController < ApplicationController
  before_action :authenticate_user!

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
    @unemployment_proof = UnemploymentProof.new(unemployment_proof_params)
    @unemployment_proof.save
    @unemployment_proofs = UnemploymentProof.all
  end

  def destroy
    @unemployment_proof = UnemploymentProof.find(params[:id])
    @unemployment_proof.destroy
  end

  private

  def unemployment_proof_params
    params.require(:unemployment_proof).permit(:name)
  end
end
