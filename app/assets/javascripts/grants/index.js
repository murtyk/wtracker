$(document).ready(function() {
  var grant_ids = $('.page_data').data('grant-ids');
  $.each(grant_ids, function( index, value ){
    leftHeight = $('#left_' + value).height();
    rightHeight = $('#right_' + value).height();
    if (leftHeight < rightHeight){
      $('#left_' + value).css({'height':rightHeight});
    }
  });
});