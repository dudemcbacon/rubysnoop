$(document).ready(function() {
  $('#scanform').submit(function(event) {
    alert("submit happened.");
    event.preventDefault();
  });
});
