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

$('#new_job_share').submit(function(e){
  e.preventDefault();
  process_submit();
  return false;
});

$(window).load(function() {
  job_info = $('.page_data').data('job-info');
  job_ids = $('.page_data').data('job-ids');

  var klass_id = $('#select_klass :selected').val();
  if (klass_id > 0){
    $('#select_klass').change();
  }
});
