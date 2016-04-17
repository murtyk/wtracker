$(document).ready(function(){
  $(".klass_event_form").submit(function(e){
    $('#klass_event_employer_ids option').prop('selected', true);
    return validateNewEvent();
  });
});

$(document).on('click', "#button-getemployers", function(e){

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

$(document).on('click', "#add-selected-employers", function(){
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

$(document).on('click', "#remove-selected-employers", function(){
   $("#klass_event_employer_ids option:selected").remove();
});

$(document).ready(function(){
  $('.combobox').combobox();
});
