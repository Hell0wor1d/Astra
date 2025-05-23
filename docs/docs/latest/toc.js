// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded affix "><a href="introduction.html">Introduction</a></li><li class="chapter-item expanded affix "><a href="getting_started.html">Getting Started</a></li><li class="chapter-item expanded affix "><li class="part-title">Basic Usage</li><li class="chapter-item expanded "><a href="basic_usage/configuration.html"><strong aria-hidden="true">1.</strong> Configuration</a></li><li class="chapter-item expanded "><a href="basic_usage/routes.html"><strong aria-hidden="true">2.</strong> Routes</a></li><li class="chapter-item expanded "><a href="basic_usage/requests.html"><strong aria-hidden="true">3.</strong> Requests</a></li><li class="chapter-item expanded "><a href="basic_usage/responses.html"><strong aria-hidden="true">4.</strong> Responses</a></li><li class="chapter-item expanded "><a href="basic_usage/cookies.html"><strong aria-hidden="true">5.</strong> Cookies</a></li><li class="chapter-item expanded "><a href="basic_usage/fault_tolerance.html"><strong aria-hidden="true">6.</strong> Fault Tolerance</a></li><li class="chapter-item expanded "><a href="basic_usage/deployment.html"><strong aria-hidden="true">7.</strong> Deployment</a></li><li class="chapter-item expanded "><a href="basic_usage/astra_io.html"><strong aria-hidden="true">8.</strong> Astra IO</a></li><li class="chapter-item expanded affix "><li class="part-title">Utilities</li><li class="chapter-item expanded "><a href="utilities/about.html"><strong aria-hidden="true">9.</strong> About utilities</a></li><li class="chapter-item expanded "><a href="utilities/schema_validation.html"><strong aria-hidden="true">10.</strong> Schema Validation</a></li><li class="chapter-item expanded "><a href="utilities/markup_languages.html"><strong aria-hidden="true">11.</strong> Markup Language Parsers</a></li><li class="chapter-item expanded "><a href="utilities/crypto.html"><strong aria-hidden="true">12.</strong> Crypto</a></li><li class="chapter-item expanded "><a href="utilities/sql_driver.html"><strong aria-hidden="true">13.</strong> PostgreSQL Driver</a></li><li class="chapter-item expanded "><a href="utilities/async_tasks.html"><strong aria-hidden="true">14.</strong> Async Tasks</a></li><li class="chapter-item expanded "><a href="utilities/http_client.html"><strong aria-hidden="true">15.</strong> HTTP Client</a></li><li class="chapter-item expanded "><a href="utilities/dotenv.html"><strong aria-hidden="true">16.</strong> Dotenv</a></li><li class="chapter-item expanded "><a href="utilities/extra_goodies.html"><strong aria-hidden="true">17.</strong> Extra Goodies</a></li><li class="chapter-item expanded "><a href="utilities/importing.html"><strong aria-hidden="true">18.</strong> Importing Overhaul</a></li><li class="chapter-item expanded affix "><li class="part-title">Internals</li><li class="chapter-item expanded "><a href="internals/structure.html"><strong aria-hidden="true">19.</strong> Structure</a></li><li class="chapter-item expanded "><a href="internals/extending_astra.html"><strong aria-hidden="true">20.</strong> Extending Astra</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
