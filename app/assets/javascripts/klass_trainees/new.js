// for adding trainees on klass page
$("form.new_klass_trainee").on('submit', function(e){
  var t_ids;
  var klass_page = $('#page_data').data('klass-page');
  console.log(klass_page);
  if(klass_page != null){
    t_ids = $('#klass_trainee_trainee_id :selected').text();
    if (t_ids == ""){
      alert("Please select trainees");
      return false;
    }
  }
});
