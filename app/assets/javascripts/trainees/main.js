$(document).ready(function () {
  $('#new_trainee').submit(function() {
    var count = $('#trainee_klass_ids option:selected').length;
    if (count == 0){
      alert("Please select at least one class");
      return false;
    }
  });
});

$(document).ready(function () {
  $('.form-search').submit(function() {
    var klass_id, trainee_id, sector_id;
    klass_id = $('#filters_klass_id :selected').text();
    if (klass_id == 0 ){
      alert("Please select a class");
      return false;
    }
    if ($('#filters_near_by_employers').is(':checked')){
      trainee_id = $('#filters_trainee_id :selected').val();
      if (trainee_id == 0 ){
        alert("Please select ONE trainee to find near by employers");
        return false;
      }
      sector_id = $('#filters_sector_id :selected').val();
      if (sector_id == 0 ){
        alert("Please select a sector to find near by employers");
        return false;
      }
    }
    $('#submit-button').button('loading');
  });
});

$(document).ready(function () {
  $('#skills_search_form').submit(function() {
    $('#submit-button').button('loading');
  });
});

$(document).ready(function () {
  $('.new_trainee_email').submit(function() {
    var subject, content;
    subject = $('#trainee_email_subject').val();
    if (subject.length < 5){
      alert('subject should be minimum 5 characters');
      return false;
    }
    content = $('#trainee_email_content').val();
    if (content.length < 5){
      alert('content should be minimum 5 characters');
      return false;
    }
  });
});

$(document).on('click', '#trainee_disabled_show_or_hide', function() {
  div_id = '#trainee_disabled_details';
  if ($(div_id).is(':hidden')){
    $(div_id).show();
    $('#' + button_id + " i").removeClass("icon-arrow-down").addClass("icon-arrow-up");
  }
  else{
    $(div_id).hide();
    $('#' + button_id + " i").removeClass("icon-arrow-up").addClass("icon-arrow-down");
  }
});

$(document).on('change', '#filters_klass_id', function(e) {
  var klass_id;
  klass_id = $('#filters_klass_id :selected').val();

  if (klass_id > 0){
    $.get("/klasses/" + klass_id + "/trainees", function(data) {
          populateTraineesDropdown($("#filters_trainee_id"), data);
      }, "json");

    e.preventDefault();
  }
  else{
    $("#filters_trainee_id").html('');
    $('#filters_near_by_employers').prop("checked", false);
  }
});

function populateTraineesDropdown(select, data) {
  var name = "";
  select.html('');
  select.append($('<option></option>').val(0).html('All'));
  $.each(data, function(id, option) {
    if (!option.middle){
      name = option.first + " " + option.last;
    }
    else{
      name = option.first + " " + option.middle + " " + option.last;
    }
    select.append($('<option></option>').val(option.id).html(name));
  });
}

$(document).on('change', '#filters_trainee_id', function(e){
  var trainee_id;
  trainee_id = $('#filters_trainee_id :selected').val();
  if (trainee_id > 0 ){
    $('#filters_near_by_employers').prop("checked", true);
  }
  else{
    $('#filters_near_by_employers').prop("checked", false);
  }
});

$(document).on('click', '#help-button', function() {
  $('#helpModal').modal();
});
