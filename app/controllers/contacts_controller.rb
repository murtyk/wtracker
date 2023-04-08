# frozen_string_literal: true

class ContactsController < ApplicationController
  before_filter :authenticate_user!

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    # contact_params = { contactable_type: params[:contactable_type],
    #                    contactable_id: params[:contactable_id] }
    # @contact = Contact.new_with_contactable(contact_params)

    @contact = contactable.contacts.new
    @contact.land_no = contactable.try(:phone_no)

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
    # @contact = Contact.new_with_contactable(params[:contact])
    @contact = contactable.contacts.new(contact_params)
    authorize @contact
    @contact.save
  end

  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    # params[:contact].delete :contactable_type
    # params[:contact].delete :contactable_id
    @contact = Contact.find(params[:id])
    authorize @contact

    respond_to do |format|
      if @contact.update_attributes(contact_params)
      end
      format.js
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

  private

  def contact_params
    params.require(:contact)
          .permit(:email, :first, :last, :land_no, :ext, :mobile_no, :title)
  end

  def contactable
    c_type = params[:contactable_type] || params[:contact][:contactable_type]
    c_id = params[:contactable_id] || params[:contact][:contactable_id]
    owner_class = Object.const_get(c_type)
    owner_class.find(c_id)
  end
end
