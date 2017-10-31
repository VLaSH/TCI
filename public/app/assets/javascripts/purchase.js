/* Auto-submit the form on load */
Event.observe(window, 'load', function() {
  $('purchase_form').submit();
});