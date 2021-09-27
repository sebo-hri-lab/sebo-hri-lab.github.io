$(document).on("scroll", function() {

    if ($(document).scrollTop() > 70) {
        $("nav").addClass("shrink");
        $("nav2").addClass("shrink2");
    } else {
        $("nav").removeClass("shrink");
        $("nav2").addClass("shrink2");
    }

});