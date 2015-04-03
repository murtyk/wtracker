$('#new_assessment').submit(function() {
  if ($('#assessment_name').val() == ""){
    alert("Please enter assessment name");
    return false;
  }
  if ($('#assessment_name').val().length < 3){
    alert("Name should be minimum 3 characters");
    return false;
  }
});
