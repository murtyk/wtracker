# frozen_string_literal: true

# wrapper for rendering trainees based on job search profile
class JobSearchProfilesMap < MapService
  attr_reader :error

  def initialize(trainees)
    @trainees = trainees
    return unless trainees

    generate_markers_json
  end

  private

  def generate_markers_json
    markers = []
    @trainees.each do |trainee|
      jsp = trainee.job_search_profile
      city = GeoServices.findcity(jsp.location)
      info = "<h4>#{trainee.name}</h4>" \
             "<p><b>Location:</b>#{jsp.location}(#{jsp.distance} miles)</p>" \
             "<b>Skills:</b>#{jsp.skills}"
      markers << { lat: city.latitude, lng: city.longitude,
                   title: trainee.name, description: info,
                   picture: get_marker_pic(trainee) }
    end
    @markers_json = markers.to_json
  end
end
