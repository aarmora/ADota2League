$(function() {
  $('table').dataTable({
  	"sPaginationType": "bootstrap",
  	"iDisplayLength": 25,
  	"aaSorting": [[ 4, "desc" ]]
	});
});