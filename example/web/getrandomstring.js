
function randomstring(params) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    var randomstring = '';
    for (var i = 0; i < params; i++) {
        var rnum = Math.floor(Math.random() * chars.length);
        randomstring += chars[rnum];
    }

    return randomstring;
}   