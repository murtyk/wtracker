# helper for creating buttons with icons
module ButtonsHelper
  def show_button(resource)
    return nil unless policy(resource).show?
    link_to(polymorphic_path(resource),
            id: button_id(resource),
            class: 'btn btn-flat btn-mini btn-info',
            title: 'Show') do
      '<i class="icon-eye-open"></i>'.html_safe
    end
  end

  def add_button(btn_class, name, resource, params = {}, tip = nil)
    return nil unless policy(resource).create?

    name     = name.nil? ? '' : ' ' + name.to_s.squish
    title    = tip || "New #{resource.name}"
    params ||= {}

    link_to(new_polymorphic_path(resource, params),
            id: build_add_button_id(resource),
            class: btn_class,
            title: title) do
      "<i class='icon-plus'>#{name}</i>".html_safe
    end
  end

  def build_add_button_id(resource)
    'new_' + resource.name.underscore.downcase + '_link'
  end

  def plus_button(resource, params = {}, tip = nil) # resource is Class
    btn_class = 'btn btn-flat btn-mini btn-info'
    add_button(btn_class, nil, resource, params, tip)
  end

  def new_button(resource, params = {}, tip = nil) # resource is Class
    btn_class = 'btn btn-flat btn-small btn-primary pull-right'
    add_button(btn_class, 'New', resource, params, tip)
  end

  def edit_button(resource)
    return nil unless policy(resource).edit?
    id = 'edit_' + button_id(resource)
    link_to(edit_polymorphic_path(resource),
            id: id,
            class: 'btn btn-flat btn-mini btn-warning',
            title: 'Edit') do
      '<i class="icon-edit"></i>'.html_safe
    end
  end

  def delete_message_button(msg)
    btn_class = 'btn btn-flat btn-mini btn-danger btn-message'
    link_to('', class: btn_class, rel: 'tooltip', title: 'Delete', message: msg) do
      "<i class='icon-trash red'></i>".html_safe
    end
  end

  def download_button(para = {}, name = '')
    para ||= {}
    link_to(url_for(params.merge(para).merge(format: 'xls')),
            class: 'btn btn-flat btn-small btn-primary btn-download pull-right',
            title: 'Download') do
      "<i class='icon-cloud-download'>#{name}</i>".html_safe
    end
  end

  def email_download_button(para = {}, name = '')
    link_to(url_for(params.merge(para)),
            remote: true,
            class: 'btn btn-flat btn-small btn-primary btn-email-download pull-right',
            title: 'Send Data by Email') do
      "<i class='icon-envelope'>#{name}</i>".html_safe
    end
  end

  def submit_button(f, label = nil)
    label ||= f.object.new_record? ? 'Add' : 'Update'
    # f.button :submit, label, class: 'btn btn-flat btn-medium btn-primary'
    icon_class = label == 'Find' ? 'icon-search' : 'icon-ok'

    "<button class='btn btn-flat btn-small btn-primary' type='submit'>
    <i class='#{icon_class}'></i> #{label}
    </button>".html_safe
  end

  def import_button
    btn_html =  "<button type='submit' id='submit-button' "
    btn_html +=  "class= 'btn btn-flat btn-primary btn-spinner'"
    btn_html += ' data-loading-text="'
    btn_html += "<i class='icon-spinner icon-spin icon-large'></i> Processing..." + '">'
    btn_html += "<i class='icon-upload icon-white'></i> Import</button>"
    btn_html.html_safe
  end

  def button_id(resource)
    resource.class.name.underscore.gsub('_decorator', '') + "_#{resource.id}"
  end
end
