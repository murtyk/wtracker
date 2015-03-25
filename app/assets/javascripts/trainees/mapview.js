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

$('.btn-spinner').button();

$('#filters_klass_id').change(function(e) {
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

$('#filters_trainee_id').change(function(e){
  var trainee_id;
  trainee_id = $('#filters_trainee_id :selected').val();
  if (trainee_id > 0 ){
    $('#filters_near_by_employers').prop("checked", true);
  }
  else{
    $('#filters_near_by_employers').prop("checked", false);
  }
});

$('#help-button').click(function() {
  $('#helpModal').modal();
});