$('#form-process-companies').submit(function() {
  if ($('#file').val() == ""){
    alert("Please select a file");
    return false;
  }
  $('#submit-button').button('loading');
});
$('.btn-spinner').button();
