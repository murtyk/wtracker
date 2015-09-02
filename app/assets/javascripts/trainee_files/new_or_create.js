$('#trainee_file_form').submit(function() {
  var unemployment_proof = $('#page_data').data('unemployment-proof');
  var txt = $('#trainee_file_file').val();

  if (txt == ''){
    if (unemployment_proof){
      return validate_unemployment_proof();
    }
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
      alert('Invalid file type. Please select a file with extensions either pdf, docx or doc');
      return false;
  }
})

function validate_unemployment_proof(){
  var initial = $('#trainee_file_unemployment_proof_initial').val();
  var date = $('#trainee_file_unemployment_proof_date').val();

  if (initial.trim() == '' || date.trim() == ''){
    alert('Select a file OR enter initial and date');
    return false;
  }
}
