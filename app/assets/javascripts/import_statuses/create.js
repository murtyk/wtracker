$(window).load(function() {
  var import_status_id = $('#page_data').data('import-status-id');
  if (import_status_id == null){
    return;
  }

  var processing = true
  console.log("fetching importer status");
  $("#pleaseWaitDialog").modal();
  $("body").css("cursor", "progress");
  jQuery.ajaxSetup({async:false});
  interval = setInterval(function(){
    $.get('/import_statuses/' + import_status_id + '/status', function(data){
      $('#ROWS_SUCCESSFUL').html(data['rows_successful']);
      $('#ROWS_FAILED').html(data['rows_failed']);
      processing = data['status'] != 'completed';
    }, "json")
    .fail(function(jqXHR, textStatus, errorThrown){
      alert("error in importer " + textStatus + errorThrown);
    });

    if (!processing) {
      clearInterval(interval);
      jQuery.ajaxSetup({async:true});
      $("body").css("cursor", "default");
      location.href = '/import_statuses/' + import_status_id;
    }
  }, 1000);
});
