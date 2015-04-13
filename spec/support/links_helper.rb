module  LinksHelper
  def href_link(s)
    page.first(:xpath, "//a[@href='/#{s}']")
  end
end
