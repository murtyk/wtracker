//= require ./new_or_show.js
var google_places_count = 0;

function initialize_in_state(){
  var page_position = $('#page_data').data('page-position');

  google_places_count = 0;

  if (page_position == 'first'){
    $('#prev-button').attr('disabled', true);
    $('#prev-button').prop('disabled', true);
  }

  if (page_position == 'last') {
    $('#next-button').attr('disabled', true);
    $('#next-button').prop('disabled', true);
  }
}

function perform_in_state(){
  // perform search and filter in state for each slice
  initialize_in_state();

  var count;
  var slice = 1;
  var process_in_state = $('#page_data').data('in-state');
  var total_slices_count = $('#page_data').data('slices');
  var job_search_id = $('#page_data').data('job-search-id');

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
}

$(document).on('click', '#analyze_all', function(event){
  var count, slice;
  var job_search_id = $('#page_data').data('job-search-id');
  var total_slices_count = $('#page_data').data('slices');

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
  var job_search_id = $('#page_data').data('job-search-id');

  console.log('complete_analysis');
  $('.bar').width("95%");
  $.get("/job_searches/complete_analysis", { job_search_id: job_search_id }, function(data) {
  }, "script");
}

function sort_if_complete(companies_count) {
  var job_search_id = $('#page_data').data('job-search-id');

  if (companies_count == google_places_count) {
    $('.bar').width("98%");
    console.log('calling sort and filter. job_search_id = ' + job_search_id);
    location.href = "/job_searches/sort_and_filter/?id=" + job_search_id + "&in_state=1";
  }
}

function status_update(companies_count) {
  google_places_count += 1;
  percent_complete = (95 * google_places_count) / companies_count;
  $('.bar').width(percent_complete + '%');
  sort_if_complete(companies_count);
}

function get_all_google_companies(name_locations){
console.log("in get_all_google_companies");
console.log("name_locations count = " + name_locations.length);
  var count;
  var delay = 400;
  var concurrent_places_searches = 3;
  var job_search_id = $('#page_data').data('job-search-id');

  var processes_count = $('#page_data').data('processes-count');
  var companies_count = name_locations.length;


  $("#modal_title").html('Fetching information on Companies.');
  $('.bar').width('0%');

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
        status_update(companies_count);
      });
      count += 1;
    }
    if (name_locations.length === 0) {
     clearInterval(interval);
    }
  }, delay);
}

function complete_search_and_filter_in_state() {
  var job_search_id = $('#page_data').data('job-search-id');

  $('.bar').width('95%');
  location.href = '/job_searches/' + job_search_id;
}

function in_state_slice_searched(slice) {
  var total_slices_count = $('#page_data').data('slices');

  $('#slices_searched_and_filtered_in_state').append($('<option></option>').val(slice).html(slice));
  var count = $('#slices_searched_and_filtered_in_state option').size();
  console.log("searched_and_filtered_in_state_slices_count = ", count);
  $('.bar').width((80 * count / total_slices_count) + "%");
  if (count == total_slices_count){
    complete_search_and_filter_in_state();
  }
}

$(document).on('click', '.add-company-link', function(event){
console.log('.add-company-link  clicked');
  var count = $('#sector_ids option:selected').length;
  if (count == 0){
    alert("Please select at least one sector");
    return false;
  }
  var sector_ids = $('#sector_ids').val();
  var job_search_id = $('#job_search_id').val();
  var url = $(this).attr('href');
  var info_index = url.indexOf("&info");
  var url_part1 = url.substring(0, info_index);
  var url_part2 = url.substring(info_index);
  var url_with_sectors = url_part1 + "&sector_ids=" + sector_ids + "&job_search_id=" + job_search_id + url_part2;

  $.post(url_with_sectors, {}, function(data){
  }, "script")
  .fail(function(jqXHR, textStatus, errorThrown){
    console.log(errorThrown);
  });

  return false;
});

$(document).on('click', '#import-from-google', function(event) {
  var count = $('#sector_ids option:selected').length;
  if (count == 0){
    alert("Please select at least one sector");
    return false;
  }
  var links = $(".add-company-link");
  interval = setInterval(function(){
    var link = $(links.splice(0, 1));
    console.log("Clicking:", link);
    link.click();
    if (links.length === 0) {
      clearInterval(interval);
    }
  }, 200);
});

$(document).on('click', '#filter-button', function(event){
  var url;
  if ($('#county_ids').val() == null){
    alert("Please select at least one county");
    return false;
  }
  url = $(this).attr('href');
  url += "&county_ids=" + $('#county_ids').val();
  $(this).attr('href', url);
});


$(document).on('click', '.btn-share', function(e){
  var id = this.id;
  var tokens = id.split('_');
  var job_search_id = tokens[1];
  var company_num = tokens[2];
  // alert(job_search_id);
  // alert(company_num);
  var checkbox_id = job_search_id + ':' + company_num + ':'

  var job_ids =
    $("input[type='checkbox'][id*='" + checkbox_id + "']:checked").map(function(){
      return $(this).val();
    }).get();

  console.log(job_ids);

  if (job_ids.length == 0){
    alert('check the titles and click share');
    return false;
  }

  var href = "/job_shares/new_multiple?job_ids=" + encodeURIComponent(job_ids);
  jQuery.ajaxSetup({async:false});
  $.get("/job_shares/company_status", {job_id: job_ids[0]}, function(status) {

    // -1: name/location blank so no search
    //  0: not searched,
    //  1: not found
    //  2: found but not added
    //  3: found and added
    if (status == 0){
      alert('Please search google places before sharing jobs');
    }
    else if (status == 2){
      alert('Please add employer before sharing jobs');
    }
    else{
      window.open(href, '_blank');
    }
  });
  jQuery.ajaxSetup({async:true});

});
