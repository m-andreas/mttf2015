# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  $('#job_from_id').filterByText($('#from_filter'), true);
  $('#job_to_id').filterByText($('#to_filter'), true);
  $('#driver_id').filterByText($('#driver_filter'), true);