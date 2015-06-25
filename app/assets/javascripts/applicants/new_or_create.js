// This is a jquery function to extend all DOM elements
// but the intention is to use on select lists where user can specify Other option
$.fn.extend({
  capture_other: function(prompt_text){
    var s_text, other_text, existing_other_text;
    s_text = $(this).children(':selected').text();
    if (s_text == 'Other, Please specify'){
      other_text = ''
      while(other_text == ''){
        other_text = prompt(prompt_text, "");
      }
      existing_other_text = $(this).find('option[value=' + other_text + ']').text();
      if (existing_other_text == ''){
        $(this).append(new Option(other_text, other_text));
      }
      $(this).val(other_text);
    }
  }
});

$('#applicant_source').change(function() {
  $('#applicant_source').capture_other("Please specify");
});

$('#applicant_current_employment_status').change(function() {
  $("#applicant_current_employment_status").capture_other("Please enter current employment status");
});

jQuery(function($){
  $("#applicant_address_zip").mask("99999");
});

$('.btn-spinner').button();
$('.new_applicant').submit(function() {
  $('#submit-button').button('loading');
});
