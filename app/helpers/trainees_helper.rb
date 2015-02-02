# helper methods
module TraineesHelper
  def joblead_status_color(job)
    return 'green' if job.applied?
    return 'red' if job.not_interested?
    return 'darkblue' if job.viewed?
    'black'
  end

  def genders
    [['Male', 1], ['Female', 2]]
  end
end
