package Beaver::Bootstrap3::Static::Widget;
use Mojo::Base -base;

1;

__DATA__

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

@@ css/form.css
.form-inline {
    display:inline!important;
}

