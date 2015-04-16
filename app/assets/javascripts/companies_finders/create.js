$(window).load(function() {
  var process_id = $('#page_data').data('process-id');
  if (process_id == null){
    return;
  }
  var processing = true;
  console.log("fetching companies finder status");
  $("#pleaseWaitDialog").modal();
  $("body").css("cursor", "progress");
  jQuery.ajaxSetup({async:false});
  interval = setInterval(function(){
    $.get("/companies_finder/status?process_id=" + process_id, function(data){
      $('#ROWS_SUCCESSFUL').html(data['success_count']);
      $('#ROWS_FAILED').html(data['fail_count']);
      processing = data['status'] != 'FINISHED';
    }, "json")
    .fail(function(jqXHR, textStatus, errorThrown){
      alert("error in companies finder " + textStatus + errorThrown);
    });

    if (!processing) {
      clearInterval(interval);
      jQuery.ajaxSetup({async:true});
      $("body").css("cursor", "default");
      location.href = '/companies_finder?process_id=' + process_id;
    }
  }, 1000);

});
