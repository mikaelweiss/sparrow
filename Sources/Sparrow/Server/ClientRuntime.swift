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
        var pendingFragment = null;

        // --- WebSocket connection ---

        function connect() {
            var proto = location.protocol === "https:" ? "wss:" : "ws:";
            var url = proto + "//" + location.host + "/sparrow/ws";
            ws = new WebSocket(url);

            ws.onopen = function() {
                reconnectAttempts = 0;
                hideIndicator();
                // Tell server which page we're on
                send({type: "init", url: location.pathname + location.search});
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
                case "content":
                    replaceContent(msg);
                    break;
                case "redirect":
                    if (msg.url) {
                        send({type: "navigate", url: msg.url});
                        window.history.replaceState({}, "", msg.url);
                    }
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
                case "removeAttr":
                    el.removeAttribute(patch.attr);
                    break;
                case "replaceInner":
                    el.innerHTML = patch.html;
                    break;
                case "insertBefore":
                    if (patch.beforeId) {
                        var before = document.getElementById(patch.beforeId);
                        if (before && before.parentNode === el) {
                            var tpl = document.createElement("template");
                            tpl.innerHTML = patch.html;
                            el.insertBefore(tpl.content.firstChild, before);
                        } else {
                            el.insertAdjacentHTML("beforeend", patch.html);
                        }
                    } else {
                        el.insertAdjacentHTML("beforeend", patch.html);
                    }
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
            if (pendingFragment) {
                var target = document.getElementById(pendingFragment);
                if (target) {
                    target.scrollIntoView({behavior: "smooth"});
                }
                pendingFragment = null;
            } else {
                window.scrollTo(0, 0);
            }
        }

        function replaceContent(msg) {
            var content = document.getElementById("sparrow-content");
            if (content && msg.html) {
                content.innerHTML = msg.html;
            }
            if (msg.title) {
                document.title = msg.title;
            }
            if (pendingFragment) {
                var target = document.getElementById(pendingFragment);
                if (target) {
                    target.scrollIntoView({behavior: "smooth"});
                }
                pendingFragment = null;
            }
            // Don't scroll to top — layout preserves position
            var root = document.getElementById("sparrow-root");
            if (root) activatePrimitives(root);
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

        // --- Navigation (intercept internal links) ---

        document.addEventListener("click", function(e) {
            var link = e.target.closest("a[data-sparrow-nav]");
            if (link) {
                e.preventDefault();
                var url = link.getAttribute("href");
                var hashIndex = url.indexOf("#");
                var path = hashIndex >= 0 ? url.substring(0, hashIndex) : url;
                var fragment = hashIndex >= 0 ? url.substring(hashIndex + 1) : null;

                // Same-page fragment navigation — just scroll, no server round-trip
                if (path === "" || path === location.pathname) {
                    if (fragment) {
                        var target = document.getElementById(fragment);
                        if (target) target.scrollIntoView({behavior: "smooth"});
                    }
                    window.history.pushState({}, "", url);
                    return;
                }

                // Cross-page navigation
                if (fragment) pendingFragment = fragment;
                send({type: "navigate", url: path});
                window.history.pushState({}, "", url);
            }
        });

        window.addEventListener("popstate", function() {
            var fragment = location.hash ? location.hash.substring(1) : null;
            if (fragment) pendingFragment = fragment;
            send({type: "navigate", url: location.pathname});
        });

        // --- Heartbeat ---

        setInterval(function() {
            send({type: "ping"});
        }, 30000);

        // =======================================
        // BEHAVIORAL PRIMITIVES
        // =======================================

        // After DOM patches, scan for data-sparrow-* attributes and activate
        // the corresponding behavioral primitives.

        function activatePrimitives(root) {
            activateFocusTraps(root);
            activateDismissables(root);
            activatePresence(root);
            activateRovingFocus(root);
            activateFloating(root);
            activateRive(root);
            activateLottie(root);
            updateRiveInputs(root);
            activateScrollTransitions(root);
        }

        // --- FocusTrap ---
        // Traps Tab/Shift+Tab cycling within a container.
        // Activated by: data-sparrow-focus-trap on a container element.
        // Based on Radix FocusScope: TreeWalker for tabbable discovery,
        // global stack for nested traps (pause/resume), focusin listener
        // to catch escapes, focus restoration on unmount.

        var activeFocusTraps = [];
        var previouslyFocused = null;

        function getFocusableElements(container) {
            var result = [];
            var walker = document.createTreeWalker(
                container,
                NodeFilter.SHOW_ELEMENT,
                { acceptNode: function(node) {
                    if (node.hidden || node.disabled) return NodeFilter.FILTER_SKIP;
                    if (node.tagName === "INPUT" && node.type === "hidden") return NodeFilter.FILTER_SKIP;
                    if (node.tabIndex >= 0) return NodeFilter.FILTER_ACCEPT;
                    return NodeFilter.FILTER_SKIP;
                }}
            );
            while (walker.nextNode()) {
                var node = walker.currentNode;
                var style = getComputedStyle(node);
                if (style.display !== "none" && style.visibility !== "hidden") {
                    result.push(node);
                }
            }
            return result;
        }

        // Tab/Shift+Tab cycling — only the topmost trap is active
        function focusTrapHandler(e) {
            if (e.key !== "Tab" || activeFocusTraps.length === 0) return;
            if (e.altKey || e.ctrlKey || e.metaKey) return;
            var trap = activeFocusTraps[activeFocusTraps.length - 1];
            var focusable = getFocusableElements(trap);
            if (focusable.length === 0) {
                e.preventDefault();
                return;
            }
            var first = focusable[0];
            var last = focusable[focusable.length - 1];
            if (e.shiftKey) {
                if (document.activeElement === first || !trap.contains(document.activeElement)) {
                    e.preventDefault();
                    last.focus({ preventScroll: true });
                }
            } else {
                if (document.activeElement === last || !trap.contains(document.activeElement)) {
                    e.preventDefault();
                    first.focus({ preventScroll: true });
                }
            }
        }

        // Refocus if focus escapes the active trap (per Radix focusin listener)
        document.addEventListener("focusin", function(e) {
            if (activeFocusTraps.length === 0) return;
            var trap = activeFocusTraps[activeFocusTraps.length - 1];
            if (!trap.contains(e.target)) {
                var focusable = getFocusableElements(trap);
                if (focusable.length > 0) {
                    focusable[0].focus({ preventScroll: true });
                } else {
                    trap.focus({ preventScroll: true });
                }
            }
        });

        document.addEventListener("keydown", focusTrapHandler);

        function activateFocusTraps(root) {
            var traps = root.querySelectorAll("[data-sparrow-focus-trap]");
            // Clean up traps for elements no longer in DOM
            activeFocusTraps = activeFocusTraps.filter(function(t) {
                return document.body.contains(t);
            });
            for (var i = 0; i < traps.length; i++) {
                var trap = traps[i];
                if (activeFocusTraps.indexOf(trap) === -1) {
                    // Save previously focused element for restoration
                    if (activeFocusTraps.length === 0) {
                        previouslyFocused = document.activeElement;
                    }
                    activeFocusTraps.push(trap);
                    // Make container focusable as fallback (per Radix: tabIndex=-1)
                    if (!trap.hasAttribute("tabindex")) {
                        trap.setAttribute("tabindex", "-1");
                    }
                    // Auto-focus first focusable (exclude links per Radix)
                    var focusable = getFocusableElements(trap).filter(function(el) {
                        return el.tagName !== "A";
                    });
                    if (focusable.length === 0) focusable = getFocusableElements(trap);
                    if (focusable.length > 0) {
                        setTimeout(function(el) { el.focus({ preventScroll: true }); }, 0, focusable[0]);
                    } else {
                        setTimeout(function(el) { el.focus({ preventScroll: true }); }, 0, trap);
                    }
                }
            }
            // Restore focus when all traps are removed (per Radix unmount behavior)
            if (activeFocusTraps.length === 0 && previouslyFocused) {
                setTimeout(function() {
                    if (previouslyFocused && previouslyFocused.focus) {
                        previouslyFocused.focus({ preventScroll: true });
                    }
                    previouslyFocused = null;
                }, 0);
            }
        }

        // --- DismissableLayer ---
        // Dismisses on Escape key or outside click.
        // Activated by: data-sparrow-dismissable="<element-id>"
        // Sends a dismiss event to the server.

        document.addEventListener("keydown", function(e) {
            if (e.key !== "Escape") return;
            var dismissables = document.querySelectorAll("[data-sparrow-dismissable]");
            if (dismissables.length === 0) return;
            // Dismiss the topmost (last in DOM order)
            var target = dismissables[dismissables.length - 1];
            var id = target.getAttribute("data-sparrow-dismissable");
            e.preventDefault();
            send({type: "event", id: id, event: "click"});
        });

        // Outside click: use pointerdown with setTimeout to prevent
        // mount-on-click false positives (per Radix). The click that caused
        // the layer to mount would otherwise immediately trigger dismissal.
        document.addEventListener("pointerdown", function(e) {
            // Delay check to next tick so mount-on-click events are ignored
            setTimeout(function() {
                var dismissables = document.querySelectorAll("[data-sparrow-dismissable]");
                for (var i = dismissables.length - 1; i >= 0; i--) {
                    var layer = dismissables[i];
                    if (!document.body.contains(layer)) continue;
                    if (!layer.contains(e.target)) {
                        var id = layer.getAttribute("data-sparrow-dismissable");
                        send({type: "event", id: id, event: "click"});
                        break;
                    }
                }
            }, 0);
        });

        function activateDismissables(_root) {
            // Dismissable layers are event-driven (keydown/pointerdown above).
            // No per-element setup needed.
        }

        // --- RovingFocus ---
        // Arrow key navigation between items in a group.
        // Activated by: data-sparrow-roving="horizontal|vertical" on a container.
        // Items are child elements with [data-sparrow-roving-item].
        // Manages tabindex: active item gets tabindex="0", others get tabindex="-1".

        function activateRovingFocus(root) {
            var groups = root.querySelectorAll("[data-sparrow-roving]");
            for (var i = 0; i < groups.length; i++) {
                var group = groups[i];
                if (group.hasAttribute("data-sparrow-roving-init")) continue;
                group.setAttribute("data-sparrow-roving-init", "");

                var items = Array.prototype.slice.call(
                    group.querySelectorAll("[data-sparrow-roving-item]")
                ).filter(function(el) {
                    return !el.disabled && el.offsetParent !== null;
                });

                if (items.length === 0) continue;

                // Set initial tabindex
                var hasActive = false;
                for (var j = 0; j < items.length; j++) {
                    if (items[j].getAttribute("tabindex") === "0") {
                        hasActive = true;
                    } else {
                        items[j].setAttribute("tabindex", "-1");
                    }
                }
                if (!hasActive && items.length > 0) {
                    items[0].setAttribute("tabindex", "0");
                }

                group.addEventListener("keydown", function(e) {
                    var orientation = this.getAttribute("data-sparrow-roving");
                    var nextKey = orientation === "horizontal" ? "ArrowRight" : "ArrowDown";
                    var prevKey = orientation === "horizontal" ? "ArrowLeft" : "ArrowUp";

                    if (e.key !== nextKey && e.key !== prevKey && e.key !== "Home" && e.key !== "End") return;
                    e.preventDefault();

                    var currentItems = Array.prototype.slice.call(
                        this.querySelectorAll("[data-sparrow-roving-item]")
                    ).filter(function(el) {
                        return !el.disabled && el.offsetParent !== null;
                    });

                    if (currentItems.length === 0) return;

                    var currentIndex = currentItems.indexOf(document.activeElement);
                    var nextIndex;

                    if (e.key === "Home") {
                        nextIndex = 0;
                    } else if (e.key === "End") {
                        nextIndex = currentItems.length - 1;
                    } else if (e.key === nextKey) {
                        nextIndex = currentIndex + 1 >= currentItems.length ? 0 : currentIndex + 1;
                    } else {
                        nextIndex = currentIndex - 1 < 0 ? currentItems.length - 1 : currentIndex - 1;
                    }

                    // Update tabindex
                    for (var k = 0; k < currentItems.length; k++) {
                        currentItems[k].setAttribute("tabindex", k === nextIndex ? "0" : "-1");
                    }
                    currentItems[nextIndex].focus();
                });
            }
        }

        // --- Floating ---
        // Collision-aware positioning for popover/tooltip/menu content.
        // Activated by: data-sparrow-floating="<placement>" on a content element.
        // The trigger element is identified by data-sparrow-floating-trigger on a sibling.
        // Placements: top, bottom, left, right (with auto-flip on collision).

        function activateFloating(root) {
            var floats = root.querySelectorAll("[data-sparrow-floating]");
            for (var i = 0; i < floats.length; i++) {
                var content = floats[i];
                if (content.hasAttribute("data-sparrow-floating-init")) continue;
                content.setAttribute("data-sparrow-floating-init", "");
                positionFloating(content);
            }
        }

        function positionFloating(content) {
            var placement = content.getAttribute("data-sparrow-floating") || "bottom";
            var triggerId = content.getAttribute("data-sparrow-floating-anchor");
            var trigger = triggerId ? document.getElementById(triggerId) : content.previousElementSibling;
            if (!trigger) return;

            var triggerRect = trigger.getBoundingClientRect();
            var gap = 8; // px offset from trigger

            // Position content absolutely relative to viewport, then check collisions
            content.style.position = "fixed";
            content.style.zIndex = "200";

            // First pass: desired position
            var coords = computePosition(triggerRect, content, placement, gap);

            // Collision check: flip if overflows viewport
            var vw = window.innerWidth;
            var vh = window.innerHeight;
            var rect = content.getBoundingClientRect();
            var w = rect.width || 200;
            var h = rect.height || 100;

            if (placement === "bottom" && coords.top + h > vh) {
                coords = computePosition(triggerRect, content, "top", gap);
            } else if (placement === "top" && coords.top < 0) {
                coords = computePosition(triggerRect, content, "bottom", gap);
            } else if (placement === "right" && coords.left + w > vw) {
                coords = computePosition(triggerRect, content, "left", gap);
            } else if (placement === "left" && coords.left < 0) {
                coords = computePosition(triggerRect, content, "right", gap);
            }

            // Shift: keep within viewport horizontally
            if (coords.left < 4) coords.left = 4;
            if (coords.left + w > vw - 4) coords.left = vw - w - 4;

            content.style.top = coords.top + "px";
            content.style.left = coords.left + "px";
        }

        function computePosition(triggerRect, content, placement, gap) {
            var rect = content.getBoundingClientRect();
            var w = rect.width || 200;
            var h = rect.height || 100;
            var result = {top: 0, left: 0};

            switch (placement) {
                case "bottom":
                    result.top = triggerRect.bottom + gap;
                    result.left = triggerRect.left + (triggerRect.width - w) / 2;
                    break;
                case "top":
                    result.top = triggerRect.top - h - gap;
                    result.left = triggerRect.left + (triggerRect.width - w) / 2;
                    break;
                case "right":
                    result.top = triggerRect.top + (triggerRect.height - h) / 2;
                    result.left = triggerRect.right + gap;
                    break;
                case "left":
                    result.top = triggerRect.top + (triggerRect.height - h) / 2;
                    result.left = triggerRect.left - w - gap;
                    break;
            }
            return result;
        }

        // Reposition on scroll/resize
        window.addEventListener("scroll", function() {
            var floats = document.querySelectorAll("[data-sparrow-floating-init]");
            for (var i = 0; i < floats.length; i++) positionFloating(floats[i]);
        }, true);
        window.addEventListener("resize", function() {
            var floats = document.querySelectorAll("[data-sparrow-floating-init]");
            for (var i = 0; i < floats.length; i++) positionFloating(floats[i]);
        });

        // --- Script loader (shared) ---

        function loadScript(url, onLoad) {
            var s = document.createElement("script");
            s.src = url;
            s.onload = onLoad;
            s.onerror = function() { console.error("Sparrow: failed to load " + url); };
            document.head.appendChild(s);
        }

        // --- Rive Animations ---
        // Lazy-loads the Rive WASM runtime from CDN when a RiveAnimation
        // view is first encountered. Subsequent activations reuse the runtime.

        var riveReady = false;
        var riveQueue = [];
        var riveInstances = {};

        function activateRive(root) {
            var els = root.querySelectorAll("[data-sparrow-rive]:not([data-sparrow-rive-init])");
            if (els.length === 0) return;

            function doInit() {
                for (var i = 0; i < els.length; i++) initRiveElement(els[i]);
            }

            if (riveReady) { doInit(); return; }
            riveQueue.push(doInit);
            if (riveQueue.length > 1) return;
            loadScript("https://unpkg.com/@rive-app/canvas@2.27.0", function() {
                riveReady = true;
                for (var i = 0; i < riveQueue.length; i++) riveQueue[i]();
                riveQueue = [];
            });
        }

        function initRiveElement(el) {
            el.setAttribute("data-sparrow-rive-init", "");
            var src = el.getAttribute("data-sparrow-rive");
            var sm = el.getAttribute("data-sparrow-rive-sm");
            var artboard = el.getAttribute("data-sparrow-rive-artboard");
            var fitName = el.getAttribute("data-sparrow-rive-fit") || "contain";
            var autoplay = el.hasAttribute("data-sparrow-rive-autoplay");
            var elId = el.id;

            var fitMap = {
                "contain": rive.Fit.Contain,
                "cover": rive.Fit.Cover,
                "fill": rive.Fit.Fill,
                "fitWidth": rive.Fit.FitWidth,
                "fitHeight": rive.Fit.FitHeight,
                "none": rive.Fit.None,
                "scaleDown": rive.Fit.ScaleDown
            };

            var r = new rive.Rive({
                src: src,
                canvas: el,
                autoplay: autoplay,
                stateMachines: sm ? [sm] : undefined,
                artboard: artboard || undefined,
                layout: new rive.Layout({
                    fit: fitMap[fitName] || rive.Fit.Contain
                }),
                onLoad: function() {
                    r.resizeDrawingSurfaceToCanvas();
                    applyRiveInputs(el, r, sm);
                }
            });

            // Forward Rive Events (custom events authored in the Rive editor) to the server
            if (r.on && rive.EventType) {
                r.on(rive.EventType.RiveEvent, function(event) {
                    if (elId && event.data) {
                        send({type: "event", id: elId, event: "rive", value: event.data.name || ""});
                    }
                });
            }

            riveInstances[elId] = r;
        }

        function applyRiveInputs(el, riveInstance, sm) {
            var inputsAttr = el.getAttribute("data-sparrow-rive-inputs");
            if (!inputsAttr || !sm) return;
            try {
                var inputs = JSON.parse(inputsAttr);
                var smInputs = riveInstance.stateMachineInputs(sm);
                if (!smInputs) return;
                for (var k in inputs) {
                    for (var i = 0; i < smInputs.length; i++) {
                        if (smInputs[i].name === k) {
                            if (inputs[k] === "__trigger__") {
                                smInputs[i].fire();
                            } else {
                                smInputs[i].value = inputs[k];
                            }
                            break;
                        }
                    }
                }
            } catch(e) {}
        }

        // Re-apply inputs after DOM patches (server may have updated state)
        function updateRiveInputs(root) {
            var els = root.querySelectorAll("[data-sparrow-rive-init]");
            for (var i = 0; i < els.length; i++) {
                var el = els[i];
                var r = riveInstances[el.id];
                var sm = el.getAttribute("data-sparrow-rive-sm");
                if (r && sm) applyRiveInputs(el, r, sm);
            }
        }

        // --- Lottie Animations ---
        // Lazy-loads lottie-web from CDN when a LottieAnimation view is
        // first encountered. Uses the bodymovin global for rendering.

        var lottieReady = false;
        var lottieQueue = [];
        var lottieInstances = {};

        function activateLottie(root) {
            var els = root.querySelectorAll("[data-sparrow-lottie]:not([data-sparrow-lottie-init])");
            if (els.length === 0) return;

            function doInit() {
                for (var i = 0; i < els.length; i++) initLottieElement(els[i]);
            }

            if (lottieReady) { doInit(); return; }
            lottieQueue.push(doInit);
            if (lottieQueue.length > 1) return;
            loadScript("https://unpkg.com/lottie-web@5.12.2/build/player/lottie.min.js", function() {
                lottieReady = true;
                for (var i = 0; i < lottieQueue.length; i++) lottieQueue[i]();
                lottieQueue = [];
            });
        }

        function initLottieElement(el) {
            el.setAttribute("data-sparrow-lottie-init", "");
            var src = el.getAttribute("data-sparrow-lottie");
            var loop = el.hasAttribute("data-sparrow-lottie-loop");
            var autoplay = el.hasAttribute("data-sparrow-lottie-autoplay");
            var speed = parseFloat(el.getAttribute("data-sparrow-lottie-speed") || "1");
            var rendererType = el.getAttribute("data-sparrow-lottie-renderer") || "svg";
            var direction = parseInt(el.getAttribute("data-sparrow-lottie-direction") || "1", 10);
            var elId = el.id;

            var anim = bodymovin.loadAnimation({
                container: el,
                renderer: rendererType,
                loop: loop,
                autoplay: autoplay,
                path: src
            });

            anim.setSpeed(speed);
            anim.setDirection(direction);

            anim.addEventListener("complete", function() {
                if (elId) send({type: "event", id: elId, event: "lottie", value: "complete"});
            });

            anim.addEventListener("loopComplete", function() {
                if (elId) send({type: "event", id: elId, event: "lottie", value: "loopComplete"});
            });

            lottieInstances[elId] = anim;
        }

        // --- Presence ---
        // Handles enter/exit animations for elements that appear/disappear.
        // Supports multi-class transitions and from/to class swapping.
        // data-sparrow-enter: space-separated classes to ADD on enter
        // data-sparrow-enter-from: space-separated classes to REMOVE on enter
        // data-sparrow-exit: space-separated classes to ADD on exit
        // data-sparrow-exit-from: space-separated classes to REMOVE on exit

        function splitClasses(str) {
            return str ? str.split(" ").filter(Boolean) : [];
        }

        function activatePresence(root) {
            var enters = root.querySelectorAll("[data-sparrow-enter]");
            for (var i = 0; i < enters.length; i++) {
                var el = enters[i];
                if (el.hasAttribute("data-sparrow-entered")) continue;
                el.setAttribute("data-sparrow-entered", "");
                var toAdd = splitClasses(el.getAttribute("data-sparrow-enter"));
                var toRemove = splitClasses(el.getAttribute("data-sparrow-enter-from"));
                // Apply on next frame so the transition triggers from the initial state
                requestAnimationFrame(function(element, add, remove) {
                    return function() {
                        for (var j = 0; j < remove.length; j++) element.classList.remove(remove[j]);
                        for (var j = 0; j < add.length; j++) element.classList.add(add[j]);
                    };
                }(el, toAdd, toRemove));
            }
        }

        // Override applyPatch to handle exit animations and withAnimation
        var _originalApplyPatch = applyPatch;
        applyPatch = function(patch) {
            // Handle withAnimation: add transition CSS before applying the patch
            if (patch.animation) {
                var root = document.getElementById("sparrow-root");
                if (root) {
                    root.style.setProperty("--sp-animation", patch.animation);
                    root.classList.add("sp-animating");
                    // Remove after transitions settle
                    setTimeout(function() {
                        root.classList.remove("sp-animating");
                        root.style.removeProperty("--sp-animation");
                    }, 1000);
                }
            }

            // Handle content transitions
            if (patch.op === "replace") {
                var targetId = patch.target.replace("#", "");
                var el = document.getElementById(targetId);
                if (el) {
                    var ct = el.querySelector("[data-sparrow-content-transition]");
                    if (ct) {
                        applyContentTransition(ct, patch, _originalApplyPatch);
                        return;
                    }
                }
            }

            if (patch.op === "remove") {
                var targetId2 = patch.target.replace("#", "");
                var el2 = document.getElementById(targetId2);
                if (el2 && el2.hasAttribute("data-sparrow-exit")) {
                    var exitAdd = splitClasses(el2.getAttribute("data-sparrow-exit"));
                    var exitRemove = splitClasses(el2.getAttribute("data-sparrow-exit-from"));
                    for (var j = 0; j < exitRemove.length; j++) el2.classList.remove(exitRemove[j]);
                    for (var j = 0; j < exitAdd.length; j++) el2.classList.add(exitAdd[j]);
                    el2.addEventListener("transitionend", function handler() {
                        el2.removeEventListener("transitionend", handler);
                        el2.remove();
                    });
                    // Fallback: remove after 500ms if transition doesn't fire
                    setTimeout(function() { if (el2.parentNode) el2.remove(); }, 500);
                    return;
                }
            }
            _originalApplyPatch(patch);
        };

        // --- Content Transitions ---

        function applyContentTransition(el, patch, fallback) {
            var type = el.getAttribute("data-sparrow-content-transition");
            if (type === "opacity") {
                el.style.transition = "opacity 200ms ease";
                el.style.opacity = "0";
                setTimeout(function() {
                    fallback(patch);
                    el.style.opacity = "1";
                    el.addEventListener("transitionend", function handler() {
                        el.removeEventListener("transitionend", handler);
                        el.style.transition = "";
                    });
                }, 200);
            } else if (type === "numericUp" || type === "numericDown") {
                // Quick fade for numeric text
                el.style.transition = "opacity 100ms ease, transform 100ms ease";
                el.style.opacity = "0";
                el.style.transform = type === "numericUp" ? "translateY(8px)" : "translateY(-8px)";
                setTimeout(function() {
                    fallback(patch);
                    el.style.transform = "translateY(0)";
                    el.style.opacity = "1";
                    el.addEventListener("transitionend", function handler() {
                        el.removeEventListener("transitionend", handler);
                        el.style.transition = "";
                        el.style.transform = "";
                    });
                }, 100);
            } else {
                fallback(patch);
            }
        }

        // --- Scroll Transitions ---
        // Uses IntersectionObserver to animate elements when they enter the viewport.

        var scrollObserver = null;

        function activateScrollTransitions(root) {
            var els = root.querySelectorAll("[data-sparrow-scroll-transition]:not([data-sparrow-scroll-init])");
            if (els.length === 0) return;

            if (!scrollObserver) {
                scrollObserver = new IntersectionObserver(function(entries) {
                    for (var i = 0; i < entries.length; i++) {
                        if (entries[i].isIntersecting) {
                            var el = entries[i].target;
                            var toAdd = splitClasses(el.getAttribute("data-sparrow-scroll-to"));
                            var toRemove = splitClasses(el.getAttribute("data-sparrow-scroll-from"));
                            for (var j = 0; j < toRemove.length; j++) el.classList.remove(toRemove[j]);
                            for (var j = 0; j < toAdd.length; j++) el.classList.add(toAdd[j]);
                            scrollObserver.unobserve(el);
                        }
                    }
                }, { threshold: 0.1 });
            }

            for (var i = 0; i < els.length; i++) {
                els[i].setAttribute("data-sparrow-scroll-init", "");
                scrollObserver.observe(els[i]);
            }
        }

        // --- View Transitions (navigation) ---
        // Wraps page/content replacements in document.startViewTransition()
        // when the API is available, enabling matched geometry and page transitions.

        function withViewTransition(fn) {
            if (document.startViewTransition) {
                document.startViewTransition(fn);
            } else {
                fn();
            }
        }

        // Hook into DOM patching to activate primitives after patches
        var _originalApplyPatches = applyPatches;
        applyPatches = function(patches) {
            _originalApplyPatches(patches);
            var root = document.getElementById("sparrow-root");
            if (root) activatePrimitives(root);
        };

        var _originalReplacePage = replacePage;
        replacePage = function(msg) {
            withViewTransition(function() {
                _originalReplacePage(msg);
                var root = document.getElementById("sparrow-root");
                if (root) activatePrimitives(root);
            });
        };

        var _originalReplaceContent = replaceContent;
        replaceContent = function(msg) {
            withViewTransition(function() {
                _originalReplaceContent(msg);
            });
        };

        // =======================================
        // END BEHAVIORAL PRIMITIVES
        // =======================================

        // --- Boot ---

        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", function() {
                setupEventDelegation();
                connect();
                var root = document.getElementById("sparrow-root");
                if (root) activatePrimitives(root);
            });
        } else {
            setupEventDelegation();
            connect();
            var root = document.getElementById("sparrow-root");
            if (root) activatePrimitives(root);
        }
    })();
    </script>
    """
}
