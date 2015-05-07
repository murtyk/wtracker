jQuery(function($){
  $("#trainee_dob").mask("99/99/9999",{placeholder:"mm/dd/yyyy"});
  $("#trainee_trainee_id").mask("999-99-9999");
});
$('#trainee_file_form').submit(function() {
  var txt = $('#trainee_file_file').val();
  if (txt == ''){
    alert("Please select a file");
    return false;
  }
  var ext = txt.match(/\.([^\.]+)$/)[1];
  switch(ext)
  {
    case 'pdf':
    case 'docx':
    case 'doc':
      break;
    default:
      alert('Invalid file type. Please select a file with extensions either pdf or docx');
      return false;
  }
})
