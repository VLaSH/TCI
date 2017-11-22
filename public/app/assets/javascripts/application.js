// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require jquery
//= require jquery_ujs
//= require fancybox
//= require jquery.lightbox
//= require jquery-ui
//= require jquery.cycle.all


// JavaScript Document


$.noConflict();
jQuery(document).ready(function($) {

  $(".drop-button a").click(function () {
    $(".show_dropdown").slideToggle("fast");
  });

  $(".toggle_menu a").click(function () {
    $(".nav").slideToggle("fast");
  });

  $('a.lightview').lightBox();
  $('.fancybox-media').fancybox({
    openEffect  : 'none',
    closeEffect : 'none',
    helpers : {
      media : {}
    }
  });

  $('.cycle').cycle({
    fx: 'fade', sync: 1, timeout: 500, speed: $('#slide_speed').val()
  });

});

