$(document).on('click', '#expandcollapse', function () {
  ind = $(this).text().search('Expand');
  if (ind > -1) {
    $('#accordion2').find('.collapse:not(.in)').each(function (index) {
      $(this).collapse("toggle");
    });
    $(this).html("<i class='icon-white icon-minus-sign'></i> Collapse All");
  }
  else {
    $('#accordion2').find('.collapse.in').each(function (index) {
      $(this).collapse("toggle");
    });
    $(this).html("<i class='icon-white icon-plus-sign'></i> Expand All");
  }
});

$(document).on('click', '#trainees_more_info_show', function () {
  var ind, div_id, klass_trainee_id, button_id;
  ind = $(this).text().search('Show More');
  if (ind > -1){
    $(this).html('Show Less');
  }
  else{
    $(this).html('Show More');
  }
  $('#klass_trainees').find('.trainee_details').each(function (index) {
    div_id = $(this).attr('id');
    klass_trainee_id = div_id.split('_')[3];
    button_id = 'Klass_trainee_show_more_' + klass_trainee_id;

    if (ind > -1){
      $(this).show();
      $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
    }
    else{
      $(this).hide();
      $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
    }
  });
});

$(document).on('click', '#klass_trainees .klass-trainee-info', function() {
  var div_id, button_id, klass_trainee_id;
  button_id = $(this).attr('id');
  klass_trainee_id = button_id.split('_')[4];
  div_id = '#klass_trainee_details_' + klass_trainee_id;
  if ($(div_id).is(':hidden')){
    $(div_id).show();
    $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
  }
  else{
    $(div_id).hide();
    $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
  }
});

$(document).on('click', "#brief_calendar_table tr td", function(event) {
  var event_id = $(this).attr('id');
  if (event_id != undefined){
    event_id = event_id.split('_')[2];
    // alert(event_id);
    location.href = '/klass_events/' + event_id + '/edit';
  }
});

$(document).ready(function() {
  var kt_ids = $('#klass_titles_data').data('kt-ids');
  if (kt_ids) {
    refresh_job_counts(kt_ids);
  }
});
