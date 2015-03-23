// Google analytics related custom code

$(document).ready(function() {
  if (RAILS_ENV == "production") {
    // Add a view event for the user looking at this tab
    $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
      var tabName = e.target.href.split("#")[1];
      ga('send', 'pageview', window.location.pathname + '/' + tabName);
    });

    $('#sponsors').on('click', 'a', function(e) {
      var adName = $(this).data("campaign-id");
      ga('send', 'event', 'ads', 'click', adName);
    });
  }
  ga('require', 'ecommerce');
});