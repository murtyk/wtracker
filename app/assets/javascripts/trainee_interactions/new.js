bind_datepicker();
$("form.new_trainee_interaction").submit(function(e){
  console.log('form.new_trainee_interaction.submit');
  toid = $('#trainee_interaction_employer_id :selected').text();
  if (toid == ""){
    alert("Please select an employer");
    return false;
  }
});

$("#button-getemployers").click(function(e){

    var name = $("#trainee_interaction_employer_name").val();
    if (name.length < 1){
      alert("please enter at least 1 character");
      return false;
    }

    var trainee_id = $("#trainee_interaction_trainee_id").val();
    var hashName = {name: name}

    $.get("/employers/list_for_trainee", {trainee_id: trainee_id, name: name}, function(data) {
          populateDropdown($("#trainee_interaction_employer_id"), data);
    }, "json");

    e.preventDefault();
});
