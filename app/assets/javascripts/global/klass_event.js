function validateNewEvent(){
  var name = $('#klass_event_name').val();
  var dt = $('#klass_event_event_date').val();

  if(name == "") {
    alert('enter event name');
    return false;
  }
  if(dt == "") {
    alert('enter event date');
    return false;
  }
  return true;
}
