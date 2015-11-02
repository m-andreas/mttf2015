# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $(document).ready(ready)
  $(document).on('page:load', ready)


ready = ->
  $('#jobs-in-bill-table').DataTable({
    responsive: false,
    columnDefs: [ {
          targets: 'no-sort',
          orderable: false,
    } ]
  });
# Auftragseingabemaske

  $("#job_driver_id").change ->
    $("#drivername").text($( "#job_driver_id option:selected" ).text();)

  $("#job_to_id").change ->
    $("#to").text($( "#job_to_id option:selected" ).text();)

  $("#job_from_id").change ->
    $("#from").text($( "#job_from_id option:selected" ).text();)

  $("#job_cost_center_id").keyup ->
    $("#cost-center").text($("#job_cost_center_id").val());

  $("#job_car_brand").keyup ->
    $("#car_brand").text($("#job_car_brand").val());

  $("#job_car_type").keyup ->
    $("#car_type").text($("#job_car_type").val());

  $("#job_registration_number").keyup ->
    $("#registration_number").text($("#job_registration_number").val());

  $("#job_scheduled_collection_date").keyup ->
    $("#scheduled_collection_date").text($("#job_scheduled_collection_date").val());

  $("#job_scheduled_delivery_date").keyup ->
    $("#scheduled_delivery_date").text($("#job_scheduled_delivery_date").val());

  $("#driver_filter").keyup ->
    $("#job_driver_id").change()

  $("#to_filter").keyup ->
    $("#job_to_id").change();

  $("#from_filter").keyup ->
    $("#job_from_id").change();

  $('#job_from_id').filterByText($('#from_filter'), true);

  $('#job_to_id').filterByText($('#to_filter'), true);

  $('#job_driver_id').filterByText($('#driver_filter'), true);

  $('#shuttle_jobs').DataTable
    processing: true
    serverSide: true
    ajax:
      url: '/jobs_ajax/show_all'
      data: (d) ->
        d.form_type = document.getElementById("form_type").value;
        d.main_job_id = document.getElementById("main_job_id").value;
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
    order: [ [1,'desc'] ],
    oLanguage:{
      sUrl: "/datatable_i18n"
    }

  $('*[data-role=activerecord_sortable]').activerecord_sortable();


# Alle Auftraege Maske

  show_jobs_table = $('#show_jobs').DataTable
    processing: true
    serverSide: true
    hover: true
    ajax:
      url: '/jobs_ajax/show_regular_jobs'
      data: (d) ->
        d.start_from_date = $('#start_from_date').val()
        d.end_at_date = $('#end_at_date').val()
        d.show_open = $('#show_open').prop('checked');
        d.show_finished = $('#show_finished').prop('checked');
        d.show_charged = $('#show_charged').prop('checked');
        d.show_shuttles = $('#show_shuttles').prop('checked');
        d.show_regular_jobs = $('#show_regular_jobs').prop('checked');
        return
    columns: [
      { width: "6%", className: "center", orderable: false }
      { width: "10%", className: "row_config", searchable: false, orderable: false }
      { width: "10%", className: "row_config", searchable: false, orderable: false }
      { width: "7%", className: "row_config", searchable: false, orderable: false }
      { width: "7%", className: "center", searchable: false, orderable: false }
      { width: "10%", className: "center", searchable: false, orderable: false }
      { width: "10%", className: "center", searchable: false, orderable: false }
      { width: "10%", className: "center", searchable: false, orderable: false }
      { width: "5%", className: "center", searchable: false, orderable: false }
      { width: "5%", className: "center", searchable: false, orderable: false }
      { width: "5%", className: "center", searchable: false, orderable: false }
      { width: "5%", className: "center", searchable: false, orderable: false }
    ]
    order: [ [1,'desc'] ],
    oLanguage:{
      sUrl: "datatable_i18n"
    }

  $("#start_from_date").datepicker( dateFormat: "dd.mm.yy" );

  $("#end_at_date").datepicker( dateFormat: "dd.mm.yy" );

  $("#start_from_date").change ->
    $('#show_jobs').dataTable().fnFilter();

  $("#end_at_date").change ->
    $('#show_jobs').dataTable().fnFilter();

  $('#show_open').change ->
    $('#show_jobs').dataTable().fnFilter();

  $('#show_finished').change ->
    $('#show_jobs').dataTable().fnFilter();

  $('#show_charged').change ->
    $('#show_jobs').dataTable().fnFilter();

  $('#show_shuttles').change ->
    $('#show_jobs').dataTable().fnFilter();

  $('#show_regular_jobs').change ->
    $('#show_jobs').dataTable().fnFilter();


# Shuttle verwaltung für create

  shuttle_to_sidebar = ( name, id ) ->
    $('#co_jobs').val($('#co_jobs').val() + "," + id )
    $("#shuttle-co-drivers table tbody").append("<tr><td>" + name + "</td><td>" + id + "</td><td class='remove'><i class='fa fa-minus'></i> entfernen</td></tr>")

  $("#shuttle_jobs").on "click", ".add", ->
    if document.getElementById("form_type").value == "new"
      pos = $('#shuttle_jobs').dataTable().fnGetPosition(this)
      id = $('#shuttle_jobs').dataTable().fnGetData(pos[0])[0];
      name = $('#shuttle_jobs').dataTable().fnGetData(pos[0])[3]
      shuttle_to_sidebar( name, id )

  $("#shuttle-summary").on "click", ".remove", ->
    if document.getElementById("form_type").value == "new"
      id = $(this).parent().children()[1].innerText;
      $('#co_jobs').val($('#co_jobs').val().replace("," + id, ''))
      $(this).parent().remove();

  $("#shuttle-co-drivers").on "click", ".remove", ->
    if document.getElementById("form_type").value == "new"
      id = $(this).parent().children()[1].innerText;
      $('#co_jobs').val($('#co_jobs').val().replace("," + id, ''))
      $(this).parent().remove();

  displayshuttle = ->
    console.log("doit")
    if $('#job_shuttle').prop('checked')
      $("#shuttle_jobs_outer_wrapper").show();
      $("#shuttle-co-drivers").show();
      $("#job_details").hide()
      $("#breakpoints").show()
    else
      console.log("hideit")
      $("#shuttle_jobs_outer_wrapper").hide();
      $("#shuttle-co-drivers").hide();
      $("#job_details").show()
      $("#breakpoints").hide()

  $("#job_shuttle").click ->
    displayshuttle();

  displayshuttle();
  $("#job_driver_id").change();
  $("#job_to_id").change();
  $("#job_from_id").change();
  $("#job_cost_center_id").keyup();
  $("#job_car_type").keyup();
  $("#job_scheduled_delivery_date").keyup();
  $("#job_scheduled_collection_date").keyup();
  $("#job_car_type").keyup();
  $("#job_car_brand").keyup()
  $("#job_registration_number").keyup();