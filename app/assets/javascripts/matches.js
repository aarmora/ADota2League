$(document).ready(function(){
	$("form#new_matchcomment").bind('ajax:complete', function(data){
		//This is a hack.  Not sure of a better way to do it.
		$.get('/matchcommentspartial', {match_id:$('#matchcomment_match_id').val()}, function(data){
			$('#matchcommentspartial').html(data);
			$('textarea').val("");
			deleteComment();
		});
	});
	deleteComment();
});

function deleteComment(){
	$('.delete').on('click', function(){
		var $this = $(this)
		$.post('/matchcomment_delete', {comment_id:$(this).attr('commentid')}, function(){
			$($this).closest('blockquote').remove();
		});
	});
};