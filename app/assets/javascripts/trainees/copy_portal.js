jQuery(function($){
  $("#trainee_dob").mask("99/99/9999",{placeholder:"mm/dd/yyyy"});
  $("#trainee_trainee_id").mask("999-99-9999");
});

function control_div_for(id){
  return $('#'+id).parents('.control-group')[0];
}

function highlight_error(id){
  var $div = control_div_for(id);
  $($div).addClass("error");
}

function remove_highlight(id){
  var $div = control_div_for(id);
  $($div).removeClass("error");
}

function check_file_input(id, extensions){
  var txt = $('#' + id).val();
  if (txt == ''){
    return false;
  }
  var ext = txt.match(/\.([^\.]+)$/)[1];

  if ($.inArray(ext, extensions) == -1){ return false; }
  return true;
}

$('#trainee_files_form').submit(function() {
  var ids = [
        'trainee_file_file',
        'trainee_trainee_files_attributes_0_file',
        'trainee_trainee_files_attributes_1_file'];

  var valid_file = false;

  for (i = 0; i < ids.length; ++i) {
    if (document.getElementById(ids[i])) {
      remove_highlight(ids[i]);
      valid_file = check_file_input(ids[i], ['pdf', 'docx', 'doc']);
      if(!valid_file){
        highlight_error(ids[i]);
        alert('Please select a file with extensions either pdf, docx or doc');
        return false;
      }
    }
  }
});
