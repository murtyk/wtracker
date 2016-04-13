$(document).ready(function () {
  $('#new_report').submit(function() {
    $('#submit-button').button('loading');
  });
});

function send_process_requests(trainees_count, request_url, show_url){
  jQuery.ajaxSetup({async:false});
  n = 0;
  while(n < trainees_count){
    n = n + 1;
    $.get(request_url, function(status) {
    }, "json");
  }
  jQuery.ajaxSetup({async:true});
  location.href = show_url;
}
