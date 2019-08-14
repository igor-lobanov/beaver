$(function () {
    $(".beaver-sidebar").mCustomScrollbar({
        theme: "minimal"
    });
    $('body').append('<div class="beaver-sidebar-overlay">');
    $('.beaver-sidebar-dismiss, .beaver-sidebar-overlay').on('click', function () {
        $('.beaver-sidebar').removeClass('active');
        $('.beaver-sidebar-overlay').removeClass('active');
    });
    $('.beaver-sidebar-collapse').on('click', function () {
        $('.beaver-sidebar').addClass('active');
        $('.beaver-sidebar-overlay').addClass('active');
    });
});
