$('#new_employment_status').submit(function() {
  if ($('#employment_status_status').val() == ""){
    alert("Please enter an employment status");
    return false;
  }
  if ($('#employment_status_status').val().length < 3){
    alert("Status should be minimum 3 characters");
    return false;
  }
});
