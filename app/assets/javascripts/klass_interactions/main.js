$(document).on('change', '#klass_interaction_klass_id', function(e){
  klass_interaction_klass_id_changed(e);
});

$(document).on('click', '#add_event', function(){
  $('#new_klass_event').show();
  $('#add_event').hide();
});

$(document).on('click', '#cancel_event', function(){
  $('#new_klass_event').hide();
  $('#add_event').show();
});

$(document).on('submit','form.new_klass_interaction',function(e){
  var valid_event = true,
      count = 0;
  if ($('#add_event').css("visibility") == "hidden" || $('#add_event').css('display') == "none"){
    // + button clicked and new event fields are visible
    valid_event =  validateNewEvent();
  }
  else{
    $("[name='klass_event[name]']").val("");
  }

  if(valid_event && $('#employer_sector_ids').length){
    count = $('#employer_sector_ids option:selected').length;
    if (count == 0){
      alert("Please select at least one sector");
      return false;
    }
  }
  return valid_event;
});

function populateEvents(select, data){
  var name = "";
  select.html('');
  $.each(data, function(id, option){
    select.append($('<option></option>').val(option.id).html(option.label));
  });
}

function trigger_klass_interaction_klass_change(){
  $('#klass_interaction_klass_id').trigger("change");
}

function klass_interaction_klass_id_changed(e){
  console.log("in klass_interaction_klass_id_changed");
  var klass_id;
  klass_id = $('#klass_interaction_klass_id :selected').val();

  if (klass_id > 0){
    $.get("/klasses/" + klass_id + "/events", function(data){
        populateEvents($("#klass_interaction_klass_event_id"), data);
      }, "json");

    e.preventDefault();
  }
  else{
    $("#klass_interaction_klass_event_id").html('');
  }
}
