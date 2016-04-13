var globalTraineeFileIds = []; //trainee file ids gets set when document ready
var globalAttachmentNumber = 1;

$(document).ready(function() {
  var klass_id = $('.page_data').data('klass-id');
  if (klass_id == null){
    return;
  }
  globalTraineeFileIds = $('.page_data').data('tf-ids');
  if (globalTraineeFileIds != null && klass_id > 0 && globalTraineeFileIds.length > 0){
    $('[name=select_klass_id]').val(klass_id);
    $('#select_klass_id').trigger('change');
  }
});

$(document).on("click", "#add-selected-contacts", function(e){
  var str = '';
  var e_option;
   $( "#select_contacts option:selected" ).each(function() {
      e_option = $(this);
      if ($("#email_contact_ids option[value="+e_option.val()+"]").length == 0){
        $("#email_contact_ids").append($('<option></option>').val(e_option.val()).html(e_option.text()));
      }
      str += $( this ).text() + " ";
    });
   // alert(str);
});

$(document).on("click", "#button-getcontacts", function(e){
  var sector_id = $('#sector_id :selected').val();
  var county_id = $('#county_id :selected').val();
  var name = $('#name').val();

  if (sector_id == 0 & county_id == 0 & name == 0){
    alert("Please select a sector or county. Or enter employer name to search");
    return false;
  }

  $.get("/employers/contacts_search", {filters: {county_id: county_id, sector_id: sector_id, name: name}}, function(data) {
        populateDropdown($("#select_contacts"), data);
  }, "json");

  e.preventDefault();
});

$(document).on('click', '#new_attachment', function(e) {
  $.ajax({
      url: "/emails/new_attachment?number=" + globalAttachmentNumber,
      beforeSend: function(xhr, settings){
        xhr.setRequestHeader('accept', "text/javascript");
      }
  });
  globalAttachmentNumber = globalAttachmentNumber + 1;
});

/*
  when user selects a klass, fetch the trainee and their documents through ajax request
  the js returned by the ajax request show each trainee and checkboxes for each of their
  documents.

  call check_check_boxes to select all the documents by default
*/
$(document).on('change', '#select_klass_id', function(e) {
  var klass_id = $('#select_klass_id :selected').val();
  $('#email_klass_id').val(klass_id);
  if (klass_id > 0){
    $.get("/trainees/docs_for_selection?klass_id=" + klass_id, function(data) {
      check_check_boxes();
    }, "script");
    e.preventDefault();
  }
  else{
    $("#trainees_documents_id").html('');
  }
});

$(document).on('click', "#remove-selected-contacts", function(e){
   $("#email_contact_ids option:selected").remove();
});

$(document).ready(function () {
  $("#new_email").submit(function(e){
    var count = 0;
    var checkbox_id = 'tf_';

    var checkboxes = $("input[type='checkbox'][id*='" + checkbox_id + "']:checked");
    var file_ids = $.map(checkboxes, function(cb, i){ return cb.id.split('_')[1]; } );

    if (file_ids.length > 0){
      $('#email_trainee_file_ids').val(file_ids.join(':'));
    }

    $('#email_contact_ids option').prop('selected', true);

    count = $('#email_contact_ids option:selected').length;
    if (count == 0){
      alert("Please add at least one employer contact");
      return false;
    }

    var s = $('#email_subject').val();
    if (s.length < 5){
      alert('Subject should be minimum of 5 characters');
      return false;
    }

    s = $('#email_content').val();
    if (s.length < 5){
      alert('Content should be minimum of 5 characters');
      return false;
    }
  });
});

function check_check_boxes() {
  var id;
  globalTraineeFileIds.forEach(function(tf_id) {
    id = '#tf_' + tf_id;
    console.log(id);
    $(id).prop('checked', 'true');
  });
  globalTraineeFileIds = [];
}
