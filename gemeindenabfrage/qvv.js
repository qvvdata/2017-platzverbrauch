function resize() {
    if(window.parent) {
        window.parent.postMessage(JSON.stringify({
           'height': document.body.offsetHeight,
           'id': QVVID
        }),'*');
    }
}
document.addEventListener('readystatechange', function() {
    if(document.readyState!='complete') {
        return;
    }
    if(document.fonts) {
        document.fonts.onloadingdone = resize;
        if(document.fonts.ready && document.fonts.ready.then) {
            document.fonts.ready.then(resize);
        }
    }
});

function getEmbed() {
    return ['<iframe height="0" src="',document.location,
        '" scrolling="no" frameborder="0" ',
        'style="width: 0; min-width: 100% !important;"',
        'allowtransparency="true" allowfullscreen="allowfullscreen" ',
        'webkitallowfullscreen="webkitallowfullscreen" ',
        'mozallowfullscreen="mozallowfullscreen" oallowfullscreen="oallowfullscreen" ',
        'msallowfullscreen="msallowfullscreen" ',
        'id="',QVVID,'"></iframe>',
        '<script>window.addEventListener("message",',
            'function(message) {',
            'try{ message = JSON.parse(message.data);',
            'if(message.height && message.id) {var el = document.getElementById(message.id);',
            'el.height=message.height; }} catch(e) {}',
        '});</script>'].join('');
}
