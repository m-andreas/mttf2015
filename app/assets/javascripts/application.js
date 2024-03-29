// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.responsive
//= require jquery-ui
//= require foundation
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.foundation
//= require turbolinks
//= require_tree .
//= require sortable

$(function(){ $(document).foundation(); });


$(document).ready(function(){
  setTimeout(function(){
    $('.alert-box').fadeOut("slow");
  }, 8000);
  $(function() {
    $('.datepicker').datepicker();
  });
 })

var fade_flash = function() {
  setTimeout(function(){
    $('.alert-box').fadeOut("slow");
  }, 8000);
};
fade_flash();

var show_ajax_message = function(msg, type) {
  if( type == "notice" ){
    type = 'success'
  }
  else{
    type = 'alert'
  }
  $('html, body').animate({ scrollTop: 0 }, 'fast');
  $("#flash-message").html('<div class="alert-box round ' + type + '">' +msg+'</div>');
  fade_flash();
};

$(document).ajaxComplete(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    var type = request.getResponseHeader('X-Message-Type');
    if(msg !== null)
      show_ajax_message(msg, type); //use whatever popup, notification or whatever plugin you want
});