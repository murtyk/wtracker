bind_datepicker();
$('#klass_trainee_status').change(function() {
  var status_id = $('#klass_trainee_status :selected').val();
  if (status_id == 4) {
    $('#hire_details').show();
  }
  else {
    $('#hire_details').hide();
  };
});

$("#button-getemployers").click(function(e){
  var name = $("#klass_trainee_employer_name").val();
  if (name.length < 1){
    alert("please enter at least 1 character");
    return false;
  }

  $.get("/employers/list_for_trainee", {trainee_id: 0, name: name}, function(data) {
      populateDropdown($("#klass_trainee_employer_id"), data);
  }, "json");

  e.preventDefault();
});

$("form.edit_klass_trainee").on('submit', function(e){
  var status_id, employer_id;
  status_id = $('#klass_trainee_status :selected').val();
  if (status_id == 4) {
    employer_id = $('#klass_trainee_employer_id :selected').val();
    if (employer_id == 0) {
      alert('Please select an employer.');
      return false;
    }
  }
});
