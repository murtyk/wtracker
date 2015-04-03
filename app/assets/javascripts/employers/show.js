$('.klass_events_expand').click(function () {
  var id, ind, klass_id, div_id;

  id = $(this).attr('id');
  klass_id = id.split('_')[3];
  div_id= '#klass_events_' + klass_id;

  ind = $(this).text().search('Expand');

  if (ind > 1){
    $(this).html('Collapse');
    $(div_id).show();
  }
  else{
    $(this).html('Expand');
    $(div_id).hide();
  }
});

$('#employers_more_info_show').click(function () {
  var ind, div_id, employer_note_id, button_id, div_short_notes_id, div_full_notes_id;

  ind = $(this).text().search('Show More');
  if (ind > -1){
    $(this).html('Show Less');
  }
  else{
    $(this).html('Show More');
  }

  $('#employer_notes').find('.employer_note').each(function (index) {
    div_id = $(this).attr('id');
    employer_note_id = div_id.split('_')[2];
    button_id = 'employer_note_show_more_' + employer_note_id;

    div_short_notes_id = '#short_notes_' + employer_note_id;
    div_full_notes_id = '#full_notes_' + employer_note_id;

    if (ind > -1){
      $(div_short_notes_id).hide();
      $(div_full_notes_id).show();

      $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
    }
    else{
      $(div_short_notes_id).show();
      $(div_full_notes_id).hide();
      $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
    }
  });
});

$('#employer_notes').on('click', '.employer-note-show-more-or-less', function() {
  var f_show, employer_note_id, button_id, div_short_notes_id, div_full_notes_id;
  button_id = $(this).attr('id');
  employer_note_id = button_id.split('_')[4];
  div_short_notes_id = '#short_notes_' + employer_note_id;
  div_full_notes_id = '#full_notes_' + employer_note_id;
  f_show = $(div_full_notes_id).is(':hidden');

  if (f_show){
    $(div_short_notes_id).hide();
    $(div_full_notes_id).show();

    $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
  }
  else{
    $(div_short_notes_id).show();
    $(div_full_notes_id).hide();
    $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
  }
});
