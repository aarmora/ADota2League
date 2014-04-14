$(document).ready(function(){
	//Select2 isn't working and it really is needed to be able to search through the names
	//$('select').select2();
	another = $('#addplayers').clone();
	$(document).on('change', '.addplayer', function(){
		another.clone().removeAttr('id').appendTo($(this).closest('.form-horizontal'));
		$(this).closest('.form-group').find('.button').remove();
		//weird stuff happening if you select nothing
	});
});