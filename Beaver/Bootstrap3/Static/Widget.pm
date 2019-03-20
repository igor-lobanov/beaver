package Beaver::Bootstrap3::Static::Widget;
use Mojo::Base -base;

1;

__DATA__
@@ beaver.svg
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" height="100px" width="100px" fill="#aa0000" version="1.1" x="0px" y="0px" viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve" id="svg1">
<circle id="circle1" r="1.25" cy="36.25" cx="63.813" />
<circle id="circle2" r="1.25" cy="36.25" cx="36.312" />
<path id="path1" d="m 39.215,53.65 c 0.014,0.033 0.038,0.059 0.055,0.09 0.862,2.027 2.165,3.807 3.836,5.146 1.313,5.059 3.909,8.406 6.955,8.406 3.074,0 5.69,-3.409 6.992,-8.547 3.045,-2.53 4.863,-6.524 4.863,-10.809 0,-7.41 -5.346,-13.438 -11.917,-13.438 -6.571,0 -11.917,6.028 -11.917,13.438 0,1.972 0.402,3.875 1.111,5.613 0.012,0.035 0.008,0.069 0.022,0.101 z m 2.284,0.139 c 0.254,-0.097 0.51,-0.185 0.767,-0.271 0.04,0.604 0.091,1.198 0.162,1.776 -0.347,-0.474 -0.656,-0.977 -0.929,-1.505 z m 2.738,-0.851 c 1.573,-0.387 3.185,-0.612 4.825,-0.675 V 65.052 C 46.795,63.983 44.57,59.402 44.237,52.938 Z m 6.826,12.115 V 52.267 c 1.639,0.07 3.251,0.303 4.823,0.698 -0.338,6.449 -2.56,11.019 -4.823,12.088 z m 6.656,-9.968 c 0.057,-0.499 0.104,-1.009 0.139,-1.527 0.215,0.075 0.43,0.151 0.644,0.231 -0.234,0.452 -0.496,0.884 -0.783,1.296 z M 50,36.5 c 5.468,0 9.917,5.131 9.917,11.438 0,1.392 -0.225,2.745 -0.635,4.011 -2.633,-1.005 -5.388,-1.569 -8.22,-1.682 v -5.334 c 2.282,-0.311 4,-1.664 4,-3.286 0,-1.852 -2.239,-3.354 -5,-3.354 -2.761,0 -5,1.502 -5,3.354 0,1.622 1.718,2.975 4,3.286 v 5.332 c -2.876,0.101 -5.674,0.665 -8.344,1.684 -0.411,-1.265 -0.635,-2.618 -0.635,-4.01 C 40.083,41.631 44.532,36.5 50,36.5 Z" />
<path id="path2" d="M 50,7 C 26.29,7 7,26.29 7,50 7,73.71 26.29,93 50,93 73.71,93 93,73.71 93,50 93,26.29 73.71,7 50,7 Z M 29.699,31.545 c 0,-0.309 0.121,-0.6 0.339,-0.818 0.354,-0.355 0.878,-0.42 1.308,-0.218 -0.522,0.5 -1.025,1.018 -1.506,1.558 -0.084,-0.162 -0.141,-0.335 -0.141,-0.522 z M 50,27 c 12.683,0 23,10.318 23,23 V 78.951 C 67.00489,84.091843 58.718423,86.949622 50,87 41.312,87 33.319,83.982 26.999,78.95 L 27,50 C 27,37.318 37.318,27 50,27 Z m 20.183,5.092 c -0.482,-0.543 -0.988,-1.065 -1.512,-1.568 0.434,-0.217 0.97,-0.159 1.331,0.203 0.371,0.371 0.42,0.925 0.181,1.365 z M 13,50 C 13,29.598 29.598,13 50,13 70.402,13 86.308453,29.165783 87,50 86.959,59.830427 83.742736,68.681986 77.007419,76.585898 L 77,50 C 76.9985,44.604 75.403,39.578 72.666,35.356 l 0.164,-0.165 c 2.011,-2.011 2.011,-5.282 0,-7.293 -2.01,-2.011 -5.283,-2.011 -7.293,0 l -0.023,0.023 C 61.12,24.826 55.771,23 50,23 44.239,23 38.898,24.819 34.509,27.906 l -0.007,-0.007 c -2.01,-2.011 -5.282,-2.011 -7.292,0 -0.974,0.974 -1.511,2.269 -1.511,3.647 0,1.378 0.537,2.673 1.511,3.646 l 0.14,0.14 C 24.603,39.559 23,44.594 23,50 L 22.999,75.26 C 16.804,68.642 13,59.759 13,50 Z" />
</svg>

@@ js/file_upload.js
"use strict";

(function($) {
    $.fn.file_upload = function(args) {
        args = $.extend({
            method: "POST",
            url: "/upload",
            onchange: function(){},
            onerror: function(){},
            onsuccess: function(){},
            onprogress: function(){},
            maxsize: 0,
        }, args);
        this.each(function(){
            var ff = $(this);
            if (ff.is('input') && ff.attr('type')==='file') {
                ff.on('change', function(changeEvent){
                    if (ff[0].files.length>0) {
                        args.onchange.apply(ff, [changeEvent]);
                        var xhr = new XMLHttpRequest();
                        xhr.upload.onprogress = function(progressEvent) {
                            args.onprogress.apply(ff, [progressEvent]);
                        };
                        $(xhr).on('load', function(loadEvent) {
                            args.onsuccess.apply(ff, [loadEvent]);
                            //ff.prop('x-upload',false);
                        });
                        xhr.onabort = function(abortEvent) {
                            args.onerror.apply(ff, [abortEvent]);
                            //ff.prop('x-upload',false);
                        };
                        xhr.onerror = function(errorEvent) {
                            args.onerror.apply(ff, [errorEvent]);
                            //ff.prop('x-upload',false);
                        };
                        xhr.open(args.method, ff.data('upload-url')||args.url, true);
                        var formData = new FormData();
                        $(ff[0].files).map(function(){ formData.append(ff.attr('name'), this) });
                        ff.prop('x-upload',true);
                        xhr.send(formData);
                    }
                    return false;
                });
            }
        });
    }
})(jQuery);

@@ js/sidebar.js
$(function () {
    $(".cs-sidebar").mCustomScrollbar({
        theme: "minimal"
    });
    $('body').append('<div class="cs-sidebar-overlay">');
    $('.cs-sidebar-dismiss, .cs-sidebar-overlay').on('click', function () {
        $('.cs-sidebar').removeClass('active');
        $('.cs-sidebar-overlay').removeClass('active');
    });
    $('.cs-sidebar-collapse').on('click', function () {
        $('.cs-sidebar').addClass('active');
        $('.cs-sidebar-overlay').addClass('active');
    });
});

@@ css/popup.css
.modal.modal-popup .modal-dialog,
.modal.modal-popup .modal-content,
.modal.modal-popup .modal-header,
.modal.modal-popup .modal-body,
.modal.modal-popup .modal-footer
{
  border-radius: 0;
}
.modal.modal-popup .modal-dialog {
  width: 98vw;
  height: 96vh;
  animation-duration:0.6s;
  position: absolute;
  top: 2vh;
  left: 1vw;
  padding: 0;
  margin: 0;
}
.modal.modal-popup .modal-content {
  height:100%;
  padding: 0;
  margin:0;
}
.modal.modal-popup .modal-body {
  overflow-y: hidden;
  padding: 0;
  margin:0;
}
.modal.modal-popup .modal-content iframe {
  border: none;
  padding: 0;
  margin: 0;
  width: 100%;
  height: 100%;
}

@@ css/sidebar.css
/* sidebar and overlay position */
.cs-sidebar {
    min-width: 250px;
    max-width: 250px;
    height: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 9999;
}
.cs-sidebar {
    margin-left: -250px;
}
.cs-sidebar.active {
    margin-left: 0px;
}
.cs-sidebar-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background: rgba(0, 0, 0, 0.7);
    z-index: 9998;
    opacity: 0;
    transition: all 0.5s ease-in-out;
}
.cs-sidebar-overlay.active {
    display: block;
    opacity: 1;
}
.cs-sidebar-dismiss {
    width: 35px;
    height: 35px;
    position: absolute;
    top: 10px;
    right: 10px;
    border: 1px solid #bbb;
}
/* Styling */
.cs-sidebar {
    background: #e7e7e7;
    color: #777;
    transition: all 0.3s;
    border-right: 1px solid #996;
    box-shadow: 1px 1px 3px rgba(0, 0, 0, 0.5);
}
.cs-sidebar .cs-sidebar-header {
    padding: 20px;
    padding-top: 30px;
    background: #e7e7e7;
}
.cs-sidebar ul ul a {
    font-size: 0.9em !important;
    padding-left: 30px !important;
    background: #d7d7d7;
}
.cs-sidebar ul.cs-sidebar-content {
    padding: 20px 0;
    border-bottom: 1px solid #e7e7e7;
}
.cs-sidebar ul p {
    color: #777;
    padding: 10px;
}
.cs-sidebar ul li a {
    padding: 10px;
    font-size: 1.1em;
    display: block;
}
.cs-sidebar ul li a:hover {
    color: #777;
    background: #fff;
}
.cs-sidebar ul li.active > a, a[aria-expanded="true"] {
    background: #eee;
}
.cs-sidebar ul li.active > a:hover, a[aria-expanded="true"]:hover {
    background: #fff;
}
.cs-sidebar a[data-toggle="collapse"][aria-expanded="true"]::after {
    content: '\f077';
    font-family: "Font Awesome 5 Free";
    font-weight: 900;
    display: inline-block;
    position: absolute;
    right: 20px;
}
.cs-sidebar a[data-toggle="collapse"][aria-expanded="false"]::after {
    content: '\f078';
    font-family: "Font Awesome 5 Free";
    font-weight: 900;
    display: inline-block;
    position: absolute;
    right: 20px;
}

@@ css/table.css
.row-clickable {
    cursor: pointer;
}

@@ css/navbar.css
.navbar-custom.navbar {
    background-color: #ffc;
    border-bottom: 1px solid #996;
    box-shadow:0 0 10px rgba(128,128,0,0.5);
}
.navbar-default.navbar {
    border-bottom: 1px solid #777;
    box-shadow: 1px 1px 3px rgba(0, 0, 0, 0.1);
}

