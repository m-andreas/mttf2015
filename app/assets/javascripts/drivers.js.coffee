# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#drivers').DataTable({
    responsive: false
  });
  $('#driver_date_of_birth').datepicker
    dateFormat: 'yy-mm-dd'
  $('#driver_entry_date').datepicker
    dateFormat: 'yy-mm-dd'
  $('#driver_exit_date').datepicker
    dateFormat: 'yy-mm-dd'
  $(document).ready(ready)
  $(document).on('page:load', ready)


ready = ->
  $('#drivers-table').DataTable({
    responsive: false,
    columnDefs: [ {
          targets: 'no-sort',
          orderable: false,
    } ]
  });