$('.form-search').submit(function() {
  var sector_id, county_ids, source, name;
  sector_id  = $('#filters_sector_id :selected').text();
  county_ids = $('#filters_county_ids :selected').text();
  source     = $('#filters_employer_source_id :selected').text();
  name       = $('#filters_name').val();
  if (sector_id == 0 && county_ids == 0 && source == 0 && name == ''){
    alert("Please select at least one of sector / county / source OR enter name");
    return false;
  }
  $('#submit-button').button('loading');
});
$('#help-button').click(function() {
  $('#helpModal').modal();
});
