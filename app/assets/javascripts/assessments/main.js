$(document).on('click', '#new_assessment_link', function(event) {
  $("#assessment_form").show();
  $('#new_assessment_link').hide();
});

$(document).on('click', '#cancel_assessment', function(event){
  closeAssessmentForm();
  event.preventDefault();
});

$(document).on('click', '#submit_assessment', function(event){
  event.preventDefault();
  addAssessment();
});

$(document).on('click', '.btn-delete-assessment', function(event){
  if (!confirm("Are you sure?")) {
    return false;
  }

  var assessment_id = $(this).data("assessmentId");
  var div_id = "#assessment_" + assessment_id;

  $.ajax({
     url: '/assessments/' + assessment_id,
     type: 'DELETE',
     dataType: 'json',
     data: { id: assessment_id},
     success: function (data, textStatus, xhr) {
      $(div_id).remove();
     },
     error: function (xhr, textStatus, errorThrown) {
      alert(errorThrown);
     }
  });

});

function cancelNewAssessment(){
  closeAssessmentForm();
}

function addAssessment(){
  var name   = $("#assessment_name").val();
  var url    = '/assessments';
  var params = { assessment: { name: name } };

  $.post(url, params, function(data){
    appendAssessment(data);
    closeAssessmentForm();
  }, "json")
  .fail(function(jqXHR, textStatus, errorThrown){
    errorfy_assessment_fields(jqXHR.responseJSON);
  });

  return false;
}

function closeAssessmentForm(){
  clearAssessmentErrors();
  $("#assessment_form").hide();
  $('#new_assessment_link').show();
};

function appendAssessment(data){
  var div = $("#assessment_id").clone();
  div.attr("id", "assessment_" + data.id);

  var para = div.find('p');
  para.append(data.name);

  var delete_btn = para.find('button');
  delete_btn.attr("id", "destroy_assessment_" + data.id + "_link");
  delete_btn.data("assessmentId", data.id);

  $("#assessments").append(div);
  div.show();
};

function errorfy_assessment_fields(data){
  var errorSpan;

  clearAssessmentErrors();

  if(data.name != null){
    $("div.assessment_name").addClass("error");

    errorSpan = '<span class="help-inline">' + data.name[0] + '</span>';
    $("#assessment_name").after(errorSpan);
  }
};

function clearAssessmentErrors(){
  $("div.assessment_name").removeClass("error");
  $("span").remove(".help-inline");
}
