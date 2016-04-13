$(document).on('click', '#btnCustomExport', function(e){
  // window.open('data:application/vnd.ms-excel,' + encodeURIComponent($('#dvData').html()));
  CustomMethodToExport("companies-table");
  e.preventDefault();
});
