$('#applicant_source').change(function() {
  source_text = $('#applicant_source :selected').text();
  if (source_text == 'Other, Please specify'){
    other_source = ''
    while(other_source == ''){
      other_source = prompt("Please specify", "");
    }
    existing_other_source = $("#applicant_source option[value=" + other_source + "]").text();
    if (existing_other_source == ''){
      $("#applicant_source").append(new Option(other_source, other_source));
    }
    $("#applicant_source").val(other_source);
  }
});
$('#applicant_current_employment_status').change(function() {
  status = $('#applicant_current_employment_status :selected').text();
  if (status == 'Other, Please specify'){
    other_status = ''
    while(other_status == ''){
      other_status = prompt("Please enter current employment status", "");
    }
    existing_other_status = $("#applicant_current_employment_status option[value=" + other_status + "]").text();
    if (existing_other_status == ''){
      $("#applicant_current_employment_status").append(new Option(other_status, other_status));
    }
    $("#applicant_current_employment_status").val(other_status);
  }
});
