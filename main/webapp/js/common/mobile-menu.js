/* 휴대폰에서는 데스크톱 메뉴를 오른쪽 드로어로 전환한다. */
(function () {

    const header = document.getElementById("siteHeader");
    const toggle = document.getElementById("mobileMenuToggle");
    const backdrop = document.getElementById("mobileMenuBackdrop");
    const panel = document.getElementById("mobileMenuPanel");
    const toggleLabel = toggle && toggle.querySelector(".blind");

    if (!header || !toggle || !backdrop || !panel) {
        return;
    }

    function setMenuOpen(open, options) {
        const mobileViewport = window.innerWidth <= 1024;
        const shouldOpen = mobileViewport && open;

        header.classList.toggle("mobile-menu-open", shouldOpen);
        document.body.classList.toggle("mobile-menu-open", shouldOpen);
        toggle.setAttribute("aria-expanded", String(shouldOpen));
        backdrop.hidden = !shouldOpen;
        panel.inert = mobileViewport && !shouldOpen;

        if (toggleLabel) {
            toggleLabel.textContent = shouldOpen
                ? window.t("nav.menuClose", "메뉴 닫기")
                : window.t("nav.menuOpen", "메뉴 열기");
        }

        if (mobileViewport) {
            panel.setAttribute("aria-hidden", String(!shouldOpen));
        } else {
            panel.removeAttribute("aria-hidden");
        }

        if (shouldOpen && options && options.focusDrawer) {
            window.setTimeout(function () {
                const firstControl = panel.querySelector("a[href], button:not([disabled]), select, input:not([disabled])");
                if (firstControl) {
                    firstControl.focus();
                }
            }, 0);
        }

        if (!shouldOpen && options && options.returnFocus) {
            toggle.focus();
        }
    }

    toggle.addEventListener("click", function () {
        setMenuOpen(!header.classList.contains("mobile-menu-open"), { focusDrawer: true });
    });

    backdrop.addEventListener("click", function () {
        setMenuOpen(false, { returnFocus: true });
    });

    panel.querySelectorAll("a").forEach(function (link) {
        link.addEventListener("click", function () {
            if (window.innerWidth <= 1024) {
                setMenuOpen(false);
            }
        });
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && header.classList.contains("mobile-menu-open")) {
            setMenuOpen(false, { returnFocus: true });
            return;
        }

        if (event.key !== "Tab" || !header.classList.contains("mobile-menu-open")) {
            return;
        }

        const focusable = Array.prototype.slice.call(
            panel.querySelectorAll("a[href], button:not([disabled]), select, input:not([disabled])")
        ).filter(function (element) {
            return !element.hidden && element.getClientRects().length > 0;
        });

        if (focusable.length === 0) {
            return;
        }

        const first = focusable[0];
        const last = focusable[focusable.length - 1];

        if (event.shiftKey && document.activeElement === first) {
            event.preventDefault();
            last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first.focus();
        }
    });

    //뷰포트 폭이 바뀔 때마다(모바일<->PC 양쪽 방향 다) 열림 상태를 다시 계산한다.
    //예전엔 "열려있을 때 PC 폭으로 커지는" 경우만 처리했는데, 그러면 모바일 폭에서
    //드로어를 한 번도 안 열고 그대로 PC 폭으로 키웠을 때 panel.inert가 true로 남아서
    //데스크톱 메뉴 전체가 클릭·포커스가 전혀 안 먹는 상태로 고정되는 문제가 있었다.
    window.addEventListener("resize", function () {
        setMenuOpen(header.classList.contains("mobile-menu-open"));
    });

    setMenuOpen(false);

})();
