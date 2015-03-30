$('.show_or_hide_trainees').click(function () {
  var button_id, college_id, div_id, f_show;

  button_id  = $(this).attr('id');
  college_id = button_id.split('_')[3];
  div_id     = '#all_trainees_' + college_id;
  f_show     = $(div_id).is(':hidden');

  if (f_show){
    $(div_id).show();
    $('#' + button_id).html('Hide');
  }
  else{
    $(div_id).hide();
    $('#' + button_id).html('Show All');
  }
});
$('.add_trainees_to_class').click(function () {
  var trainee_ids =
    $("input[type='checkbox']:checked").map(function() {
      return $(this).attr('id');
    }).get();

  if(trainee_ids.length == 0){
    alert('Please select some trainees');
  }
  else{
    href = "/klass_trainees/new?trainee_ids=" + encodeURIComponent(trainee_ids);
    window.open(href, '_blank');
  }
});
