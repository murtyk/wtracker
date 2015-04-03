function bind_datepicker(){
  $('[data-behaviour~=datepicker]').datepicker({"format": "mm/dd/yyyy", "weekStart": 1, "autoclose": true});
}
$(document).ready(function() {
  bind_datepicker();
});

