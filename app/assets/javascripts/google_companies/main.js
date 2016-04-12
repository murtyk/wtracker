$(document).ready(function () {
  $('#form_google_companies').submit(function() {
    var name, near;
    name = $('#filters_name').val();
    if (name == ''){
      alert("Please enter name");
      return false;
    }
    near = $('#filters_location').val();
    if (near == ''){
      alert("Please enter location");
      return false;
    }
  });
});
