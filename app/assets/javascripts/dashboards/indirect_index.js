$('.klass_filter').click(function (){
  var button_id, klass_type, f_show_scheduled, f_show_ongoing, f_show_completed;

  button_id = $(this).attr('id');
  klass_type = button_id.split('_')[0]
  f_show_scheduled = klass_type == '1' || klass_type == '0';
  f_show_ongoing   = klass_type == '2' || klass_type == '0';
  f_show_completed = klass_type == '3' || klass_type == '0';

  $('#all_programs').find('.scheduled_classes').each(function (index){
    if (f_show_scheduled){
      $(this).show();
    }
    else{
      $(this).hide();
    }
  });

  $('#all_programs').find('.ongoing_classes').each(function (index){
    if (f_show_ongoing){
      $(this).show();
    }
    else{
      $(this).hide();
    }
  });

  $('#all_programs').find('.completed_classes').each(function (index){
    if (f_show_completed){
      $(this).show();
    }
    else{
      $(this).hide();
    }
  });
});
