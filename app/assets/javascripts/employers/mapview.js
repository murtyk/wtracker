$('.form-search').submit(function() {
  var counties_count, sector_id, name;
  counties_count = $('#filters_county_ids option:selected').length;
  sector_id = $('#filters_sector_id :selected').text();
  name = $('#filters_name').val();
  if (name == '' && sector_id == 0 && counties_count == 0){
    alert("Please select a county and/or a sector. OR enter name.");
    return false;
  }
  $('#submit-button').button('loading');
});

$('#help-button').click(function() {
  $('#helpModal').modal();
});

$('#clear-button').click(function() {
  $('#filters_name').val('');
  $('#filters_sector_id').val('');
  $('#filters_klass_id').val('');
  $("#filters_county_ids").val([]);
});

$('.btn-spinner').button();

function attachPolygonInfoWindow(polygon, html)
{
  polygon.infoWindow = new google.maps.InfoWindow({
    content: html
  });

  google.maps.event.addListener(polygon, 'click', function(e){
    var latLng = e.latLng;
    console.log(latLng);
    this.setOptions({fillOpacity:0.3, strokeColor: "#F00"});
    polygon.infoWindow.setPosition(latLng);
    polygon.infoWindow.open(Gmaps.map.serviceObject);
  });

  google.maps.event.addListener(polygon, 'mouseout', function() {
    this.setOptions({fillOpacity:0.15, strokeColor: "#383838"});
    polygon.infoWindow.close();
  });
}

$(document).ready(function() {
  Gmaps.map.callback = function(){
    var c, county_polygons, county_names, county_count, polygon;

    console.log("map callback");
    console.log(Gmaps.map.polygons.length);

    county_polygons  = $('.page_data').data('county-polygons');
    county_names  = $('.page_data').data('county-names');
    county_count = county_polygons.length;

    for (c = 0; c < county_count; c++)
    {
      polygon = Gmaps.map.create_polygon(county_polygons[c]);
      polygon.setOptions({clickable: true, fillColor: "#88F",strokeColor: "#383838",fillOpacity: 0.15, strokeWeight: 1});
      // alert(county_names[c]);
      attachPolygonInfoWindow(polygon, '<div style="width: 100px;"><strong>' + county_names[c] + '</strong></div>');
    }
  }
});
