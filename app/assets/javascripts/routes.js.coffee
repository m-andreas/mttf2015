# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready(ready)
  $(document).on('page:load', ready)


ready = ->
  console.log("ready");
  $('#routes-table').DataTable({
    responsive: false
  });