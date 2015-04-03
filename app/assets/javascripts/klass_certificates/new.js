$('#new_klass_certificate').submit(function() {
  if ($('#klass_certificate_name').val() == ""){
    alert("Please enter certificate name");
    return false;
  }
});
