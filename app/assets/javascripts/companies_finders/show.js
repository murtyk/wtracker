var companies, process_id;
$(document).ready(function() {
  companies  = $('.page_data').data('companies');
  process_id = $('.page_data').data('process-id');
});

$("#selectAll").click(function() {
  $('.forAdd').prop('checked', true);
});

$("#addSelected").click(function() {
  if ($('#sector_ids :selected').length == 0){
    alert("Please select at least one sector");
    return false;
  }
  sector_ids = $('#sector_ids').val();
  results = {};
  var add_success = 0;
  var add_fail    = 0;
  jQuery.ajaxSetup({async:false});
  $("#pleaseWaitDialog").modal();
  $.each(companies, function( index, value ){
    id = '#' + index;
    if($(id).prop('checked')) {
      url = '/companies_finder/add_employer';
      params = {process_id: process_id, index: index, sector_ids: sector_ids};
      $.post(url, params, function(data){
        save_add_results(index, data);
        ++add_success;
        $('#ADD_SUCCESSFUL').html(add_success);
      }, "json")
      .fail(function(jqXHR, textStatus, errorThrown){
        ++add_fail;
        $('#ADD_FAILED').html(add_fail);
        // alert("error in addSelected js");
      });
    }
  });
  jQuery.ajaxSetup({async:true});
  $("#pleaseWaitDialog").modal('hide');

  // alert(JSON.stringify(results));
  process_add_results();
});

function save_add_results(index, data){
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

function process_add_results(){
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
  $('.popover-error-info').popover({placement: 'top', html: true});
}

$('[data-toggle="popover"]').popover();

$('body').on('click', function (e) {
    $('[data-toggle="popover"]').each(function () {
        //the 'is' for buttons that trigger popups
        //the 'has' for icons within a button that triggers a popup
        if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
            $(this).popover('hide');
        }
    });
});
