$(document).ready(function(){
  $('#form-import').submit(function() {
    var count = 0;

    if ($('#sector_ids_').length){
      count = $('#sector_ids_ option:selected').length;
      if (count == 0){
        alert("Please select at least one sector");
        return false;
      }
    }

    if ($('#file').val() == ""){
      alert("Please select a file");
      return false;
    }
    $('#submit-button').button('loading');
  });
});

function perform_import_status(){
  var import_status_id = $('#page_data').data('import-status-id');
  if (import_status_id == null){
    return;
  }
  var processing = true;
  var href  = '/import_statuses/' + import_status_id;
  var admin = $('#page_data').data('admin');
  if (admin != null){
    href = '/admin' + href;
  }
  var status_url = href + '/status';

  console.log("fetching importer status");
  console.log("status url: " + status_url);
  console.log("location href: " + href);

  $("#pleaseWaitDialog").modal();
  $("body").css("cursor", "progress");
  jQuery.ajaxSetup({async:false});
  interval = setInterval(function(){
    $.get(status_url, function(data){
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
      location.href = href;
    }
  }, 1000);
}
