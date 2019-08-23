"use strict";

var Beaver = Beaver || {};

Beaver = (function(NS) {
    
    NS.redirect = function(url) {
        var path = window.location.pathname+window.location.search;
        var newpath = $('<a>').attr('href', url).prop('pathname')+$('<a>').attr('href', url).prop('search');
        $(location).prop('href', url);
        if (path == newpath) window.location.reload(true);
    };

    NS.getStorage = function(key) {
        try {
            var value = JSON.parse(window.localStorage.getItem(key));
            if (value == null) {
                return [];
            }
            else {
                return value;
            }
        }
        catch (e) {
            return [];
        }
    };
    NS.pushStorage = function(key, value) {
        var stored = NS.getStorage(key);
        stored.push(value);
        window.localStorage.setItem(key, JSON.stringify(stored));
    };
    NS.popStorage = function(key) {
        var stored = NS.getStorage(key);
        var value = stored.pop();
        window.localStorage.setItem(key, JSON.stringify(stored));
        return value;
    };

    NS.confirm = function(dlg) {
        dlg = $.extend(true, {
            callback: function(){},
            message: 'Are you sure?',
            title: 'Confirm action',
            label_yes: 'Yes',
            label_no: 'No'
        }, dlg);
        $('<div class="modal fade">').append(
            $('<div class="modal-dialog">').append(
                $('<div class="modal-content">').append(
                    $('<div class="modal-header">').append(
                        $('<button type="button" class="close" data-dismiss="modal">').html('&times;'),
                        $('<h3 class="modal-title">').text(dlg.title)
                    ),
                    $('<div class="modal-body">').append(
                        $('<p class="lead">').text(dlg.message)
                    ),
                    $('<div class="modal-footer">').append(
                        $('<button type="button" class="btn btn-lg btn-success" data-dismiss="modal">').text(dlg.label_yes).on('click', function(){
                            dlg.callback();
                        }),
                        $('<button type="button" class="btn btn-lg btn-danger" data-dismiss="modal">').text(dlg.label_no)
                    )
                )
            )
        ).modal();
    };
    
    NS.alert = function(dlg) {
        dlg = $.extend(true, {
            callback: function(){},
            message: 'Something happened',
            title: 'Alert',
            label_ok: 'Ok'
        }, dlg);
        $('<div class="modal fade">').append(
            $('<div class="modal-dialog">').append(
                $('<div class="modal-content">').append(
                    $('<div class="modal-header">').append(
                        $('<button type="button" class="close" data-dismiss="modal">').html('&times;'),
                        $('<h3 class="modal-title">').text(dlg.title)
                    ),
                    $('<div class="modal-body">').append(
                        $('<p class="lead">').text(dlg.message)
                    ),
                    $('<div class="modal-footer">').append(
                        $('<button type="button" class="btn btn-lg btn-primary" data-dismiss="modal">').text(dlg.label_ok)
                    )
                )
            )
        ).css("z-index", "9999").modal();
    };

    NS.display_errors = function(errors,form) {
        for (var i=0; i<errors.length; i++) {
            if (typeof(errors[i].alert)!=="undefined") {
                Beaver.alert(errors[i].alert);
            }
            else if (typeof(errors[i].field)!=="undefined") {
                var el = $('[name="'+errors[i].field+'"]');
                el.closest('[class~="form-group"]').addClass('has-error from-'+form).data({
                    toggle: "popover",
                    trigger: "click hover",
                    placement: "auto",
                    content: errors[i].message
                }).popover();
            }
        }
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
            beforeSend: function(xhr, settings) {
                $('.form-group.has-error.from-'+req.form).popover('destroy').removeClass('has-error');
            },
            error: function(xhr, status, error) {},
            success: function(data, status, xhr) {
                if (typeof(data.redirect)!=="undefined") {
                    // restore redirect parameters from web-storage
                    // TODO
                    NS.redirect(data.redirect);
                }
                else if (typeof(data.errors)!=="undefined") {
                    NS.display_errors(data.errors, req.form);
                }
            }
        });
    };

    return NS;

} (Beaver));

Beaver.Storage = Beaver.Storage || {};

Beaver.Storage = (function(NS) {

    NS.get = function(key) {
        try {
            return JSON.parse(window.localStorage.getItem(key)||'[]');
        }
        catch (e) {
            return [];
        }
    };

    NS.push = function(key, value) {
        var stored = NS.get(key);
        stored.push(value);
        window.localStorage.setItem(key, JSON.stringify(stored));
    };
    
    NS.pop = function(key) {
        var stored = NS.get(key);
        var value = stored.pop();
        window.localStorage.setItem(key, JSON.stringify(stored));
        return value;
    };

    return NS;

} (Beaver.Storage));

$(function(){
    // form submit buttons
    var submitter = function(el) {
        Beaver.sendRequest({
            form: el.data('submit') || '',
            url: el.data('url') || window.location.href,
            method: el.data('method') || 'GET'
        });
        // save current page parameters to web-storage
        // TODO
    }
    $('[data-submit]').on('click', function(){
        var el = $(this);
        if (el.data('confirm')) {
            Beaver.confirm({
                callback: function(){submitter(el)},
                message: $(this).data('confirm'),
                label_yes: $(this).data('confirm_label_yes'),
                label_no: $(this).data('confirm_label_no'),
                title: $(this).data('confirm_title')
            });
        }
        else {
            submitter(el);
        }
    });
    // save current location
    Beaver.pushStorage(window.location.pathname, window.location.search);
});
