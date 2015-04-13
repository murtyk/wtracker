module ReportsHelper
  def visit_report(name)
    visit('/reports/new?report_name=' + name)
  end
end
