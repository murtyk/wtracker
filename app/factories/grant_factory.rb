# frozen_string_literal: true

include UtilitiesHelper
# for building email content assiciations
class GrantFactory
  EMAIL_MESSAGE_ATTRS = %i[profile_request_subject_attributes
                           profile_request_content_attributes
                           job_leads_subject_attributes
                           job_leads_content_attributes
                           optout_message_one_attributes
                           optout_message_two_attributes
                           optout_message_three_attributes].freeze
  # for new action
  def self.new_grant(account_id)
    grant = Grant.unscoped.new(account_id: account_id)
    build_profile_associations(grant)
    grant
  end

  # for edit
  def self.find(id)
    grant = Grant.unscoped.find(id)
    build_profile_associations(grant)
    grant
  end

  # for create
  def self.build_grant(params)
    params = clean_attributes(params)
    store_logo_file(params) if params[:applicant_logo_file]
    Grant.unscoped.new(params)
  end

  def self.update(id, params)
    grant = Grant.unscoped.find(id)
    if params[:delete_applicant_logo]
      grant.delete_applicant_logo
      return [grant, 'logo deleted!!!']
    end
    store_logo_file(params) if params[:applicant_logo_file]
    attrs = clean_attributes(params)
    if grant.update_attributes(attrs)
      [grant, 'Grant was successfully updated.']
    else
      [grant, 'Grant Update failed!']
    end
  end

  def self.store_logo_file(params)
    aws_file = Amazon.store_file(params[:applicant_logo_file], 'applicant_logos')
    params[:applicant_logo_file] = aws_file
  end

  def self.clean_attributes(g_params)
    params = g_params.clone
    params[:start_date] = opero_str_to_date(params[:start_date])
    params[:end_date] = opero_str_to_date(params[:end_date])
    if params[:auto_job_leads]
      account_id = params[:account_id]
      EMAIL_MESSAGE_ATTRS.each { |attr| params[attr][:account_id] = account_id }
    else
      EMAIL_MESSAGE_ATTRS.each { |attr| params.delete(attr) }
    end
    params
  end

  def self.build_profile_associations(g)
    aid = { account_id: g.account_id }
    g.profile_request_subject || g.build_profile_request_subject(aid)
    g.profile_request_content || g.build_profile_request_content(aid)
    g.job_leads_subject       || g.build_job_leads_subject(aid)
    g.job_leads_content       || g.build_job_leads_content(aid)
    build_optout_associations(g)
  end

  def self.build_optout_associations(g)
    aid = { account_id: g.account_id }
    g.optout_message_one      || g.build_optout_message_one(aid)
    g.optout_message_two      || g.build_optout_message_two(aid)
    g.optout_message_three    || g.build_optout_message_three(aid)
  end
end
