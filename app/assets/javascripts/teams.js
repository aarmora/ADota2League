$(document).ready(function(){
	//Select2 isn't working and it really is needed to be able to search through the names
	//$('select').select2();
	another = $('#addplayers');
	$('.addplayer').on('change', function(){
		//Isn't firing for second select
		another.clone().removeAttr('id').appendTo($(this).closest('.form-horizontal'));
	});
});