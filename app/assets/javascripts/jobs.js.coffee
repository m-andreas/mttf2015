# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  $('#job_from_id').filterByText($('#from_filter'), true);
  $('#job_to_id').filterByText($('#to_filter'), true);
  $('#driver_id').filterByText($('#driver_filter'), true);
  $('#shuttle_jobs').DataTable
    processing: true 
    serverSide: true 
    ajax: 
      url: '/jobs_ajax/datatable_ajax' 
      data: (d) -> 
        d.product_code = ""
        d.product_name = "" 
        return 
    columns: [ 
      { width: "0%", className: "dont_show", searchable: false, orderable: false } 
      { width: "15%", orderable: false, className: "add" }
      { width: "35%", className: "row_config" }
      { width: "15%", className: "row_config", searchable: false, orderable: false }
      { width: "15%", className: "row_config", searchable: false, orderable: false }
      { width: "5%", className: "center", searchable: false, orderable: false }
      { width: "15%", className: "center", searchable: false, orderable: false }
    ] 
    order: [ [1,'desc'] ] 

    $("#job_shuttle").click ->
      if $('#job_shuttle').prop('checked')
        $("#shuttle_jobs_wrapper").show();
        $("#shuttle-co-drivers").show();
      else
        $("#shuttle_jobs_wrapper").hide();
        $("#shuttle-co-drivers").hide();

    $("#driver_id").change ->
      $("#drivername").text($( "#driver_id option:selected" ).text();)

    $("#job_to_id").change ->
      $("#to").text($( "#job_to_id option:selected" ).text();)

    $("#job_from_id").change ->
      $("#from").text($( "#job_from_id option:selected" ).text();)

    $("#job_cost_center_id").keyup ->
      $("#cost-center").text($("#job_cost_center_id").val());

    $("#driver_filter").keyup ->
      $("#driver_id").change()

    $("#to_filter").keyup ->
      $("#job_to_id").change();

    $("#from_filter").keyup ->
      $("#job_from_id").change();

    $("#shuttle_jobs").on "click", ".add", ->
      pos = $('#shuttle_jobs').dataTable().fnGetPosition(this)
      id = $('#shuttle_jobs').dataTable().fnGetData(pos[0])[0];
      name = $('#shuttle_jobs').dataTable().fnGetData(pos[0])[3]
      $('#co_jobs').val($('#co_jobs').val() + "," + id )
      $("#shuttle-co-drivers table tbody").append("<tr><td>" + name + "</td><td>" + id + "</th></tr>")
      console.log("click");
      console.log($(this).parent().find("dont_show"));
$ ->
  $("#shuttle-co-drivers").hide();
  $("#shuttle_jobs_wrapper").hide();
  $("#driver_id").change()
  $("#job_to_id").change();
  $("#job_from_id").change();
  $("#job_cost_center_id").keyup();