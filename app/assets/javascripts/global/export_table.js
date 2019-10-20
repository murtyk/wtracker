function ExportTable(tblId){
  var html;
  var trhtml = "";
  var gTable = document.getElementById(tblId);
  var numofRows = gTable.rows.length;
  var numofCells =  gTable.rows[0].cells.length;

  for ( r = 0; r < numofRows; r++)
  {
    var c =0;
    var tdhtml =  "" ;
    var node;

    for (c = 0; c < numofCells; c++)
    {
      if (gTable.rows[r].cells[c].childNodes.length == 0){
        tdhtml = tdhtml + '<td></td>';
        continue;
      }
      nodes = gTable.rows[r].cells[c].childNodes;
      cell_text = '';
      for (n = 0; n < nodes.length; n++)
      {
        cell_text = cell_text + nodes[n].textContent;
      }
      tdhtml = tdhtml + '<td>' + cell_text + '</td>';
    }
    trhtml = trhtml + "<tr>" + tdhtml + "</tr>";
  }

  html = "<table border='1'>"+trhtml+"</table>";

  // MS OFFICE 2003  : data:application/vnd.ms-excel
  window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));

  // MS OFFICE 2007  : application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  // window.open('data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' + encodeURIComponent(html));
}

function CustomMethodToExport(tblId){
  var html;
  var trhtml = "";
  var gTable = document.getElementById(tblId);
  var numofRows = gTable.rows.length-1;
  var numofCells =  gTable.rows[0].cells.length-1  ;

  var r, c, tdhtml, node_0, node, tokens, job_search_id, company_num, checkbox_id, titles;
  for (r = 0; r <= numofRows; r++) {
    c = 0;
    tdhtml =  "" ;

    for (c = 0; c <= numofCells; c++) {
      node_0 = gTable.rows[r].cells[c].childNodes[0]
      node = gTable.rows[r].cells[c].childNodes[1];
      if (node != null && node.nodeName == 'OL') {
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
      else if(node_0 != null && node_0.nodeName == 'A') {
        tdhtml = tdhtml + '<td>' + gTable.rows[r].cells[c].textContent + '</td>'
      }
      else {
        if(gTable.rows[r].cells[c].innerHTML.indexOf("Add</a>") != -1) {
          tdhtml = tdhtml + "<td></td>";
        }
        else {
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

// Make sure the DOM is ready
$(function() {
$('#btnExport').on('click', function(e){
  // window.open('data:application/vnd.ms-excel,' + encodeURIComponent($('#dvData').html()));

  console.log("Export Report");
  ExportTable("data-table");
  e.preventDefault();
});
});
