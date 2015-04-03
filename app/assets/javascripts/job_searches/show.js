//= require ./new_or_show.js

var total_slices_count = $('#page_data').data('slices');
var job_search_id = $('#page_data').data('job-search-id');
var page_position = $('#page_data').data('page-position');
var process_in_state = $('#page_data').data('in-state');
var processes_count = $('#page_data').data('processes-count');

var name_locations;
var companies_count;
var google_places_count = 0;

if (page_position == 'first'){
  $('#prev-button').attr('disabled', true);
  $('#prev-button').prop('disabled', true);
}

if (page_position == 'last') {
  $('#next-button').attr('disabled', true);
  $('#next-button').prop('disabled', true);
}

$(window).load(function() {
  // perform search and filter in state for each slice
  var count;
  var slice = 1;

  if (process_in_state){
    process_in_state = false;
  }
  else{
    return;
  }

  // var $bar = $('.bar');
  $("#pleaseWaitDialog").modal();
  $("#modal_title").html('Searching and filtering jobs within the state');
  interval = setInterval(function(){
    count = 1
    while (count < 4 && slice <= total_slices_count)
    {
      console.log("search and filter request for slice = ", slice);
      $.get("/job_searches/search_and_filter_in_state", {slice: slice, job_search_id: job_search_id }, function(data) {
        in_state_slice_searched(data);
      }, "json")
      .fail(function(jqXHR, textStatus, errorThrown){
        alert("error in search and filter by state");
      });

      slice += 1;
      count += 1;
    }

    if (slice > total_slices_count) {
      clearInterval(interval);
    }
  }, 20);
});

$('#analyze_all').click(function(){
  var count, slice;
  // first check if analysis exists
  $.get("/job_searches/analysis_present", { job_search_id: job_search_id }, function(data) {

    if (data == null || data == false) {
      slice = 1;
      // var $bar = $('.bar');

      $("#pleaseWaitDialog").modal();

      interval = setInterval(function(){
        count = 1
        while (count < 4 && slice <= total_slices_count) {
          console.log("analyze request for slice = ", slice);
          $.get("/job_searches/analyze_slice", { slice: slice, job_search_id: job_search_id }, function(data) {
          }, "script")
          .fail(function(jqXHR, textStatus, errorThrown){
            alert('error in analyzing job search id = ' + job_search_id + ' slice = ' + slice + ' ' + errorThrown);
          });

          slice += 1;
          count += 1;
        }

        if (slice > total_slices_count) {
          clearInterval(interval);
        }
      }, 20);
    }
    else {
      location.href = '/job_searches/' + job_search_id + '/analyze';
    }
  }, "json");
});

function complete_analysis() {
  console.log('complete_analysis');
  $('.bar').width("95%");
  $.get("/job_searches/complete_analysis", { job_search_id: job_search_id }, function(data) {
  }, "script");
}

function sort_if_complete() {
  console.log("google_places_count = " + google_places_count)
  if (companies_count == google_places_count) {
    $('.bar').width("98%");
    console.log('calling sort and filter');
    location.href = "/job_searches/sort_and_filter/?id=" + job_search_id + "&in_state=1";
  }
}

function status_update() {
  google_places_count += 1;
  percent_complete = (95 * google_places_count) / companies_count;
  $('.bar').width(percent_complete + '%');
  sort_if_complete();
}

function get_all_google_companies(){
  var count;
  var delay = 400;
  var concurrent_places_searches = 3;

  $("#modal_title").html('Fetching information on Companies.');
  $('.bar').width('0%');
  console.log("in get-all-google-places click");

  $.get("/job_searches/google_places_cache_check_and_start", {job_search_id: job_search_id }, function(data) {
    if (data){
      delay = 20;
    }
  });

  if (processes_count > 3) {
    concurrent_places_searches = processes_count - 1;
  }
  // big assumption: server engine processes requests in fifo and the cache check returns in less than 400ms, so we don't need any wait mechanism. we need to analyze this for multi-processor
  // var $bar = $('.bar');

  $("#pleaseWaitDialog").modal();

  interval = setInterval(function(){
    count = 1
    console.log("delay = ", delay);
    while (count <= concurrent_places_searches && name_locations.length > 0) {
      name_location = name_locations.splice(0, 1)[0];
      $.get("/employers/get_google_company", { name_location: name_location }, function(data) {
      })
      .always(function(){
        status_update();
      });
      count += 1;
    }
    if (name_locations.length === 0) {
     clearInterval(interval);
    }
  }, delay);

};

function complete_search_and_filter_in_state() {
  $('.bar').width('95%');
  location.href = '/job_searches/' + job_search_id;
}

function in_state_slice_searched(slice) {
  $('#slices_searched_and_filtered_in_state').append($('<option></option>').val(slice).html(slice));
  var count = $('#slices_searched_and_filtered_in_state option').size();
  console.log("searched_and_filtered_in_state_slices_count = ", count);
  $('.bar').width((80 * count / total_slices_count) + "%");
  if (count == total_slices_count){
    complete_search_and_filter_in_state();
  }
}
