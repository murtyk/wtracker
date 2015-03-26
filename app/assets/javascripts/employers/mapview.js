$('.form-search').submit(function() {
  var counties_count, sector_id, name;
  counties_count = $('#filters_county_ids option:selected').length;
  sector_id = $('#filters_sector_id :selected').text();
  name = $('#filters_name').val();
  if (name == '' && sector_id == 0 && counties_count == 0){
    alert("Please select a county and/or a sector. OR enter name.");
    return false;
  }
  $('#submit-button').button('loading');
});

$('#help-button').click(function() {
  $('#helpModal').modal();
});

$('#clear-button').click(function() {
  $('#filters_name').val('');
  $('#filters_sector_id').val('');
  $('#filters_klass_id').val('');
  $("#filters_county_ids").val([]);
});

$('.btn-spinner').button();

function CustomMethodToExport(tblId){

  var html;
  var trhtml = "";
  var gTable = document.getElementById(tblId);
  var numofRows = gTable.rows.length-1;
  var numofCells =  gTable.rows[0].cells.length-1  ;

  var c, tdhtml, node, tokens, job_search_id, company_num, checkbox_id, titles;
  for ( r = 0; r <= numofRows; r++)
  {
    c =0;
    tdhtml =  "" ;

    for (c = 0; c<=numofCells; c++)
    {
      node = gTable.rows[r].cells[c].childNodes[1];
      if (node != null && node.nodeName == 'OL')
      {
        tokens = node.id.split('_');
        job_search_id = tokens[1];
        company_num = tokens[2];
        checkbox_id = job_search_id + ':' + company_num
        titles = '';
        $("input[type='checkbox'][id*='" + checkbox_id + "']").each(function(){
          titles += '<li>' + this.name + '</li>';
        });
        tdhtml = tdhtml + "<td><ol>" + titles + "</ol></td>";
      }
      else if(gTable.rows[r].cells[c].childNodes[0].nodeName == 'A')
      {
        tdhtml = tdhtml + '<td>' + gTable.rows[r].cells[c].textContent + '</td>'
      }
      else
      {
        if(gTable.rows[r].cells[c].innerHTML.indexOf("Add</a>") != -1)
        {
          tdhtml = tdhtml + "<td></td>";
        }
        else
        {
          tdhtml = tdhtml + gTable.rows[r].cells[c].outerHTML;
        }
      }
    }

    trhtml = trhtml + "<tr>" + tdhtml + "</tr>";
  }

  html = "<table border='1'>"+trhtml+"</table>";

      // MS OFFICE 2003  : data:application/vnd.ms-excel
      window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));

      // MS OFFICE 2007  : application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      // window.open('data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' + encodeURIComponent(html));
}

$('#btnExport').click(function(e){
  // window.open('data:application/vnd.ms-excel,' + encodeURIComponent($('#dvData').html()));
  CustomMethodToExport("companies-table");
  e.preventDefault();
});

function attachPolygonInfoWindow(polygon, html)
{
  polygon.infoWindow = new google.maps.InfoWindow({
    content: html
  });

  google.maps.event.addListener(polygon, 'click', function(e){
    var latLng = e.latLng;
    console.log(latLng);
    this.setOptions({fillOpacity:0.3, strokeColor: "#F00"});
    polygon.infoWindow.setPosition(latLng);
    polygon.infoWindow.open(Gmaps.map.serviceObject);
  });

  google.maps.event.addListener(polygon, 'mouseout', function() {
    this.setOptions({fillOpacity:0.15, strokeColor: "#383838"});
    polygon.infoWindow.close();
  });
}
