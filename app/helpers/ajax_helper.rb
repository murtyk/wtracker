# frozen_string_literal: true

# layout: for list of associations (ex: contacts)
#       Contacts  [New]
#       <div id = 'contacts'>
#         <div id = "contact_2">   for each contact
#           [edit][delete] contact details
#         </div>
#       </div>
# new and edit buttons show the form
#     form id for new:   new_contact
#     for edit           edit_contact_2
# to avoid conflitcts, the link id for buttons should be:
#     for new:     new_contact_link
#         edit:    edit_contact_2_link
#         destroy: destroy_contact_2_link
#     form cancel: cancel_new_contact or cancel_cantact_2

# form cancel action:
# if new contact form:
#    1. remove form (new_contact)
#    2. show new button (new_contact_link)
# else (edit form)
#    1. remove form (id = edit_contact_2)
#    2. show entire div for the contact (id = contact_2)

# form create action
# refresh entire collection <div id='contacts'> or append

# form update action
# refresh <div id='contact_2'> or refresh entire collection (ex:for trainee status)

# destroy action
# just remove <div id ='contact_2'> or refresh collection (ex: when counts are shown)
module AjaxHelper
  def ajax_form_cancel_script(resource, id_prefix = '')
    resource_name = link_name(resource)
    link_id = if resource.new_record?
                "##{id_prefix}new_#{resource_name}_link"
              else
                "##{div_id_for(resource)}"
              end

    form_id = "##{ajax_form_id(resource)}"

    cancel_id = "##{cancel_button_id(resource)}"

    script = "$('#{cancel_id}').click(function() {
    $('#{form_id}').remove();
    $('#{link_id}').show();
    });"
    javascript_tag script
  end

  def div_id_for_collection(cl)
    cl.name.underscore.pluralize
  end

  def div_id_for(resource)
    link_name(resource) + "_#{resource.id}"
  end

  def ajax_form_id(resource)
    resource_name = link_name(resource)
    return "new_#{resource_name}" if resource.new_record?

    "edit_#{resource_name}_#{resource.id}"
  end

  def ajax_form_cancel_button(resource)
    id = cancel_button_id(resource)
    "<input id='#{id}' class='btn btn-flat btn-danger' type='button' value='Cancel'>" \
    '</input>'.html_safe
  end

  def ajax_cancel_and_submit_buttons(f, submit_label = nil)
    cancel_button = ajax_form_cancel_button(f.object)
    "#{cancel_button} #{submit_button(f, submit_label)}"
  end

  def button_new_association(resource, **params_hash)
    skip_policy_check =  params_hash.delete(:skip_policy_check)
    return nil unless skip_policy_check || policy(resource).new?

    resource_name = class_name(resource)
    tip = params_hash.delete(:title) || "New #{resource_name.humanize.capitalize}"
    id_prefix = params_hash.delete(:id_prefix)
    id = new_link_id(resource_name, id_prefix)

    url = new_polymorphic_path(resource, **params_hash)

    link_to(url, class: 'btn btn-flat btn-mini btn-info',
                 id: id,
                 rel: 'tooltip',
                 title: tip,
                 remote: true) do
      "<i class='icon-plus white'></i>".html_safe
    end
  end

  def button_edit_association(resource, **params_hash)
    return nil unless policy(resource).edit?

    tip = params_hash.delete(:title) || 'Edit'
    url = edit_polymorphic_path(resource, **params_hash)
    link_to(url, class: 'btn btn-flat btn-mini btn-warning ajax-edit-button',
                 id: edit_link_id(resource),
                 rel: 'tooltip', title: tip, remote: true) do
      "<i class='icon-edit white'></i>".html_safe
    end
  end

  def button_destroy_association(resource, **params_hash)
    return nil unless policy(resource).destroy?

    confirm_message = params_hash.delete(:confirm_message) || 'Are you sure?'
    tip = params_hash.delete(:title) || 'Delete'

    url = polymorphic_path(resource, **params_hash)
    link_to(url, method: :delete, remote: true, data: { confirm: confirm_message },
                 class: 'btn btn-flat btn-mini btn-danger',
                 id: destroy_link_id(resource),
                 rel: 'tooltip', title: tip) do
      "<i class='icon-trash red'></i>".html_safe
    end
  end

  def new_link_id(resource_name, id_prefix = nil)
    id_prefix.to_s + "new_#{resource_name}_link"
  end

  def edit_link_id(resource)
    resource_name = link_name(resource)
    "edit_#{resource_name}_#{resource.id}_link"
  end

  def destroy_link_id(resource)
    resource_name = link_name(resource)
    "destroy_#{resource_name}_#{resource.id}_link"
  end

  def cancel_button_id(resource)
    resource_name = link_name(resource)
    return "cancel_new_#{resource_name}" if resource.new_record?

    "cancel_#{resource_name}_#{resource.id}"
  end

  def link_name(resource)
    resource.class.name.underscore.gsub('_decorator', '')
  end

  def class_name(resource)
    resource.name.underscore.gsub('_decorator', '')
  end
end
