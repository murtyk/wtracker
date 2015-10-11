$('#select_klass').change(function() {
  var klass_id = $('#select_klass :selected').val();

  if (klass_id == ""){
    $('#select_trainees').html('<option value=""></option>');
  }
  else{
    jQuery.ajaxSetup({async:false});
    $.ajax({
          url: "/klasses/" + klass_id + "/trainees",
          beforeSend: function(xhr, settings) {
            xhr.setRequestHeader('accept', "text/javascript");
            }
          });
    jQuery.ajaxSetup({async:true});
  }
});

$(document).ready(function() {
  var trainee_id = $('.page_data').data('trainee-id');
  $('#select_klass').change();
  if (trainee_id > 0){
    $('#select_trainees').val(trainee_id);
  }
});
