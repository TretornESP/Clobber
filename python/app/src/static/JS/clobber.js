
function clobber(command, input, callback) {
    $.getJSON($SCRIPT_ROOT + command + $(input).val(), callback);
}
