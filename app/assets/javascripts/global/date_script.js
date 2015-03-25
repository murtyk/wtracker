$(document).ready(function() {
  // $.mask.definitions['~']='[+-]';
  $('[data-behaviour~=datepicker]').datepicker({"format": "mm/dd/yyyy", "weekStart": 1, "autoclose": true});
})
