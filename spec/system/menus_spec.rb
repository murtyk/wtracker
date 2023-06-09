# frozen_string_literal: true
require 'rails_helper'

def full_menu_list
  [
    ['Dashboard',            '/dashboards'],
    ['Users',                '/users'],

    ['Settings',             '#'],
    ['Applicant Source',     '/applicant_sources'],
    ['Assessment',           '/assessments'],
    ['Employment Status',    '/employment_statuses'],
    ['Funding Source',       '/funding_sources'],
    ['Re-apply Messages',    '/grants/reapply_message'],
    ['Specialized Services', '/special_services'],

    ['Programs',             '/programs'],
    ['Colleges',             '/colleges'],

    ['Advanced Search',      '/trainees/advanced_search']
  ] +
    level3_menu_list
end

def level3_menu_list
  [
    ['Search by skills',      '/trainees/search_by_skills'],
    ['Near By Colleges',      '/trainees/near_by_colleges'],
    ['New Employer Class Interaction', '/klass_interactions/new'],
    ['Employers Hired',       '/reports/new?report_name=employers_hired'],
    ['Employers No Address',  '/reports/new?report_name=employers_no_address'],
    ['Search Jobs',           '/job_searches/new'],
    ['Shared List',           '/job_shares']
  ]
end

def check_common_xpath_menus
  expect_menu('klasses')

  expect_menu('trainees')
  expect_menu('trainees/mapview')
  expect_menu('trainee_emails/new')
  expect_menu('emails/new')

  expect_menu('employers')
  expect_menu('employers/new')
  expect_menu('employers/analysis')
  expect_menu('employers/mapview')

  expect_menu('applicants')
  expect_menu('applicants/analysis')
end

def expect_menu(href)
  expect(page).to have_xpath("//a[@href='/#{href}']")
end

describe 'all menus' do
  subject { page }
  before :each do
    signin_applicants_admin
  end
  after :each do
    signout
  end
  it 'has relevant menu list for applicants grant' do
    full_menu_list.each do |name, href|
      # if link is not found, capybara will throw an exception
      expect(find_link(name, href: href)[:href]).to eq(href)
    end

    list_menus = page.all('a', text: 'List')
    list_menus.each do |m|
      expect(['/klasses', '/job_shares', '/grants'].include?(m[:href])).to be true
    end

    expect(page).to have_xpath("//a[@href='/grants']")

    check_common_xpath_menus
  end
end
describe 'level 3 nav menus' do
  subject { page }
  before :each do
    signin_applicants_nav3
  end
  after :each do
    signout
  end
  it 'has relevant menu list for applicants grant' do
    level3_menu_list.each do |name, href|
      expect(find_link(name)[:href]).to eq(href)
    end

    check_common_xpath_menus

    %w[Dashboard Users Programs].each do |menu|
      expect(page).to_not have_link(menu)
    end

    expect(page).to_not have_xpath("//a[@href='/colleges']")
  end
end
