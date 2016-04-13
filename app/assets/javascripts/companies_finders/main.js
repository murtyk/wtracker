function companies_finder_processing(){
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
};

function process_add_results(results){
  var td_status_id, html, error_html, td_checkbox_id;

  console.log("process_add_results");
  console.log(results);

  $.each(results, function(key, value ){

    td_status_id = '#td_status_' + key;

    if(value['added']){
      $(td_status_id).html('<b style="color:green">added</b>');
    }
    else{

      html = '<div data-content="error_message" data-placement="top" href="#" class="popover-error-info" style="color:red;margin-left:60%" ><p style="color:red">error</p></div>'

      // html = '<a href="#" data-toggle="tooltip" title="error_message" style="color:red">error</a>'

      error_html = html.replace("error_message", value['error']);
      $(td_status_id).html(error_html);
    }

    td_checkbox_id = '#td_checkbox_' + key;
    $(td_checkbox_id).html('');
  });
  // $('.popover-error-info').popover({placement: 'top', html: true});
}

function save_add_results(index, data, results){
  var result = { added: false };
  if(data['employer_id']){
    result['added'] = true;
    result['employer_id'] = data['employer_id'];
  }
  else{
    result['error'] = data['error'];
  }
  results[index] = result;
}

$(document).on("click", "#selectAll", function() {
  $('.forAdd').prop('checked', true);
});

$(document).on("click", "#addSelected", function() {

  console.log("clicked #addSelected");

  if ($('#sector_ids :selected').length == 0){
    alert("Please select at least one sector");
    return false;
  }

  var sector_ids = $('#sector_ids').val();
  var results = {};
  var companies  = $('.page_data').data('companies');
  var process_id = $('.page_data').data('process-id');
  var add_success = 0;
  var add_fail    = 0;
  var id, url, params;

  jQuery.ajaxSetup({async: false});

  $("#pleaseWaitDialog").modal();

  $.each(companies, function( index, value ){
    id = '#' + index;

    if($(id).prop('checked')) {

      url = '/companies_finder/add_employer';
      params = {process_id: process_id, index: index, sector_ids: sector_ids};

      $.post(url, params, function(data){
        save_add_results(index, data, results);
        ++add_success;
        $('#ADD_SUCCESSFUL').html(add_success);
        console.log('#ADD_SUCCESSFUL');
      }, "json")
      .fail(function(jqXHR, textStatus, errorThrown){
        ++add_fail;
        $('#ADD_FAILED').html(add_fail);
        console.log('#ADD_FAILED');
        // alert("error in addSelected js");
      });
    }
  });

  jQuery.ajaxSetup({async: true});
  $("#pleaseWaitDialog").modal('hide');

  // alert(JSON.stringify(results));
  process_add_results(results);
});

$(document).on('submit','#form-process-companies',function(e){
  if ($('#file').val() == ""){
    alert("Please select a file");
    return false;
  }
  $('#submit-button').button('loading');
});
