$(document).on('change', '#user_role', function() {
  var current_role = $('#page_data').data('role');
  var new_role = $('#user_role :selected').val();

  if (current_role != new_role){
    if (current_role == 3){
      if (new_role == 4) {
        alert('This user will be removed as Navigator from assigned classes and will be assigned as Instructor to the same classes');
      }
      else {
        alert('This user will be removed as Navigator from assigned classes.');
      }
    }
    else if(current_role == 4){
      if (new_role == 3) {
        alert('This user will be removed as Instructor from assigned classes and will be assigned as Navigator to the same classes.');
      }
      else {
        alert('This user will be removed as Instructor from assigned classes.');
      }
    }
  }
  if (new_role == 3){
    $('#navigator_options').show();
    $('#navigator_is_admin').show();
  }
  else{
    $('#navigator_options').hide();
    $('#navigator_is_admin').hide();
  }
});
