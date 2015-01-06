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
	$("#part_start_date_s").datepicker({dateFormat: 'yy-mm-dd'});
    $("#part_end_date_s").datepicker({dateFormat: 'yy-mm-dd'});
});