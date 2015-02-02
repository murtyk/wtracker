class ContactsController < ApplicationController
  before_filter :authenticate_user!

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    contact_params = { contactable_type: params[:contactable_type],
                       contactable_id: params[:contactable_id] }
    @contact = Contact.new_with_contactable(contact_params)
    authorize @contact

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @contact }
    end
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
    authorize @contact

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @contact }
    end
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new_with_contactable(params[:contact])
    authorize @contact
    @contact.save
  end

  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    params[:contact].delete :contactable_type
    params[:contact].delete :contactable_id
    @contact = Contact.find(params[:id])
    authorize @contact

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.js
      else
        format.js
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact = Contact.find(params[:id])
    authorize @contact

    @contact.destroy

    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.js
      format.json { head :no_content }
    end
  end
end
