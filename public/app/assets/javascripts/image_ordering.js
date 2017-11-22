//= require jquery
//= require jquery-ui
//= require jquery_ujs
$(document).ready(function() {
  get_image_id();
  $( "#attachment_thumbnails" ).sortable({
    stop: function( event, ui ) {
      get_image_id();
    }
  });

});

// Get image id after rearrangment images

function get_image_id(){
  var order = [];
    $('#attachment_thumbnails li').each(function(n) {order.push($(this).attr('id').replace(/attachment_thumbnail_li_/, ''));
    });
    $('input[name="attachment_thumbnails"]').val(order);
}
