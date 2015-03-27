$('#new_trainee').submit(function() {
  var count = $('#trainee_klass_ids option:selected').length;
  if (count == 0){
    alert("Please select at least one class");
    return false;
  }
})
