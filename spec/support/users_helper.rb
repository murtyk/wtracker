module  UserHelper

  def signin_opero_admin
    visit ('/admins/sign_in')
    fill_in 'Email', with: "admin@opero.com"
    fill_in 'Password', with: "adminpassword"
    click_button 'Log in'
  end

  def signout_opero_admin
    click_on 'Sign Out'
  end

  def signin_director
    switch_to_main_domain
    visit root_path
    # click_link 'Sign In'
    fill_in 'email', with: "sher@mail.com"
    fill_in 'password', with: "password"
    click_button 'Sign in'
  end

  def signin_admin
    switch_to_main_domain
    visit root_path
    # click_link 'Sign In'
    fill_in 'user_email', with: "ballu@mail.com"
    fill_in 'user_password', with: "password"
    click_button 'Sign in'
  end

  def signin_navigator
    switch_to_main_domain
    visit root_path
    # click_link 'Sign In'
    fill_in 'email', with: "melinda@mail.com"
    fill_in 'password', with: "password"
    click_button 'Sign in'
  end

  def signin_instructor
    switch_to_main_domain
    visit root_path
    # click_link 'Sign In'
    fill_in 'email', with: "eric@mail.com"
    fill_in 'password', with: "password"
    click_button 'Sign in'
  end


  def signin_college_admin
    switch_to_subdomain('brookdale')
    visit root_path
    # click_link 'Sign In'
    fill_in 'user_email', with: "michele@mail.com"
    fill_in 'user_password', with: "password"
    click_button 'Sign in'
  end

  def signin_autolead_director
    switch_to_subdomain('njit')
    visit root_path
    # click_link 'Sign In'
    fill_in 'user_email', with: "njit@mail.com"
    fill_in 'user_password', with: "password"
    click_button 'Sign in'
  end

  def signout
    click_on 'Welcome'
    click_on 'Sign Off'
    # page.find(:xpath, "//a[@href='/logout']").click
    switch_to_main_domain
  end

  def sign_in_demo_user
    switch_to_demo_domain
    visit root_path
    # click_link 'Sign In'
    # fill_in 'user_email', with: "aandrola@gmail.com"
    fill_in 'user_email', with: User.unscoped.last.email
    fill_in 'user_password', with: "password"
    click_button 'Sign in'
  end

  def signin_applicants_admin
    switch_to_applicants_domain #apple
    visit root_path
    # click_link 'Sign In'
    fill_in 'user_email', with: "corkery@mail.com"
    fill_in 'user_password', with: "password"
    click_button 'Sign in'
  end
end