# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#drivers').DataTable({
    responsive: false
  });
  $(document).ready(ready)
  $(document).on('page:load', ready)


ready = ->
  setTimeout  ->
    $.fn.fdatepicker.dates['de'] = {
      days: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"],
      daysShort: ["Son", "Mon", "Die", "Mit", "Don", "Fre", "Sam", "Son"],
      daysMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
      months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
      monthsShort: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
      today: "Heute"
    }
    $('#driver_date_of_birth').fdatepicker
      format: 'dd.mm.yyyy',
      disableDblClickSelection: true,
      language: 'de'

    $('#driver_entry_date').fdatepicker
      format: 'dd.mm.yyyy',
      disableDblClickSelection: true,
      language: 'de'

    $('#driver_exit_date').fdatepicker
      format: 'dd.mm.yyyy',
      disableDblClickSelection: true,
      language: 'de'
  ,1000

  $('#drivers-table').DataTable({
    responsive: false,
    columnDefs: [ {
          targets: 'no-sort',
          orderable: false,
    } ]
  });