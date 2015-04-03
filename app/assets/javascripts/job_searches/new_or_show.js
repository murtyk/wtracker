var list;
list = $('#colleges').data('locations');
$('#job_search_college_id').change(function() {
  var college = $('#job_search_college_id :selected').text();
  var address = list[college];
  $('#job_search_location').val(address);
});

$('#new_job_search').submit(function() {
  var loc, state;
  if ($('#job_search_location').val() == ""){
     alert("Please enter location. example: Edison, NJ");
     return false;
  }
  if ($('#job_search_keywords').val() == ""){
     alert("Please enter keywords. example: Pediatric Nurse");
     return false;
  }

  if ($('#job_search_in_state').val() == '1')
  {
    loc = $('#job_search_location').val();
    state = loc.split(',')[1];

    jQuery.ajaxSetup({async:false});
    $.get("/job_searches/valid_state", {state_code: state}, function(data) {
      if (data == null || data == false)
      {
        alert('Invalid state code. Please enter valid location.');
        return false;
      }
    });
  }
});

$('.btn-spinner').button();

$('.btn-spinner').click(function() {
    $(this).button('loading');
});
