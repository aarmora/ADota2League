$(function() {
  $('#datatable').dataTable({
  	"sPaginationType": "bootstrap",
  	"iDisplayLength": 25,
  	"aaSorting": [[ 4, "desc" ]]
	});
	$("form").bind('ajax:complete', function(data){
		//This is a hack.  Not sure of a better way to do it.
		$.get('/player_comments_partial', {player_id:$('#player_id').val()}, function(data){
			$('#player_comments_partial').html(data);
			$('textarea').val("");
			deleteComment();
		});	
	});
	deleteComment();
});
function deleteComment(){
	$('.delete').on('click', function(){
		var $this = $(this)
		$.post('/player_comment_delete', {comment_id:$(this).attr('commentid')}, function(){
			$($this).closest('blockquote').remove();
		});
	});
};