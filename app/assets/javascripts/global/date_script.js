function bind_datepicker(){
  $('[data-behaviour~=datepicker]').datepicker({"format": "mm/dd/yyyy", "weekStart": 1, "autoclose": true});
}

$(document).ready(function() {
  bind_datepicker();

  $(".date_field").each(function( index ) {
    $(this).mask("99/99/9999",{placeholder:"mm/dd/yyyy"});
  });
});

$(document).on("blur", ".date_field", function() {
  var date_string = $(this).val();
  var required = $(this).attr("required") == "required";

  var valid = is_valid_date(date_string, required);

  $(this).css({backgroundColor: ''});

  if (!valid){
    if (required || date_string.length > 0){
      $(this).css({backgroundColor: 'yellow'});
      $(this)[0].focus();
    }
  }
});

function is_valid_date_format(date_string){
  var validformat = /^\d{2}\/\d{2}\/\d{4}$/; //Basic check for format validity
  return validformat.test(date_string);
}

function is_valid_date(date_string, is_required){
  is_required = (typeof is_required === 'undefined') ? false : is_required;

  if (is_required && date_string.length == 0){
    alert("Date is required.");
    return false;
  }

  if (date_string.length == 0){
    return false;
  }

  if (!is_valid_date_format(date_string)){
    console.log(date_string);
    alert("Date is not valid.");
    return false;
  }

  var parts = date_string.split("/");
  var month = parts[0];
  var day = parts[1];
  var year = parts[2];

  var date_obj = new Date(year, month-1, day);

  var is_valid = ( (date_obj.getMonth() + 1) == month || date_obj.getDate() == day || date_obj.getFullYear() == year);

  if (is_valid){
    return true;
  } else {
    alert("Date is invalid!");
    return false;
  }
}
