$('#job_search_profile_opt_out_reason_code').change(function() {
  var opt_out_reason_code = $('#job_search_profile_opt_out_reason_code :selected').val();
  if (opt_out_reason_code == 1) {
    $('#employment_details').show();
  }
  else {
    $('#employment_details').hide();
  };
  if (opt_out_reason_code == 2) {
    $('#reason_description').show();
  }
  else {
    $('#reason_description').hide();
  };
});
