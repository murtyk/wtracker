$('#new_applicant_source').submit(function() {
  if ($('#applicant_source_source').val() == ""){
    alert("Please enter an applicant source");
    return false;
  }
  if ($('#applicant_source_source').val().length < 3){
    alert("Source should be minimum 3 characters");
    return false;
  }
});
