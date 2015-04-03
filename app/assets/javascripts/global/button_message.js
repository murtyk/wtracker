// Make sure the DOM is ready
$(function() {
  $('.btn-message').on('click', function() {
    message = $(this).attr('message');
    alert(message);
    e.preventDefault();
  });
})