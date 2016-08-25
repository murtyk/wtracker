# for user sign in and sign out
module  UserHelper
  def signin_opero_admin
    visit '/admins/sign_in'
    fill_in 'admin_email', with: 'admin@opero.com'
    fill_in 'admin_password', with: 'adminpassword'
    click_button 'Sign in'
  end

  def signout_opero_admin
    click_on 'Sign Out'
  end

  def signin_director
    sign_in_user('www', 'sher@mail.com')
  end

  def signin_admin
    sign_in_user('www', 'ballu@mail.com')
  end

  def signin_navigator
    sign_in_user('www', 'melinda@mail.com')
  end

  def signin_instructor
    sign_in_user('www', 'eric@mail.com')
  end

  def signin_college_admin
    sign_in_user('brookdale', 'michele@mail.com')
  end

  def signin_college_director
    sign_in_user('brookdale', 'marie@mail.com')
  end

  def signin_autolead_director
    sign_in_user('njit', 'njit@mail.com')
  end

  def signin_applicants_director
    sign_in_user('apple', 'hilpert@mail.com')
  end

  def signout
    click_on 'Welcome'
    click_on 'Sign Off'
    # page.find(:xpath, "//a[@href='/logout']").click
    switch_to_main_domain
  end

  def sign_in_demo_user
    Account.current_id = Account.find_by(subdomain: 'demo').id
    email = User.unscoped.last.email

    sign_in_user('demo', email)
  end

  def signin_applicants_admin
    sign_in_user('apple', 'corkery@mail.com')
  end

  def signin_applicants_nav
    sign_in_user('apple', 'melinda1@mail.com')
  end

  def signin_applicants_nav3
    sign_in_user('apple', 'cameron@nomail.net')
  end

  def sign_in_user(sub, email, pwd = 'password')
    switch_to_subdomain(sub)
    visit '/login'
    fill_in 'user_email', with: email
    fill_in 'user_password', with: pwd
    click_button 'Sign in'
  end

  def admin_user
    User.find_by(email: 'ballu@mail.com')
  end
end
