//= require ./new_common.js
$('#select_klass').change(function() {
  var klass_id = $('#select_klass :selected').val();
  $.ajax({
        url: "/klasses/" + klass_id + "/trainees",
        beforeSend: function(xhr, settings) {
          xhr.setRequestHeader('accept', "text/javascript");
          }
        });
});
