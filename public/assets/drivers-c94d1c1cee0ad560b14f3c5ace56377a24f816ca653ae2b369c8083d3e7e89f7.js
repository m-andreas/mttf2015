(function(){var e;jQuery(function(){return $("#drivers").DataTable({responsive:!1}),$("#driver_date_of_birth").datepicker({dateFormat:"yy-mm-dd"}),$("#driver_entry_date").datepicker({dateFormat:"yy-mm-dd"}),$("#driver_exit_date").datepicker({dateFormat:"yy-mm-dd"}),$(document).ready(e),$(document).on("page:load",e)}),e=function(){return $("#drivers-table").DataTable({responsive:!1,columnDefs:[{targets:"no-sort",orderable:!1}]})}}).call(this);