$('#trainee_disabled_show_or_hide').click(function() {
  div_id = '#trainee_disabled_details';
  if ($(div_id).is(':hidden')){
    $(div_id).show();
    $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
  }
  else{
    $(div_id).hide();
    $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
  }
});
