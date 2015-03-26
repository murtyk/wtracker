$('.form-search').submit(function() {
  $('#submit-button').button('loading');
});
$('.new_trainee_email').submit(function() {
  var subject, content;
  subject = $('#trainee_email_subject').val();
  if (subject.length < 5){
    alert('subject should be minimum 5 characters');
    return false;
  }
  content = $('#trainee_email_content').val();
  if (content.length < 5){
    alert('content should be minimum 5 characters');
    return false;
  }
});
