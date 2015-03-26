$('#select_klass_id').change(function(e) {
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

var attachment_number = 1;
$('#new_attachment').click(function() {
  $.ajax({
      url: "/emails/new_attachment?number=" + attachment_number,
      beforeSend: function(xhr, settings){
        xhr.setRequestHeader('accept', "text/javascript");
      }
  });
  attachment_number = attachment_number + 1;
});

$(".simple_form").submit(function(e){
  var count = 0;
  var file_ids = [];
  var checkbox_id = 'tf_';

  $("input[type='checkbox'][id*='" + checkbox_id + "']:checked").each(function() {
    id = this.id.split('_')[1];
    file_ids.push(id);
  });
  // alert(file_ids);
  if (file_ids.length > 0){
    $('#email_trainee_file_ids').val(file_ids.join(':'));
  }

  $('#email_contact_ids option').prop('selected', true);
  count = $('#email_contact_ids option:selected').length;
  if (count == 0){
    alert("Please add at least one employer contact");
    return false;
  }
});

$("#button-getcontacts").click(function(e){
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

$("#add-selected-contacts").click(function(){
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

$("#remove-selected-contacts").click(function(){
   $("#email_contact_ids option:selected").remove();
});

var tf_ids = [];

function check_check_boxes() {
  tf_ids.forEach(function(tf_id) {
    id = '#tf_' + tf_id;
    console.log(id);
    $(id).prop('checked', 'true');
  });
  tf_ids = [];
}

$(document).ready(function() {
  var klass_id = $('.page_data').data('klass-id');
  tf_ids = $('.page_data').data('tf-ids');
  if (klass_id > 0 && tf_ids.length > 0){
    $('[name=select_klass_id]').val(klass_id);
    $('#select_klass_id').trigger('change');
  }
});