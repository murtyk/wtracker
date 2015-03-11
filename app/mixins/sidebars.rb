# grant specific options for sidebar visibility
module Sidebars
  EMPLOYER_PAGE = 100
  EMPLOYER_PAGE_TRAINEE_INFO       = 101
  EMPLOYER_PAGE_CLASS_INTERACTIONS = 102

  TRAINEE_PAGE = 200
  TRAINEE_PAGE_JOBS = 201

  PAGES = {
    EMPLOYER_PAGE => 'Employer Page',
    TRAINEE_PAGE =>  'Trainee Page'
  }

  SIDE_BARS = {
    EMPLOYER_PAGE => { EMPLOYER_PAGE_TRAINEE_INFO => 'Trainee Information',
                       EMPLOYER_PAGE_CLASS_INTERACTIONS => 'Class Interactions' },

    TRAINEE_PAGE =>  { TRAINEE_PAGE_JOBS => 'Jobs Information' }
  }

  def hide_a_side_bar(sidebar)
    self.hidden_sidebars ||= []
    self.hidden_sidebars += [sidebar]
    save
  end

  def show_a_side_bar(sidebar)
    self.hidden_sidebars ||= []
    self.hidden_sidebars -= [sidebar]
    save
  end

  def pages
    PAGES
  end

  def side_bars(page)
    SIDE_BARS[page]
  end

  def visible_side_bars(page)
    v_keys = side_bars(page).keys - (hidden_sidebars || [])
    side_bars(page).slice(*v_keys)
  end

  def show_side_bar?(sidebar)
    return true if hidden_sidebars.blank?
    !hidden_sidebars.include?(sidebar.to_s)
  end
end
