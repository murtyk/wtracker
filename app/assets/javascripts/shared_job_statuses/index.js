$('#select_klass').change(function() {
  var klass_id = $('#select_klass :selected').val();

  if (klass_id == "") {
    $('#select_trainees').html('<option value=""></option>');
  }
  else {
    $.ajax({
          url: "/klasses/" + klass_id + "/trainees",
          beforeSend: function(xhr, settings) {
            xhr.setRequestHeader('accept', "text/javascript");
            }
          });
  }
});
$('#select_klass').change();
