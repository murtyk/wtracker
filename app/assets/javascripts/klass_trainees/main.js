bind_datepicker();
$(document).on('change', '#klass_trainee_status', function(e) {
  var kt_id, ojt_enrolled;
  var status_id = $('#klass_trainee_status :selected').val();
  if (status_id == 4) {
    // edit_klass_trainee_133_link
    kt_id = $(this).closest('form').attr('id').split('_')[3];

    ojt_enrolled = has_open_placement(kt_id);
    if (ojt_enrolled) {
      alert('Placement data already exists for this trainee. Go to trainee page to view.');
      e.preventDefault();
    }
    else {
      $('#hire_details').show();
    }
  }
  else {
    $('#hire_details').hide();
  };
});

$(document).on('click', "#button-kt-getemployers", function(e){
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

$(document).ready(function(){
  $("form.new_klass_trainee").on('submit', function(e){
    var t_ids;
    var klass_page = $('#page_data').data('klass-page');
    console.log(klass_page);
    if(klass_page != null){
      t_ids = $('#klass_trainee_trainee_id :selected').text();
      if (t_ids == ""){
        alert("Please select trainees");
        return false;
      }
    }
  });
});

$(document).ready(function(){
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
});

function has_open_placement(kt_id){
  var enrolled;
  jQuery.ajaxSetup({async:false});
  $.get("/klass_trainees/" + kt_id + "/ojt_enrolled", function(data) {
      enrolled = data;
  }, "json");
  jQuery.ajaxSetup({async:true});

  return enrolled;
}
