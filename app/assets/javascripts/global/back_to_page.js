$(document).ready(function () {
  $('.table_freeze_header').each(function (index){
    $(this).freezeHeader();
  });
});

$(document).ready(function() {
  var offset = 250;
  var duration = 300;

  $(window).scroll(function() {
    if (jQuery(this).scrollTop() > offset) {
      $(".back-to-top").fadeIn(duration);
    } else {
      $(".back-to-top").fadeOut(duration);
    }
  });

  $(".back-to-top").click(function(event) {
      event.preventDefault();
      $("html, body").animate({scrollTop: 0}, duration);

      return false;

  });
});
