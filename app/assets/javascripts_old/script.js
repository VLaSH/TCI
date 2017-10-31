// JavaScript Document
	jQuery(document).ready(function() {
		<!-- Js for Menu -->
		jQuery(".toggle_menu a").click(function () {
			jQuery(".nav").slideToggle("fast");
			});


		<!-- Js for BXSLIDER -->
		$('.bxslider').bxSlider({
			captions: true,
			auto:false,
			controls:false,				
			pager: false,			
		});

		
	});	
