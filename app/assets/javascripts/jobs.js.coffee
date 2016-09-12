# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $(document).ready(ready)
  $(document).on('page:load', ready)


ready = ->

  setTimeout  ->
    $("#show_jobs_filter input").focus()

    $.fn.fdatepicker.dates['de'] = {
      days: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"],
      daysShort: ["Son", "Mon", "Die", "Mit", "Don", "Fre", "Sam", "Son"],
      daysMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
      months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
      monthsShort: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
      today: "Heute"
    }
    $(".remove-co_driver").click ->
      $(this.parentElement).remove()

    $('#job_scheduled_collection_time').fdatepicker
      format: 'dd.mm.yyyy hh:ii',
      disableDblClickSelection: true,
      language: 'de',
      pickTime: true
    .change -> $("#scheduled_collection_time").text($("#job_scheduled_collection_time").val());

    $('#job_scheduled_delivery_time').fdatepicker
      format: 'dd.mm.yyyy hh:ii',
      disableDblClickSelection: true,
      language: 'de',
      pickTime: true
    .change ->
      $("#scheduled_delivery_time").text($("#job_scheduled_delivery_time").val());

    now = new Date();

    job_actual_delivery_time = $('#job_actual_delivery_time').fdatepicker
      format: 'dd.mm.yyyy hh:ii',
      disableDblClickSelection: true,
      language: 'de',
      pickTime: true,
      onRender: (date) ->
        if date.valueOf() > now.valueOf() then 'disabled' else ''
    .change ->
      calculate_time_gap(this)

    job_actual_collection_time = $('#job_actual_collection_time').fdatepicker
      format: 'dd.mm.yyyy hh:ii',
      disableDblClickSelection: true,
      language: 'de',
      pickTime: true,
      onRender: (date) ->
        if date.valueOf() > now.valueOf() then 'disabled' else ''
    .change ->
      calculate_time_gap(this)
  ,1000

  $('#jobs-in-bill-table').DataTable({
    responsive: false,
    columnDefs: [ {
          targets: 'no-sort',
          orderable: false,
    } ]
  })


# Auftragseingabemaske

  $("#job_driver_id").change ->
    setTimeout  ->
      update_panel_field(  $( "#job_driver_id option:selected" ), $("#drivername") )
    , 1000

  $("#job_to_id").change ->
    setTimeout  ->
      update_panel_field( $( "#job_to_id option:selected" ), $("#to") )
    , 1000

  update_panel_field = ( from, to ) ->
    to.text from.text()


  $("#job_from_id").change ->
    setTimeout  ->
      update_panel_field( $( "#job_from_id option:selected" ), $("#from") )
    , 1000

  $("#job_cost_center_id").keyup ->
    $("#cost-center").text($("#job_cost_center_id").val());

  $("#job_car_brand").keyup ->
    $("#car_brand").text($("#job_car_brand").val());

  $("#job_car_type").keyup ->
    $("#car_type").text($("#job_car_type").val());

  $("#job_registration_number").keyup ->
    $("#registration_number").text($("#job_registration_number").val());

  $("#driver_filter").keyup ->
    $("#job_driver_id").change()

  $("#to_filter").keyup ->
    $("#job_to_id").change();

  $("#from_filter").keyup ->
    $("#job_from_id").change();

  checkTimespan = () ->
    strDate = $("#job_actual_collection_time").val()
    dateParts = strDate.split(".");
    time = dateParts[2].split(":");
    hour = time[0].slice(-2)
    dateStart = new Date(dateParts[2].substring(0,4), dateParts[1]-1, dateParts[0], time[0].slice(-2), time[1]);
    strDate = $("#job_actual_delivery_time").val()
    dateParts = strDate.split(".");
    time = dateParts[2].split(":");
    hour = time[0].slice(-2)
    dateEnd = new Date(dateParts[2].substring(0,4), dateParts[1]-1, dateParts[0], time[0].slice(-2), time[1]);
    oneDay = 24*60*60*1000;
    daysBetween = (dateEnd.getTime()- dateStart.getTime())/oneDay
    daysBetween > 2

  checkDaysBetween = (e) ->
    strDate = $(e).val()
    dateParts = strDate.split(".");
    time = dateParts[2].split(":");
    hour = time[0].slice(-2)
    date = new Date(dateParts[2].substring(0,4), dateParts[1]-1, dateParts[0], time[0].slice(-2), time[1]);
    oneDay = 24*60*60*1000;
    daysBetween = (date.getTime()- Date.now())/oneDay
    daysBetween > 1 || daysBetween < -30

  calculate_time_gap = (e) ->
    if checkDaysBetween
      $(e).parent().css('background-color', 'red');
    else
     $(e).parent().css('background-color', 'transparent');

  high_distance = () ->
    Math.abs(parseInt($("#job_mileage_delivery").val()) - parseInt($("#job_mileage_collection").val())) > 1500

  calculate_distance = () ->
    $("#distance").text(parseInt($("#job_mileage_delivery").val()) - parseInt($("#job_mileage_collection").val()) + " km");
    if high_distance()
      $("#distance").css('background-color', 'red');
    else
     $("#distance").css('background-color', 'transparent');

  doc_keyUp = (e) ->
    if (e.keyCode == 35)
        $("#update_and_pay").click()

  document.addEventListener('keyup', doc_keyUp, false);


  $("#job_mileage_delivery").keyup ->
    calculate_distance();

  $("#job_mileage_collection").keyup ->
    calculate_distance();

  $('#job_from_id').filterByText($('#from_filter'), true);

  $('#job_to_id').filterByText($('#to_filter'), true);

  $('#job_driver_id').filterByText($('#driver_filter'), true);

  $('#shuttle_jobs').DataTable
      processing: true
      serverSide: true
      ajax:
        url: window._url_prefix + "jobs_ajax/show_all"
        data: (d) ->
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
        sUrl: window._url_prefix + "datatable_i18n"
      }


  $('*[data-role=activerecord_sortable]').activerecord_sortable();


# Alle Auftraege Maske

  show_jobs_table = $('#show_jobs').DataTable
    processing: true
    serverSide: true
    hover: true
    ajax:
      url: window._url_prefix + "jobs_ajax/show_regular_jobs"
      data: (d) ->
        d.start_from_date = $('#start_from_date').val()
        d.end_at_date = $('#end_at_date').val()
        d.show_open = $('#show_open').prop('checked');
        d.show_finished = $('#show_finished').prop('checked');
        d.show_charged = $('#show_charged').prop('checked');
        d.show_shuttles = $('#show_shuttles').prop('checked');
        d.show_regular_jobs = $('#show_regular_jobs').prop('checked');
        d.show_deleted = $('#show_deleted').prop('checked');
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
      sUrl: window._url_prefix + "datatable_i18n"
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

  $('#show_deleted').change ->
    $('#show_jobs').dataTable().fnFilter();

  calculate_time_gap = (e) ->
    strDate = $(e).val()
    dateParts = strDate.split(".");
    time = dateParts[2].split(":");
    hour = time[0].slice(-2)
    date = new Date(dateParts[2].substring(0,4), dateParts[1]-1, dateParts[0], time[0].slice(-2), time[1]);
    oneDay = 24*60*60*1000;
    daysBetween = (date.getTime()- Date.now())/oneDay
    console.log(daysBetween)

    if daysBetween > 1 || daysBetween < -30
      $(e).parent().css('background-color', 'red');
    else
     $(e).parent().css('background-color', 'transparent');



  $('form[class="edit_job"]').submit ( event ) ->
      if  high_distance()
        if (!confirm("Die Distanz ist ungewöhnlich hoch ( " + $("#distance").html() + " ). Fortfahren?"))
          event.preventDefault();
      if checkDaysBetween($("#job_actual_collection_time"))
        if (!confirm("Der Abholtermin wirkt ungewöhnlich ( " + $("#job_actual_collection_time").val() + " ). Fortfahren?"))
          event.preventDefault();
      if checkDaysBetween($("#job_actual_delivery_time"))
        if (!confirm("Der Liefertermin wirkt ungewöhnlich ( " + $("#job_actual_collection_time").val() + " ). Fortfahren?"))
          event.preventDefault();
      if checkDaysBetween($("#job_actual_delivery_time"))
        if (!confirm("Der Liefertermin wirkt ungewöhnlich ( " + $("#job_actual_collection_time").val() + " ). Fortfahren?"))
          event.preventDefault();
      if checkTimespan()
        if (!confirm("Die Zeitspanne zwischen Abholung und Lieferung ist ungewöhlich groß. Fortfahren?"))
          event.preventDefault();

# Shuttle verwaltung für edit

  window.attach_shuttle_functions = (elem) ->
    $('#start_milage').change ->
      url = window._url_prefix + "jobs/change_breakpoint_distance/" + $("#id").val() + "?count=START" + "&distance=" + $(this).val()
      $.ajax(url: url, dataType: 'script' ).done (html) ->

    $('#end_milage').change ->
      url = window._url_prefix + "jobs/change_breakpoint_distance/" + $("#id").val() + "?count=END" + "&distance=" + $(this).val()
      $.ajax(url: url, dataType: 'script' ).done (html) ->

    $('.leg_distance').change ->
      a = $(this).parent().parent().parent().attr("id")
      url = window._url_prefix + "jobs/change_breakpoint_distance/" + $("#id").val() + "?count=" + a + "&distance=" + $(this).val()
      $.ajax(url: url, dataType: 'script' ).done (html) ->

    $('.add_shuttle_passenger').click ->
      a = $(this).parent().parent().parent().attr("id")

      url = window._url_prefix + "jobs/add_shuttle_passenger/" + $("#id").val() + "?count=" + a + "&driver_id=" + $(this).parent().parent().find(".driver_ids").val()
      $.ajax(url: url, dataType: 'html', context: this )
      .done (html) ->
        console.log("done")
        console.log($($(this).parent().parent()))
        $(this).parent().parent().find(".shuttle_passengers").replaceWith(html)
        console.log(html)
        true
      .fail (html) ->
        console.log("fail")
        console.log(this)
        console.log(html)
        true
    $('.addresses_select').change ->
      a = $(this).parent().parent().parent().attr("id")
      url = window._url_prefix + "jobs/change_breakpoint_address/" + $("#id").val() + "?count=" + a + "&address_id=" + $(this).val()
      $.ajax(url: url, dataType: 'script' ).done (html) ->

  window.attach_shuttle_functions()

#  remove_breakpoint = (elem) ->
#    $(elem).parent().parent().next().remove()
#    $(elem).parent().parent().remove()

#  add_breakpoint = (count) ->


#  $(".remove_breakpoint").click ->
#    remove_breakpoint(this)
  calculate_distance();
  $("#job_driver_id").change();
  $("#job_to_id").change();
  $("#job_from_id").change();
  $("#job_cost_center_id").keyup();
  $("#job_car_type").keyup();
  $("#job_car_type").keyup();
  $("#job_car_brand").keyup()
  $("#job_registration_number").keyup();
  $("#scheduled_collection_time").text($("#job_scheduled_collection_time").val());
  $("#scheduled_delivery_time").text($("#job_scheduled_delivery_time").val());
