$('#form-import').submit(function() {
  var count = 0;

  if ($('#sector_ids_').length){
    count = $('#sector_ids_ option:selected').length;
    if (count == 0){
      alert("Please select at least one sector");
      return false;
    }
  }

  if ($('#file').val() == ""){
    alert("Please select a file");
    return false;
  }
  $('#submit-button').button('loading');
});
