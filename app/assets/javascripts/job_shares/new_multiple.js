//= require ./new_common.js
var employer_marker, markers_array;
$('#select_klass').change(function() {
  console.log("new multiple select klass change");
  var klass_id;
  if (Gmaps.map) {
    if (!employer_marker){
      employer_marker = Gmaps.map.markers[0];
    }
    else{
      markers_array = [];
      markers_array[0] = employer_marker;
      Gmaps.map.replaceMarkers(markers_array);
      Gmaps.map.replaceMarkers([{"lat":employer_marker.lat,"lng":employer_marker.lng,"name":employer_marker.name,"title":employer_marker.title}]);
    }
  }

  klass_id = $('#select_klass :selected').val();
  $.ajax({
        url: "/klasses/" + klass_id + "/trainees?markers=true",
        beforeSend: function(xhr, settings) {
          xhr.setRequestHeader('accept', "text/javascript");
          }
        });
});
