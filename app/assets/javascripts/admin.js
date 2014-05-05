
$('input.filter').on('keyup', function() {
    var rex = new RegExp($(this).val(), 'i');
    $('.searchable tr').hide();
    $('.searchable tr').filter(function() {
        return rex.test($(this).text());
    }).show();
});
$(document).ready(function(){
	$('#admin-data-table').dataTable({
    "bPaginate": false,
    "aaSorting": [[ 5, "asc" ]]
  });
  $('select').select2();
});