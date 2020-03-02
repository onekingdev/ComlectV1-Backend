$(document).ready(function() {
  if (typeof(_audit_request_id) != "undefined") {
    $("html, body").stop().animate({scrollTop:$("#_audit_request_"+_audit_request_id).position().top-100}, 500, 'swing');
  }

  $(".audit_requests.index, .audit_requests.show").on("click", ".btn-purchase", function() {
    $.ajax({
      type: 'POST',
      url: _audit_requests_url,
      data: { id: $(this).attr("data-identifier") },
      success: function(data) {
        window.location = data.url;
      }
    });
  });

  $(".audit_requests.index, .audit_requests.show").on("click", ".btn-customize", function() {
    console.log("hey");
    window.location = _audit_requests_url+"/new?id="+$(this).attr("data-identifier");
  });
})