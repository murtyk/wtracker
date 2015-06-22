# helper for menu bar
module MenusHelper
  def profile_menu
    link = link_to(current_user) do
      '<i class="icon-user"></i>Profile'.html_safe
    end

    "<li>#{link}</li>".html_safe
  end

  def change_password_menu
    link = link_to(edit_password_users_path) do
      '<i class="icon-lock"></i>Change Password'.html_safe
    end

    "<li>#{link}</li>".html_safe
  end

  def preferences_menu
    return unless current_user.admin_access?

    link = link_to(preferences_users_path) do
      '<i class="icon-asterisk"></i>Preferences'.html_safe
    end

    "<li>#{link}</li>".html_safe
  end

  def sign_off_menu
    link = link_to(destroy_user_session_path, method: :delete) do
      '<i class="icon-off"></i>Sign Off'.html_safe
    end

    "<li>#{link}</li>".html_safe
  end

  def dashboard_menu
    return unless current_user.admin_access?
    menu_link('Dashboard', dashboards_path)
  end

  def users_menu
    policy(User).index? ? menu_link('Users', users_path) : nil
  end

  def grants_menu
    return grants_grants_menu unless grants_dropdown_menu?
    if current_user.admin_access?
      items = grants_list_menu + grant_context_change_menu
    else
      items = grant_context_change_menu
    end
    build_dropdown_menu('Grants', items)
  end

  def grants_dropdown_menu?
    current_account.grant_recipient? &&
      current_user.active_grants.count > 1
  end

  def grants_grants_menu
    return unless current_account.grant_recipient?
    policy(Grant).index? ? menu_link('Grants', grants_path) : nil
  end

  def grants_list_menu
    menu_link('List', grants_path)
  end

  def grant_context_change_menu
    menu_link('Change Current Grant', starting_page_dashboards_path)
  end

  def settings_menu
    return unless settings_menu?
    items = [applicant_sources_menu,
             assessments_menu,
             employment_statuses_menu,
             funding_sources_menu,
             reapply_message_menu,
             special_services_menu,
             trainee_options_menu,
             unemployment_proofs_menu].join
    build_dropdown_menu('Settings', items)
  end

  def applicant_sources_menu
    ta_settings_menu? ? menu_link('Applicant Source', applicant_sources_path) : ''
  end

  def assessments_menu
    settings_menu? ? menu_link('Assessments', assessments_path) : ''
  end

  def employment_statuses_menu
    ta_settings_menu? ? menu_link('Employment Status', employment_statuses_path) : ''
  end

  def funding_sources_menu
    settings_menu? ? menu_link('Funding Sources', funding_sources_path) : ''
  end

  def reapply_message_menu
    ta_settings_menu? ? menu_link('Re-apply Messages', reapply_message_grants_path) : ''
  end

  def special_services_menu
    ta_settings_menu? ? menu_link('Specialized Services', special_services_path) : ''
  end

  def trainee_options_menu
    settings_menu? ? menu_link('Trainee Options', trainee_options_accounts_path) : ''
  end

  def unemployment_proofs_menu
    ta_settings_menu? ? menu_link('Unemployment Proof', unemployment_proofs_path) : ''
  end

  def colleges_menu
    policy(College).index? ? menu_link('Colleges', colleges_path) : nil
  end

  def programs_menu
    policy(Program).index? ? menu_link('Programs', programs_path) : nil
  end

  def klasses_menu
    items = klasses_list_menu + klasses_import_menu
    build_dropdown_menu('Classes', items)
  end

  def klasses_list_menu
    policy(Klass).index? ? menu_link('List', klasses_path) : nil
  end

  def klasses_import_menu
    return unless policy(Klass).create?
    menu_link('Import from a file', new_import_status_path(resource: 'klasses'))
  end

  def applicants_menu
    return unless current_grant.trainee_applications?
    items = applicants_menu_items
    build_dropdown_menu('Applicants', items)
  end

  def applicants_menu_items
    applicants_search_menu +
      applicants_analysis_menu
  end

  def applicants_search_menu
    trainee_applications? ? menu_link('Search', applicants_path) : nil
  end

  def applicants_analysis_menu
    trainee_applications? ? menu_link('Analysis', analysis_applicants_path) : nil
  end

  def trainees_menu
    items = trainees_search_menu +
            trainees_advanced_search_menu +
            trainee_auto_leads_items

    items +=  trainees_create_menu_items
    items +=  trainees_mapview_menu_items
    items +=  divider_menu +
              trainees_send_mail_menu +
              trainees_emails_sent_menu

    build_dropdown_menu('Trainees', items)
  end

  def trainees_create_menu_items
    return unless policy(Trainee).create?
    divider_menu + trainees_add_menu + trainees_import_menu
  end

  def trainees_mapview_menu_items
    return unless policy(Trainee).mapview?
    divider_menu + trainees_map_view_menu + trainees_near_by_colleges_menu
  end

  def trainees_search_menu
    menu_link('Search', trainees_path)
  end

  def trainee_auto_leads_items
    return unless current_grant.auto_job_leads?
    items = divider_menu +
            trainees_search_by_skills_menu
    return items unless trainee_applications?
    items + auto_job_leads_metrics_menu
  end

  def auto_job_leads_metrics_menu
    menu_link('Job Leads Metrics', dashboards_path(auto_leads_metrics: true))
  end

  def trainees_search_by_skills_menu
    menu_link('Search by skills', search_by_skills_trainees_path)
  end

  def trainees_advanced_search_menu
    return if current_user.instructor?
    menu_link('Advanced Search', advanced_search_trainees_path)
  end

  def trainees_add_menu
    policy(Trainee).create? ? menu_link('Add', new_trainee_path) : nil
  end

  def trainees_import_menu
    return unless policy(Trainee).import?
    menu_link('Import from a file', new_import_status_path(resource: 'trainees'))
  end

  def trainees_map_view_menu
    menu_link('Map View', mapview_trainees_path)
  end

  def trainees_near_by_colleges_menu
    return unless trainee_applications?
    menu_link('Near By Colleges', near_by_colleges_trainees_path)
  end

  def trainees_send_mail_menu
    menu_link('Send Email', new_trainee_email_path)
  end

  def trainees_emails_sent_menu
    menu_link('Emails Sent', trainee_emails_path)
  end

  def employers_menu
    return unless policy(Employer).index?
    items = employers_search_menu_items + employers_create_menu_items
    items += [
      divider_menu,
      employers_map_view_menu,
      employers_analysis_menu,
      divider_menu,
      employers_klass_interaction_menu,
      employers_send_email_menu,
      employers_sent_emails_menu]

    build_dropdown_menu('Employers', items.join)
  end

  def employers_search_menu_items
    [employers_search_menu, companies_search_menu, google_companies_menu]
  end

  def employers_create_menu_items
    return unless policy(Employer).create?
    [divider_menu, employers_add_menu, employers_import_menu]
  end

  def employers_search_menu
    menu_link('Search', employers_path)
  end

  def employers_add_menu
    return unless policy(Employer).create?
    menu_link('Add', new_employer_path)
  end

  def employers_import_menu
    return unless policy(Employer).import?
    menu_link('Import from a file', new_import_status_path(resource: 'employers'))
  end

  def companies_search_menu
    return unless current_user.admin_access? && policy(Employer).create?
    menu_link('Search for Companies in a File', new_companies_finder_path)
  end

  def employers_map_view_menu
    menu_link('Map View', mapview_employers_path)
  end

  def employers_analysis_menu
    menu_link('Analysis', analysis_employers_path)
  end

  def google_companies_menu
    return if Rails.env.production?
    menu_link('Search Google', google_companies_path)
  end

  def employers_klass_interaction_menu
    menu_link('New Employer Class Interaction', new_klass_interaction_path)
  end

  def employers_send_email_menu
    menu_link('Send Email', new_email_path)
  end

  def employers_sent_emails_menu
    menu_link('Emails Sent', emails_path)
  end

  def reports_menu
    return unless policy(Report).new?
    (
      '<li class="dropdown">' \
      '<a class="dropdown-toggle" data-toggle="dropdown" href="#">' \
      'Reports' \
      '<b class="caret" style="border-top-color: white;"></b>' \
      '</a>' \
      '<ul class="dropdown-menu">' +
      reports_menu_items +
      '</ul>' \
      '</li>'
    ).html_safe
  end

  def reports_menu_items
    Report.reports_by_type(current_user).map do |type, reports|
      '<li class="dropdown-submenu">' \
        '<a tabindex="-1" href="#">' + type + '</a>' \
        '<ul class="dropdown-menu">' +
        reports.map { |report| '<li>' + report_link(report) + '</li>' }.join +
        '</ul>' \
        '</li>'
    end.join('')
  end

  def jobs_menu
    return unless policy(JobSearch).new?
    items = search_jobs_menu + shared_jobs_list_menu + job_leads_status_menu +
            divider_menu + hot_jobs_menu
    build_dropdown_menu('Jobs', items)
  end

  def search_jobs_menu
    menu_link('Search Jobs', new_job_search_path)
  end

  def shared_jobs_list_menu
    menu_link('Shared List', job_shares_path)
  end

  def job_leads_status_menu
    return unless current_account.track_trainee_status?
    menu_link('Job Leads Status', shared_job_statuses_path)
  end

  def hot_jobs_menu
    policy(HotJob).index? ? menu_link('Hot Jobs', hot_jobs_path) : nil
  end

  def menu_link(s, path)
    ('<li>' + link_to(s, path) + '</li>').html_safe
  end

  def report_link(name, label = nil)
    label ||= name.split('_').map(&:capitalize).join(' ')
    link_to(label, new_report_path(report_name: name))
  end

  def settings_menu?
    current_user.admin_access?
  end

  def trainee_applications?
    grant = Grant.find Grant.current_id
    grant.trainee_applications?
  end

  def ta_settings_menu?
    trainee_applications? && settings_menu?
  end

  def build_dropdown_menu(title, items)
    (
    '<li class="dropdown">' \
      '<a class="dropdown-toggle" data-toggle="dropdown" href="#">' +
        title +
        '<b class="caret" style="border-top-color: white;"></b>' \
      '</a>' \
      '<ul class="dropdown-menu">' +
        items +
      '</ul>' \
    '</li>'
    ).html_safe
  end

  def divider_menu
    '<li class="divider"></li>'.html_safe
  end

  # following is for building menus for opero admin
  def admin_menu_items
    [
      menu_link('Users', admin_users_path),
      menu_link('Accounts', admin_accounts_path),
      menu_link('Import Status', admin_import_statuses_path),
      menu_link('Counties', admin_counties_path),
      admin_cities_menu_group,
      admin_s3_menu_group,
      admin_sign_off_menu
    ].join.html_safe
  end

  def admin_cities_menu_group
    '<li class="dropdown">
      <a class="dropdown-toggle" data-toggle="dropdown" href="#">
        Cities
        <b class="caret" style="border-top-color: white;"></b>
      </a>
      <ul class="dropdown-menu">' +
      menu_link('Index', admin_cities_path) +
      menu_link('Import', new_admin_import_status_path(resource: 'cities')) +
      '</ul>
    </li>'
  end

  def admin_s3_menu_group
    '<li class="dropdown">
      <a class="dropdown-toggle" data-toggle="dropdown" href="#">
        S3
        <b class="caret" style="border-top-color: white;"></b>
      </a>
      <ul class="dropdown-menu">' +
      menu_link('List', admin_aws_s3s_path) +
      menu_link('Recycle Bin', recycle_bin_admin_aws_s3s_path) +
      '</ul>
    </li>'
  end

  def admin_sign_off_menu
    '<li>' +
      link_to('Sign Out', destroy_admin_session_path, method: :delete) +
      '</li>'
  end

  # following is for building menus for trainee portal
  def trainee_menu_items
    sign_off_link =  '<li>' +
                     link_to(destroy_trainee_session_path, method: :delete) do
                       '<i class="icon-off"></i> Sign Off'.html_safe
                     end +
                     '</li>'

    return sign_off_link.html_safe unless current_trainee.completed_trainee_data?

    [trainee_placements_menu,
     trainee_documents_menu,
     trainee_jobs_menu,
     sign_off_link].join('').html_safe
  end

  def trainee_placements_menu
    menu_link('Placements', trainee_trainee_placements_path)
  end

  def trainee_documents_menu
    menu_link('Documents', trainee_trainee_files_path)
  end

  def trainee_jobs_menu
    menu_link('Jobs', [:trainee, current_trainee.job_search_profile])
  end
end
