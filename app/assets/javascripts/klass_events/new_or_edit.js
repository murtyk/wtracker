$(".simple_form").submit(function(e){
  $('#klass_event_employer_ids option').prop('selected', true);
  return validateNewEvent();
});

$("#button-getemployers").click(function(e){

  var sector_id = $('#sector_id :selected').val();
  var county_id = $('#county_id :selected').val();
  var name = $('#name').val();

  if (sector_id == 0 && county_id == 0 && name == 0){
    alert("please select a sector or county");
    return false;
  }

  $.get("/employers/search", {filters: {county_id: county_id, sector_id: sector_id, name: name}}, function(data) {
        populateDropdown($("#select_employers"), data);
  }, "json");

  e.preventDefault();

});

$("#add-selected-employers").click(function(){
  var str = '';
  var e_option;
   $( "#select_employers option:selected" ).each(function() {
      e_option = $(this);
      if ($("#klass_event_employer_ids option[value="+e_option.val()+"]").length == 0){
        $("#klass_event_employer_ids").append($('<option></option>').val(e_option.val()).html(e_option.text()));
      }
      str += $( this ).text() + " ";
    });
   // alert(str);
});

$("#remove-selected-employers").click(function(){
   $("#klass_event_employer_ids option:selected").remove();
});

function validateNewEvent(){
  var name = $('#klass_event_name').val();
  var dt = $('#klass_event_event_date').val();

  if(name == "") {
    alert('enter event name');
    return false;
  }
  if(dt == "") {
    alert('enter event date');
    return false;
  }
  return true;
}

$(document).ready(function(){
  $('.combobox').combobox();
});
