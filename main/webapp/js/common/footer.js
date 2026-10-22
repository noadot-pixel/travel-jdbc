document.querySelectorAll(".footer-placeholder-link").forEach(function (link) {

    link.addEventListener("click", function (event) {

        event.preventDefault();

        alert(link.dataset.message);

    });

});
