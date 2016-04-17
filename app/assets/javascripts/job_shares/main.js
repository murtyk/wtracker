function send_to_trainees(job_share_id, trainee_ids) {
  var params = {job_share_id: job_share_id};
  var trainees_count = trainee_ids.length;
  var count = 0;
  var spliced_id, trainee_id;

  interval = setInterval(function()
  {
    spliced_id = trainee_ids.splice(0,1)
    if (spliced_id.length > 0){
      trainee_id = spliced_id[0];
    }
    else{
      trainee_id = -1
    }
    if (trainee_id > -1){
      params["trainee_id"] = trainee_id;
      $.get("/job_shares/send_to_trainee", params, function(data)
      {
        console.log(data["message"]);
        count = count + 1;
        $('.bar').width((100 * count /trainees_count) + "%");
        if (count == trainees_count){
          location.href = "/job_shares/" + job_share_id;
        }
      }, "json")
      .fail(function(jqXHR, textStatus, errorThrown)
      {
        alert("error in send_to_trainees js = " + errorThrown);
      });
    }
    else{
      clearInterval(interval);
    }
  }, 300);
}

function process_submit() {
  var count = $('#select_trainees option:selected').length;
  if (count == 0){
    alert("Please select at least one trainee");
    return false;
  }
  var selected_options = $('#select_trainees').val();
  var all_index = jQuery.inArray("0", selected_options); // "0" is the index for All option

  if (all_index > -1) {
    selected_options = $.map($('#select_trainees option'), function(ele) { return ele.value; });
    all_index = jQuery.inArray("0", selected_options);
    selected_options.splice(all_index, 1); //remove the '0'
  }

  job_info['comment'] = $('#job_share_comment').val();
  $("#pleaseWaitDialog").modal();
  $.post("/job_shares", {job_share: job_info, job_ids: job_ids}, function(data)
  {
    send_to_trainees(data["job_share_id"], selected_options);
  }, "json")
  .fail(function(jqXHR, textStatus, errorThrown)
  {
    alert("error in process_submit js");
  });
  return false;
}

var job_info, job_ids;

function trigger_klass_change(){
  console.log("in trigger_klass_change");
  job_info = $('#page_data').data('job-info');
  job_ids = $('#page_data').data('job-ids');

  var klass_id = $('#select_klass :selected').val();
  if (klass_id > 0){
    $('#select_klass').change();
  }
}

function trigger_klass_map_change(){
  job_info = $('#page_data').data('job-info');
  job_ids = $('#page_data').data('job-ids');

  var klass_id = $('#select_klass_gmap :selected').val();
  if (klass_id > 0){
    $('#select_klass_gmap').change();
  }
}

var employer_marker, markers_array;
function replaceMarkers(){
  if (Gmaps.map) {
    if (!employer_marker){
      employer_marker = Gmaps.map.markers[0];
    }
    else{
      markers_array = [];
      markers_array[0] = employer_marker;
      Gmaps.map.replaceMarkers(markers_array);
      Gmaps.map.replaceMarkers([{"lat": employer_marker.lat, "lng": employer_marker.lng, "name": employer_marker.name, "title": employer_marker.title}]);
    }
  }
}

$(document).on('change', '#select_klass_gmap', function() {
  console.log("new multiple select klass change");
  var klass_id;

  replaceMarkers();

  klass_id = $('#select_klass_gmap :selected').val();
  $.ajax({
        url: "/klasses/" + klass_id + "/trainees?markers=true",
        beforeSend: function(xhr, settings) {
          xhr.setRequestHeader('accept', "text/javascript");
          }
        });
});

$(document).on('change', '#select_klass', function() {
  var klass_id = $('#select_klass :selected').val();
  if (klass_id == ""){
    $('#select_trainees').html('<option value=""></option>');
  }
  else{
    jQuery.ajaxSetup({async:false});
    $.ajax({
          url: "/klasses/" + klass_id + "/trainees",
          beforeSend: function(xhr, settings) {
            xhr.setRequestHeader('accept', "text/javascript");
            }
          });
    jQuery.ajaxSetup({async:true});
  }
});

$(document).ready(function() {
  var trainee_id = $('.page_data').data('trainee-id');
  $('#select_klass').change();
  $('#select_klass_map').change();
  if (trainee_id > 0){
    $('#select_trainees').val(trainee_id);
  }
});

$(document).ready(function () {
  $('#new_job_share').submit(function(e){
    e.preventDefault();
    process_submit();
    return false;
  });
});

