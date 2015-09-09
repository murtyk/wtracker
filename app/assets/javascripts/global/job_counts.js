function refresh_job_counts(kt_ids) {
  $.each(kt_ids, function(index, value) {
    console.log( index + ": " + value );
    $.get("/klass_titles/"+ value +"/job_search_count", function(data) {
      console.log(data);
      $('#job_count_' + value).html('(' + data + ' as of now)');
    }, "json");
  });
}
