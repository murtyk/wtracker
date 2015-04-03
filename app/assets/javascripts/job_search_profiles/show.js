$('.joblink').click(function() {
  arr = $(this).attr('id').split('-');
  url = '/auto_shared_jobs/' + arr[0] + '/edit?key=' + arr[1] + '&status=1',
  $.ajax({
        url: url,
        beforeSend: function(xhr, settings) {
          xhr.setRequestHeader('accept', "text/javascript");
          }
        });
});
$('.job-note-show-more-or-less').click(function() {
  button_id = $(this).attr('id');
  job_id = button_id.split('_')[4];
  div_short_notes_id = '#short_notes_' + job_id;
  div_full_notes_id = '#full_notes_' + job_id;
  f_show = $(div_full_notes_id).is(':hidden');

  if (f_show)
  {
    $(div_short_notes_id).hide();
    $(div_full_notes_id).show();

    $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
  }
  else
  {
    $(div_short_notes_id).show();
    $(div_full_notes_id).hide();
    $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
  }
});
function after_note_updated(job_id, short_notes, full_notes, notes_label) {
  $("#modal_edit_notes").modal("hide");
  $('#full_notes_' + job_id).text(full_notes);
  $('#short_notes_' + job_id).text(short_notes);
  $('#notes_label_' + job_id).text(notes_label);
}
