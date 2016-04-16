$(document).on('change', '#select_klass_for_emails', function() {
  var klass_id = $('#select_klass_for_emails :selected').val();
  $.ajax({
    url: "/klasses/" + klass_id + "/trainees_with_email",
    beforeSend: function(xhr, settings) {
      xhr.setRequestHeader('accept', "text/javascript");
      }
  });
});
