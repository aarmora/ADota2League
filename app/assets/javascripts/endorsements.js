$(document).ready(function() {
	// bind click handler
	$(".js-endorsement").on("click", function() {
		// Prevent overloading the server
		if ($(this).is(".js-pending")) return;
		$(this).addClass("js-pending");

		$.post(
			"/players/" + $(this).data("user-id") + "/endorse.json",
			{ endorse: ($(this).is(".endorsed") ? 0 : 1) },
			function(data) {
				$(this).toggleClass("endorsed", data.endorsed);
			}.bind(this)
		).fail(function() {
			// TODO: Make this a global AJAX handler
		   alert("Sorry there was an error, please try again later");
		}).always(function() {
		    $(this).removeClass("js-pending");
		}.bind(this));
	});
});