$('#import-from-google').click(function() {
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

$('#filter-button').click(function (){
  var url;
  if ($('#county_ids').val() == null){
    alert("Please select at least one county");
    return false;
  }
  url = $(this).attr('href');
  url += "&county_ids=" + $('#county_ids').val();
  $(this).attr('href', url);
});

$('#companies-table').on('click','.add-company-link', function (){
  var count = $('#sector_ids option:selected').length;
  if (count == 0){
    alert("Please select at least one sector");
    return false;
  }
  var sector_ids = $('#sector_ids').val();
  var job_search_id = $('#job_search_id').val();
  var url = $(this).attr('href');
  var url_with_sectors = url + "&sector_ids=" + sector_ids + "&job_search_id=" + job_search_id
  $(this).attr('href', url_with_sectors);
});

$('#btnCustomExport').click(function(e){
  // window.open('data:application/vnd.ms-excel,' + encodeURIComponent($('#dvData').html()));
  CustomMethodToExport("companies-table");
  e.preventDefault();
});

$('.btn-share').click(function(e){
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