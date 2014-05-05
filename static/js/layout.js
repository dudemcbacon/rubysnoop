$(document).ready(function() {
  $('#scan').submit(function(event) {
    alert("submit happened.");
    $('.progress-bar').css('width', '0%');
    target = $('#target').val();
    alert(target);
    r = $.post('/scan',  $('form#scan').serialize(), function(data) {
      if data.success == true 
    }, 'json');
    event.preventDefault();
  });
});
