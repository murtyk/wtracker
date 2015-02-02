class KlassInteractionsController < ApplicationController
  before_filter :authenticate_user!

  # GET /klass_interactions/new
  # GET /klass_interactions/new.json
  def new
    @klass_event = KlassEvent.new
    if params[:employer_id]
      @employer = Employer.find(params[:employer_id])
      @klass_interaction = @employer.klass_interactions.build
    else
      @klass_interaction = KlassInteraction.new
      @employer = Employer.new
      @employer.build_address
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @klass_interaction }
    end
  end

  # GET /klass_interactions/1/edit
  def edit
    @klass_interaction = KlassInteraction.find(params[:id])
    @klass_interaction.from_page = (params[:from] || '').to_i
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @klass_interaction }
    end
  end

  # POST /klass_interactions
  # POST /klass_interactions.json
  def create
    # 2 ways we can come here 1. Employer Page - Class Interaction or
    #                         2. New Emp Class Interaction Menu
    # multiple scenarios
    # 1. New Employer
    # 2. New Event
    # 3. Existing Employer and Event, but no previous interaction for this event
    # 4. Existing Employer and Event and previous interaction exists for this event

    # create employer if new
    # create event and send emails if new
    # update interaction if exists
    # create interaction

    # debugger

    saved,
    @klass_interaction,
    @klass_event,
    @employer = KlassInteractionFactory.create_klass_interaction(params, current_user)

    respond_to do |format|
      if saved
        notice = 'Class Interaction successfully created.'
        format.html { redirect_to @employer, notice:  notice }
        kis = @klass_event.klass_interactions
        format.json { render json: kis, status: :created, location: @klass_interaction }
      else
        format.html { render :new }
        format.json { render json: @klass_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /klass_interactions/1
  # PUT /klass_interactions/1.json
  def update
    @from_page = params[:klass_interaction].delete(:from_page).to_i
    @klass_interaction = KlassInteractionFactory.update_klass_interaction(params,
                                                                          current_user)
  end

  # DELETE /klass_interactions/1
  # DELETE /klass_interactions/1.json
  def destroy
    @klass_interaction = KlassInteraction.find(params[:id])
    @klass_interaction.destroy

    respond_to do |format|
      format.html { redirect_to klass_interactions_url }
      format.js
      format.json { head :no_content }
    end
  end
end
