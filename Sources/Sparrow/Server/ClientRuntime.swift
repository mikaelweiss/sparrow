/// The Sparrow client-side JavaScript runtime.
/// Handles WebSocket connection, DOM patching, and event forwarding.
/// ~3KB unminified. Embedded as a string to avoid external file dependencies.
enum ClientRuntime {
    static let script: String = """
    <script>
    (function() {
        "use strict";
        var ws = null;
        var reconnectAttempts = 0;
        var maxReconnectDelay = 5000;
        var reconnectTimer = null;
        var indicator = null;

        // --- WebSocket connection ---

        function connect() {
            var proto = location.protocol === "https:" ? "wss:" : "ws:";
            var url = proto + "//" + location.host + "/sparrow/ws";
            ws = new WebSocket(url);

            ws.onopen = function() {
                reconnectAttempts = 0;
                hideIndicator();
                // Tell server which page we're on
                send({type: "init", url: location.pathname});
            };

            ws.onmessage = function(e) {
                var msg;
                try { msg = JSON.parse(e.data); } catch(_) { return; }
                handleMessage(msg);
            };

            ws.onclose = function() {
                scheduleReconnect();
            };

            ws.onerror = function() {
                // onclose will fire after this
            };
        }

        function send(obj) {
            if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify(obj));
            }
        }

        // --- Reconnection with exponential backoff ---

        function scheduleReconnect() {
            if (reconnectTimer) return;
            var delay = Math.min(100 * Math.pow(2, reconnectAttempts), maxReconnectDelay);
            reconnectAttempts++;
            showIndicator();
            reconnectTimer = setTimeout(function() {
                reconnectTimer = null;
                connect();
            }, delay);
        }

        // --- Reconnection indicator ---

        function showIndicator() {
            if (indicator) return;
            indicator = document.createElement("div");
            indicator.id = "sparrow-reconnect";
            indicator.style.cssText = "position:fixed;bottom:0;left:0;right:0;padding:8px;background:#1a1a2e;color:#e0e0e0;text-align:center;font-family:system-ui;font-size:14px;z-index:99999;transition:opacity 0.3s";
            indicator.textContent = "Reconnecting...";
            document.body.appendChild(indicator);
        }

        function hideIndicator() {
            if (!indicator) return;
            indicator.remove();
            indicator = null;
        }

        // --- Message handling ---

        function handleMessage(msg) {
            switch (msg.type) {
                case "patch":
                    applyPatches(msg.patches || []);
                    break;
                case "page":
                    replacePage(msg);
                    break;
                case "pong":
                    break;
            }
        }

        // --- DOM patching ---

        function applyPatches(patches) {
            // Preserve focus state
            var focused = document.activeElement;
            var focusId = focused ? focused.id : null;
            var selStart = null, selEnd = null;
            if (focused && (focused.tagName === "INPUT" || focused.tagName === "TEXTAREA")) {
                selStart = focused.selectionStart;
                selEnd = focused.selectionEnd;
            }

            for (var i = 0; i < patches.length; i++) {
                applyPatch(patches[i]);
            }

            // Restore focus
            if (focusId) {
                var el = document.getElementById(focusId);
                if (el) {
                    el.focus();
                    if (selStart !== null && (el.tagName === "INPUT" || el.tagName === "TEXTAREA")) {
                        el.selectionStart = selStart;
                        el.selectionEnd = selEnd;
                    }
                }
            }
        }

        function applyPatch(patch) {
            var targetId = patch.target.replace("#", "");
            var el = document.getElementById(targetId);
            if (!el) return;

            switch (patch.op) {
                case "text":
                    el.textContent = patch.value;
                    break;
                case "replace":
                    if (targetId === "sparrow-root") {
                        el.innerHTML = patch.html;
                    } else {
                        el.outerHTML = patch.html;
                    }
                    break;
                case "remove":
                    el.remove();
                    break;
                case "append":
                    el.insertAdjacentHTML("beforeend", patch.html);
                    break;
                case "prepend":
                    el.insertAdjacentHTML("afterbegin", patch.html);
                    break;
                case "attr":
                    el.setAttribute(patch.attr, patch.value);
                    break;
            }
        }

        function replacePage(msg) {
            var root = document.getElementById("sparrow-root");
            if (root && msg.html) {
                root.innerHTML = msg.html;
            }
            if (msg.title) {
                document.title = msg.title;
            }
            window.scrollTo(0, 0);
        }

        // --- Event capture (delegation on #sparrow-root) ---

        function setupEventDelegation() {
            var root = document.getElementById("sparrow-root");
            if (!root) return;

            // Click events (buttons, links)
            root.addEventListener("click", function(e) {
                var target = e.target.closest("[data-sparrow-event*=\\"click\\"]");
                if (target && target.id) {
                    e.preventDefault();
                    send({type: "event", id: target.id, event: "click"});
                }
            });

            // Input events (text fields) with debouncing
            var debounceTimers = {};
            root.addEventListener("input", function(e) {
                var target = e.target.closest("[data-sparrow-event*=\\"input\\"]");
                if (target && target.id) {
                    var delay = parseInt(target.getAttribute("data-sparrow-debounce") || "300", 10);
                    clearTimeout(debounceTimers[target.id]);
                    debounceTimers[target.id] = setTimeout(function() {
                        send({type: "event", id: target.id, event: "input", value: target.value});
                    }, delay);
                }
            });

            // Change events (toggles, selects)
            root.addEventListener("change", function(e) {
                var target = e.target.closest("[data-sparrow-event*=\\"change\\"]");
                if (target && target.id) {
                    var value = target.type === "checkbox" ? String(target.checked) : target.value;
                    send({type: "event", id: target.id, event: "change", value: value});
                }
            });

            // Form submit events
            root.addEventListener("submit", function(e) {
                var target = e.target.closest("[data-sparrow-event*=\\"submit\\"]");
                if (target && target.id) {
                    e.preventDefault();
                    var formData = new FormData(target);
                    var values = {};
                    formData.forEach(function(v, k) { values[k] = v; });
                    send({type: "event", id: target.id, event: "submit", values: values});
                }
            });
        }

        // --- Sidebar collapse toggle (client-side) ---

        document.addEventListener("click", function(e) {
            var btn = e.target.closest(".sidebar-collapse-btn");
            if (btn) {
                var sidebar = btn.closest(".sidebar-layout-sidebar");
                if (sidebar) {
                    sidebar.classList.toggle("sidebar-collapsed");
                }
                return;
            }
        });

        // --- Mobile sidebar toggle ---

        document.addEventListener("click", function(e) {
            // Open via hamburger button
            var hamburger = e.target.closest(".sidebar-mobile-toggle");
            if (hamburger) {
                var layout = hamburger.closest(".sidebar-layout");
                if (layout) {
                    var sidebar = layout.querySelector(".sidebar-layout-sidebar");
                    if (sidebar) sidebar.classList.add("sidebar-open");
                }
                return;
            }
            // Close when clicking outside the sidebar on mobile
            var sidebarOpen = document.querySelector(".sidebar-layout-sidebar.sidebar-open");
            if (sidebarOpen && !e.target.closest(".sidebar-layout-sidebar")) {
                sidebarOpen.classList.remove("sidebar-open");
            }
        });

        // --- Menu toggle (client-side, no server round-trip) ---

        document.addEventListener("click", function(e) {
            var trigger = e.target.closest(".menu-trigger");
            if (trigger) {
                e.stopPropagation();
                var menu = trigger.closest(".menu");
                if (menu) {
                    var content = menu.querySelector(".menu-content");
                    if (content) {
                        content.style.display = content.style.display === "block" ? "none" : "block";
                    }
                }
                return;
            }
            // Close all open menus when clicking outside
            var openMenus = document.querySelectorAll(".menu-content");
            for (var i = 0; i < openMenus.length; i++) {
                openMenus[i].style.display = "none";
            }
        });

        // --- Navigation (intercept internal links) ---

        document.addEventListener("click", function(e) {
            var link = e.target.closest("a[data-sparrow-nav]");
            if (link) {
                e.preventDefault();
                var url = link.getAttribute("href");
                send({type: "navigate", url: url});
                window.history.pushState({}, "", url);
            }
        });

        window.addEventListener("popstate", function() {
            send({type: "navigate", url: location.pathname});
        });

        // --- Heartbeat ---

        setInterval(function() {
            send({type: "ping"});
        }, 30000);

        // --- Boot ---

        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", function() {
                setupEventDelegation();
                connect();
            });
        } else {
            setupEventDelegation();
            connect();
        }
    })();
    </script>
    """
}
