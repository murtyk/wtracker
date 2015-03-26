$('#form_employer').submit(function() {
  var name, count, line1, city, state, zip;
  name = $('#employer_name').val();
  if (name.length < 3){
    alert('name should be minimum 3 characters');
    return false;
  }
  count = $('#employer_sector_ids option:selected').length;
  if (count == 0){
    alert("Please select at least one sector");
    return false;
  }
  line1 =  $('#employer_address_attributes_line1').val();
  city =  $('#employer_address_attributes_city').val();
  state =  $('#employer_address_attributes_state').val();
  zip =  $('#employer_address_attributes_zip').val();
  if (line1.length > 0 || city.length > 0 || state.length > 0 || zip.length > 0){
    if (city.length == 0){
      alert("Please enter city");
      return false;
    }
    if (state.length == 0){
      alert("Please select state");
      return false;
    }
  }
});
