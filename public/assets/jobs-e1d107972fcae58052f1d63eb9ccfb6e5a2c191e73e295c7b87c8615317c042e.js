(function(){var e;jQuery(function(){return $(document).ready(e),$(document).on("page:load",e)}),e=function(){var e,r;return console.log("ready"),$("#start_from_date").datepicker({dateFormat:"dd.mm.yy"}),$("#end_at_date").datepicker({dateFormat:"dd.mm.yy"}),$("#start_from_date").change(function(){return $("#show_jobs").dataTable().fnFilter()}),$("#end_at_date").change(function(){return $("#show_jobs").dataTable().fnFilter()}),$("#show_open").change(function(){return $("#show_jobs").dataTable().fnFilter()}),$("#show_finished").change(function(){return $("#show_jobs").dataTable().fnFilter()}),$("#show_charged").change(function(){return $("#show_jobs").dataTable().fnFilter()}),$("#job_from_id").filterByText($("#from_filter"),!0),$("#job_to_id").filterByText($("#to_filter"),!0),$("#job_driver_id").filterByText($("#driver_filter"),!0),$("#shuttle_jobs").DataTable({processing:!0,serverSide:!0,ajax:{url:"/jobs_ajax/show_all",data:function(e){}},columns:[{width:"0%",className:"dont_show",searchable:!1,orderable:!1},{width:"15%",orderable:!1,className:"add"},{width:"35%",className:"row_config"},{width:"15%",className:"row_config",searchable:!1,orderable:!1},{width:"15%",className:"row_config",searchable:!1,orderable:!1},{width:"5%",className:"center",searchable:!1,orderable:!1},{width:"15%",className:"center",searchable:!1,orderable:!1}],order:[[1,"desc"]]}),$("#show_jobs").DataTable({processing:!0,serverSide:!0,hover:!0,language:{search:"Suche nach Details:"},ajax:{url:"/jobs_ajax/show_regular_jobs",data:function(e){e.start_from_date=$("#start_from_date").val(),e.end_at_date=$("#end_at_date").val(),e.show_open=$("#show_open").prop("checked"),e.show_finished=$("#show_finished").prop("checked"),e.show_charged=$("#show_charged").prop("checked")}},columns:[{width:"15%",className:"center",orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"5%",className:"center",searchable:!1,orderable:!1},{width:"5%",className:"center",searchable:!1,orderable:!1},{width:"5%",className:"center",searchable:!1,orderable:!1}],order:[[1,"desc"]]}),$("#show_shuttles").DataTable({processing:!0,serverSide:!0,hover:!0,language:{search:"Suche nach Details:"},ajax:{url:"/jobs_ajax/show_shuttles",data:function(e){e.start_from_date=$("#start_from_date").val(),e.end_at_date=$("#end_at_date").val(),e.show_open=$("#show_open").prop("checked"),e.show_finished=$("#show_finished").prop("checked"),e.show_charged=$("#show_charged").prop("checked")}},columns:[{width:"10%",className:"center",orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"row_config",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1},{width:"10%",className:"center",searchable:!1,orderable:!1}],order:[[1,"desc"]]}),$("#job_driver_id").change(function(){return console.log("driver change"),$("#drivername").text($("#job_driver_id option:selected").text())}),$("#job_to_id").change(function(){return $("#to").text($("#job_to_id option:selected").text())}),$("#job_from_id").change(function(){return $("#from").text($("#job_from_id option:selected").text())}),$("#job_cost_center_id").keyup(function(){return $("#cost-center").text($("#job_cost_center_id").val())}),$("#job_car_brand").keyup(function(){return $("#car_brand").text($("#job_car_brand").val())}),$("#job_car_type").keyup(function(){return $("#car_type").text($("#job_car_type").val())}),$("#job_registration_number").keyup(function(){return $("#registration_number").text($("#job_registration_number").val())}),$("#job_scheduled_collection_date").keyup(function(){return $("#scheduled_collection_date").text($("#job_scheduled_collection_date").val())}),$("#job_scheduled_delivery_date").keyup(function(){return $("#scheduled_delivery_date").text($("#job_scheduled_delivery_date").val())}),$("#driver_filter").keyup(function(){return $("#job_driver_id").change()}),$("#to_filter").keyup(function(){return $("#job_to_id").change()}),$("#from_filter").keyup(function(){return $("#job_from_id").change()}),r=function(e,r){return $("#co_jobs").val($("#co_jobs").val()+","+r),$("#shuttle-co-drivers table tbody").append("<tr><td>"+e+"</td><td>"+r+"</td><td class='remove'><i class='fa fa-minus'></i> entfernen</td></tr>")},$("#shuttle_jobs").on("click",".add",function(){var e,a,t;return t=$("#shuttle_jobs").dataTable().fnGetPosition(this),e=$("#shuttle_jobs").dataTable().fnGetData(t[0])[0],a=$("#shuttle_jobs").dataTable().fnGetData(t[0])[3],r(a,e)}),$("#shuttle-summary").on("click",".remove",function(){var e;return e=$(this).parent().children()[1].innerText,$("#co_jobs").val($("#co_jobs").val().replace(","+e,"")),console.log($(this).parent().remove())}),$("#shuttle-co-drivers").on("click",".remove",function(){var e;return e=$(this).parent().children()[1].innerText,$("#co_jobs").val($("#co_jobs").val().replace(","+e,"")),console.log($(this).parent().remove())}),e=function(){return $("#job_shuttle").prop("checked")?($("#shuttle_jobs_wrapper").show(),$("#shuttle-co-drivers").show()):($("#shuttle_jobs_wrapper").hide(),$("#shuttle-co-drivers").hide())},$("#job_shuttle").click(function(){return e()}),e(),$("#job_driver_id").change(),$("#job_to_id").change(),$("#job_from_id").change(),$("#job_cost_center_id").keyup(),$("#job_car_type").keyup(),$("#job_scheduled_delivery_date").keyup(),$("#job_scheduled_collection_date").keyup(),$("#job_car_type").keyup(),$("#job_car_brand").keyup(),$("#job_registration_number").keyup()}}).call(this);