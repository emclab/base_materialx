// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function (){
	$('#part_category_id').change(function(){
      $('#part_field_changed').val('category_id');
      $.get(window.location, $('form').serialize(), null, "script");
  	  return false;
	});
});

$(function() {
	$("#start_date_s").datepicker({dateFormat: 'yy-mm-dd'});
    $("#end_date_s").datepicker({dateFormat: 'yy-mm-dd'});
});

$(function() {
  $(document).on('change', '#part_flag', function (){  //only document/'body' works with every change. 
  	$.get(window.location, {flag: $('#part_flag').val(), field_changed: 'flag'}, null, "script");
    return false;
  });
});