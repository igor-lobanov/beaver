"use strict";

var Beaver = Beaver || {};

Beaver = (function(NS) {
    
    NS.redirect = function(url) {
        var path = window.location.pathname+window.location.search;
        var newpath = $('<a>').attr('href', url).prop('pathname')+$('<a>').attr('href', url).prop('search');
        $(location).prop('href', url);
        if (path == newpath) window.location.reload(true);
    };

    NS.sendRequest = function(req) {
        req = $.extend(true, {
            method: 'GET',
            url: window.location.href
        }, req);
        var formdata = new FormData();
        $('[data-form~="'+req.form+'"]').map(function(i,el){
            var el = $(this);
            if (typeof(el.attr('name'))!=='string') return;
            if (el.is('input') && el.attr('type')==='file') {
                $(this.files).each(function(file_index, file){ formdata.append(el.attr('name'), file); });
            }
            else {
                formdata.append(el.attr('name'), el.val());
            }
        });
        $.ajax({
            type: req.method,
            url: req.url,
            // multipart/form-data
            contentType: false,
            processData: false,
            data: formdata,
            traditional: true,
            error: function(xhr, status, error) {},
            success: function(data, status, xhr) {
                if (typeof(data.redirect)!=="undefined") {
                    // restore redirect parameters from web-storage
                    // TODO
                    NS.redirect(data.redirect);
                }
            }
        });
    };

    NS.saveLocation = function() {
        var storage = window.localStorage;
        storage.setItem(window.location.pathname, JSON.stringify({"table.page":4,"table.sort":"label"}));
    };

    return NS;

} (Beaver));

$(function(){
    // form submit buttons
    $('[data-submit]').on('click', function(){
        Beaver.sendRequest({
            form: $(this).data('submit') || '',
            url: $(this).data('url') || window.location.href,
            method: $(this).data('method') || 'GET'
        });
    });
    // save current page parameters to web-storage
    // TODO
    Beaver.saveLocation();
});
