$('#hot_job_employer_id').change(function(e) {
  var id = $('#hot_job_employer_id :selected').val();
  $.get("/employers/" + id + "/address_location", function(data) {
    $('#hot_job_location').val(data);
  }, "json");
  // e.preventDefault();
});
