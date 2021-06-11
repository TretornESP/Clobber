$SCRIPT_ROOT = {{ request.script_root|tojson|safe }};

function clobber_bind_button(id, command, callback) {
  $(id).bind('click'), function() {
    $.getJSON($SCRIPT_ROOT + command, callback);
  }
}
