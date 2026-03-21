/// Self-contained preview chrome HTML page. Served at /_preview/.
/// Includes toolbar (file selector, viewport presets, resize), preview area,
/// and WebSocket client for live interactivity.
enum PreviewChrome {
    static func html(stylesheet: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>Sparrow Preview</title>
            <style>
            /* Chrome UI styles */
            *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
            html, body { height: 100%; overflow: hidden; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
                background: #111116;
                color: #e0e0e0;
                display: flex;
                flex-direction: column;
            }

            /* Toolbar */
            .toolbar {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 8px 16px;
                background: #1a1a2e;
                border-bottom: 1px solid #2a2a3e;
                flex-shrink: 0;
                min-height: 44px;
            }
            .toolbar select, .toolbar input, .toolbar button {
                font-family: inherit;
                font-size: 13px;
                background: #252538;
                color: #e0e0e0;
                border: 1px solid #3a3a4e;
                border-radius: 6px;
                padding: 4px 8px;
                outline: none;
            }
            .toolbar select:focus, .toolbar input:focus, .toolbar button:focus {
                border-color: #6366f1;
            }
            .toolbar button { cursor: pointer; }
            .toolbar button:hover { background: #3a3a4e; }
            .toolbar button.active {
                background: #6366f1;
                border-color: #6366f1;
                color: #fff;
            }
            .toolbar .separator {
                width: 1px;
                height: 24px;
                background: #3a3a4e;
                flex-shrink: 0;
            }
            .toolbar .width-display {
                width: 60px;
                text-align: center;
                font-variant-numeric: tabular-nums;
            }
            .toolbar .spacer { flex: 1; }

            /* Variant tabs */
            .variant-tabs {
                display: flex;
                gap: 0;
                padding: 0 16px;
                background: #1a1a2e;
                border-bottom: 1px solid #2a2a3e;
                flex-shrink: 0;
            }
            .variant-tabs.hidden { display: none; }
            .variant-tab {
                padding: 8px 16px;
                font-size: 13px;
                color: #888;
                cursor: pointer;
                border-bottom: 2px solid transparent;
                background: none;
                border-top: none;
                border-left: none;
                border-right: none;
                font-family: inherit;
            }
            .variant-tab:hover { color: #ccc; }
            .variant-tab.active {
                color: #e0e0e0;
                border-bottom-color: #6366f1;
            }

            /* Preview area */
            .preview-area {
                flex: 1;
                display: flex;
                justify-content: center;
                overflow: auto;
                padding: 24px;
                position: relative;
            }

            /* Preview frame with resize handle */
            .preview-frame {
                background: #fff;
                border-radius: 8px;
                overflow: hidden;
                position: relative;
                height: fit-content;
                min-height: 100px;
                box-shadow: 0 0 0 1px rgba(255,255,255,0.06), 0 8px 32px rgba(0,0,0,0.4);
            }
            .preview-content {
                min-height: 50px;
            }

            /* Component layout: each variant in its own frame */
            .variant-frame {
                padding: 16px;
                border-bottom: 1px solid #e5e7eb;
                position: relative;
            }
            .variant-frame:last-child { border-bottom: none; }
            .variant-label {
                position: absolute;
                top: 4px;
                right: 8px;
                font-size: 11px;
                color: #9ca3af;
                font-family: -apple-system, monospace;
            }

            /* Resize handle */
            .resize-handle {
                position: absolute;
                top: 0;
                right: -6px;
                width: 12px;
                height: 100%;
                cursor: col-resize;
                z-index: 10;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .resize-handle::after {
                content: '';
                width: 4px;
                height: 32px;
                background: #3a3a4e;
                border-radius: 2px;
            }
            .resize-handle:hover::after { background: #6366f1; }

            /* Status indicators */
            .status-bar {
                padding: 6px 16px;
                background: #1a1a2e;
                border-top: 1px solid #2a2a3e;
                font-size: 12px;
                color: #666;
                flex-shrink: 0;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .status-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background: #22c55e;
            }
            .status-dot.error { background: #ef4444; }
            .status-dot.building { background: #eab308; }

            /* Error overlay */
            .error-overlay {
                position: absolute;
                inset: 0;
                background: rgba(0,0,0,0.85);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 100;
            }
            .error-overlay.hidden { display: none; }
            .error-content {
                max-width: 600px;
                padding: 24px;
                background: #1a1a2e;
                border-radius: 8px;
                border: 1px solid #ef4444;
            }
            .error-content h3 { color: #ef4444; margin-bottom: 8px; }
            .error-content pre {
                font-size: 12px;
                color: #ccc;
                white-space: pre-wrap;
                max-height: 300px;
                overflow: auto;
            }

            /* No previews state */
            .empty-state {
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100%;
                color: #666;
                font-size: 14px;
            }
            </style>
            <style id="sparrow-styles">
            \(stylesheet)
            </style>
        </head>
        <body>
            <div class="toolbar">
                <select id="file-select" title="File"></select>
                <select id="preview-select" title="Preview"></select>
                <div class="separator"></div>
                <button id="btn-mobile" title="Mobile (375px)">Mobile</button>
                <button id="btn-tablet" title="Tablet (768px)">Tablet</button>
                <button id="btn-desktop" title="Desktop (1280px)" class="active">Desktop</button>
                <div class="separator"></div>
                <input id="width-input" class="width-display" type="number" value="1280" min="200" max="2560" title="Viewport width">
                <span style="font-size:12px;color:#666">px</span>
                <div class="spacer"></div>
                <span id="status-text" style="font-size:12px;color:#666">Connecting...</span>
            </div>
            <div class="variant-tabs hidden" id="variant-tabs"></div>
            <div class="preview-area" id="preview-area">
                <div class="preview-frame" id="preview-frame" style="width:1280px">
                    <div class="preview-content" id="preview-content">
                        <div class="empty-state">Connecting to preview server...</div>
                    </div>
                    <div class="resize-handle" id="resize-handle"></div>
                </div>
            </div>
            <div class="error-overlay hidden" id="error-overlay">
                <div class="error-content">
                    <h3>Build Error</h3>
                    <pre id="error-details"></pre>
                </div>
            </div>
            <div class="status-bar">
                <div class="status-dot" id="status-dot"></div>
                <span id="status-bar-text">Ready</span>
            </div>

            <script>
            (function() {
                "use strict";

                // State
                var ws = null;
                var reconnectAttempts = 0;
                var reconnectTimer = null;
                var files = [];
                var currentPreview = null;
                var currentVariant = 0;
                var viewportWidth = 1280;

                // DOM elements
                var fileSelect = document.getElementById("file-select");
                var previewSelect = document.getElementById("preview-select");
                var previewFrame = document.getElementById("preview-frame");
                var previewContent = document.getElementById("preview-content");
                var variantTabs = document.getElementById("variant-tabs");
                var widthInput = document.getElementById("width-input");
                var statusText = document.getElementById("status-text");
                var statusDot = document.getElementById("status-dot");
                var statusBarText = document.getElementById("status-bar-text");
                var errorOverlay = document.getElementById("error-overlay");
                var errorDetails = document.getElementById("error-details");
                var btnMobile = document.getElementById("btn-mobile");
                var btnTablet = document.getElementById("btn-tablet");
                var btnDesktop = document.getElementById("btn-desktop");

                // --- WebSocket ---

                function connect() {
                    var proto = location.protocol === "https:" ? "wss:" : "ws:";
                    var url = proto + "//" + location.host + "/_preview/ws";
                    ws = new WebSocket(url);

                    ws.onopen = function() {
                        reconnectAttempts = 0;
                        statusText.textContent = "Connected";
                        statusDot.className = "status-dot";
                        statusBarText.textContent = "Ready";
                        errorOverlay.classList.add("hidden");

                        // If URL has ?file= param, request that file
                        var params = new URLSearchParams(location.search);
                        var file = params.get("file");
                        if (file) {
                            send({type: "preview:setFile", path: file});
                        }
                    };

                    ws.onmessage = function(e) {
                        var msg;
                        try { msg = JSON.parse(e.data); } catch(_) { return; }
                        handleMessage(msg);
                    };

                    ws.onclose = function() {
                        statusText.textContent = "Disconnected";
                        statusDot.className = "status-dot error";
                        scheduleReconnect();
                    };

                    ws.onerror = function() {};
                }

                function send(obj) {
                    if (ws && ws.readyState === WebSocket.OPEN) {
                        ws.send(JSON.stringify(obj));
                    }
                }

                function scheduleReconnect() {
                    if (reconnectTimer) return;
                    var delay = Math.min(100 * Math.pow(2, reconnectAttempts), 5000);
                    reconnectAttempts++;
                    reconnectTimer = setTimeout(function() {
                        reconnectTimer = null;
                        connect();
                    }, delay);
                }

                // --- Message handling ---

                function handleMessage(msg) {
                    switch (msg.type) {
                        case "preview:render":
                            handleRender(msg);
                            break;
                        case "preview:filesUpdated":
                            if (msg.files) {
                                files = msg.files;
                                updateFileSelect();
                            }
                            break;
                        case "preview:building":
                            statusDot.className = "status-dot building";
                            statusBarText.textContent = "Building...";
                            break;
                        case "preview:ready":
                            statusDot.className = "status-dot";
                            statusBarText.textContent = "Ready";
                            errorOverlay.classList.add("hidden");
                            break;
                        case "preview:error":
                            statusDot.className = "status-dot error";
                            statusBarText.textContent = "Build error";
                            errorDetails.textContent = msg.details || msg.message || "Unknown error";
                            errorOverlay.classList.remove("hidden");
                            break;
                        case "patch":
                            handlePatch(msg);
                            break;
                        case "pong":
                            break;
                    }
                }

                function handleRender(msg) {
                    if (!msg.preview) {
                        previewContent.innerHTML = '<div class="empty-state">No previews found</div>';
                        return;
                    }

                    currentPreview = msg.preview;
                    currentVariant = 0;
                    var layout = msg.preview.layout || "component";
                    var variants = msg.preview.variants || [];

                    if (layout === "component") {
                        // Show all variants stacked
                        variantTabs.classList.add("hidden");
                        var html = "";
                        for (var i = 0; i < variants.length; i++) {
                            html += '<div class="variant-frame" id="variant-' + i + '">';
                            html += '<span class="variant-label">Variant ' + i + '</span>';
                            html += '<div id="sparrow-root-' + i + '">' + variants[i].html + '</div>';
                            html += '</div>';
                        }
                        previewContent.innerHTML = html;
                    } else {
                        // Full page: tabs + single variant
                        variantTabs.classList.remove("hidden");
                        var tabsHtml = "";
                        for (var i = 0; i < variants.length; i++) {
                            var active = i === 0 ? " active" : "";
                            tabsHtml += '<button class="variant-tab' + active + '" data-variant="' + i + '">Variant ' + (i + 1) + '</button>';
                        }
                        variantTabs.innerHTML = tabsHtml;

                        if (variants.length > 0) {
                            previewContent.innerHTML = '<div id="sparrow-root-0">' + variants[0].html + '</div>';
                        }
                    }

                    // Update file info in status
                    if (msg.file) {
                        var fileName = msg.file.split("/").pop();
                        statusBarText.textContent = fileName + " — " + msg.preview.name;
                    }

                    setupEventDelegation();
                }

                function handlePatch(msg) {
                    var variantIdx = msg.variant || 0;
                    var rootId = "sparrow-root-" + variantIdx;
                    var patches = msg.patches || [];

                    // Preserve focus
                    var focused = document.activeElement;
                    var focusId = focused ? focused.id : null;
                    var selStart = null, selEnd = null;
                    if (focused && (focused.tagName === "INPUT" || focused.tagName === "TEXTAREA")) {
                        selStart = focused.selectionStart;
                        selEnd = focused.selectionEnd;
                    }

                    for (var i = 0; i < patches.length; i++) {
                        var patch = patches[i];
                        var target = patch.target.replace("#", "");
                        // Remap sparrow-root to the variant-specific root
                        if (target === "sparrow-root") {
                            target = rootId;
                        }
                        var el = document.getElementById(target);
                        if (!el) continue;

                        switch (patch.op) {
                            case "replace":
                                if (target === rootId) {
                                    el.innerHTML = patch.html;
                                } else {
                                    el.outerHTML = patch.html;
                                }
                                break;
                            case "text":
                                el.textContent = patch.value;
                                break;
                            case "remove":
                                el.remove();
                                break;
                        }
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

                // --- Event delegation ---

                function setupEventDelegation() {
                    // Remove old listeners by replacing the content wrapper
                    // (listeners are on the content element, which is replaced on each render)

                    previewContent.addEventListener("click", function(e) {
                        var target = e.target.closest('[data-sparrow-event*="click"]');
                        if (target && target.id) {
                            e.preventDefault();
                            var variant = findVariantForElement(target);
                            send({type: "event", id: target.id, event: "click", variant: variant});
                        }
                    });

                    var debounceTimers = {};
                    previewContent.addEventListener("input", function(e) {
                        var target = e.target.closest('[data-sparrow-event*="input"]');
                        if (target && target.id) {
                            var delay = parseInt(target.getAttribute("data-sparrow-debounce") || "300", 10);
                            clearTimeout(debounceTimers[target.id]);
                            var variant = findVariantForElement(target);
                            debounceTimers[target.id] = setTimeout(function() {
                                send({type: "event", id: target.id, event: "input", value: target.value, variant: variant});
                            }, delay);
                        }
                    });

                    previewContent.addEventListener("change", function(e) {
                        var target = e.target.closest('[data-sparrow-event*="change"]');
                        if (target && target.id) {
                            var value = target.type === "checkbox" ? String(target.checked) : target.value;
                            var variant = findVariantForElement(target);
                            send({type: "event", id: target.id, event: "change", value: value, variant: variant});
                        }
                    });
                }

                function findVariantForElement(el) {
                    // Walk up to find which variant root this element belongs to
                    var node = el;
                    while (node && node !== previewContent) {
                        if (node.id && node.id.startsWith("sparrow-root-")) {
                            return parseInt(node.id.replace("sparrow-root-", ""), 10);
                        }
                        // Also check parent variant-frame
                        if (node.id && node.id.startsWith("variant-")) {
                            return parseInt(node.id.replace("variant-", ""), 10);
                        }
                        node = node.parentElement;
                    }
                    return 0;
                }

                // --- Toolbar interactions ---

                // Viewport presets
                function setViewport(width) {
                    viewportWidth = width;
                    previewFrame.style.width = width + "px";
                    widthInput.value = width;
                    btnMobile.classList.toggle("active", width === 375);
                    btnTablet.classList.toggle("active", width === 768);
                    btnDesktop.classList.toggle("active", width === 1280);
                }

                btnMobile.addEventListener("click", function() { setViewport(375); });
                btnTablet.addEventListener("click", function() { setViewport(768); });
                btnDesktop.addEventListener("click", function() { setViewport(1280); });

                widthInput.addEventListener("change", function() {
                    var w = parseInt(widthInput.value, 10);
                    if (w >= 200 && w <= 2560) {
                        setViewport(w);
                    }
                });

                // File selector
                fileSelect.addEventListener("change", function() {
                    send({type: "preview:setFile", path: fileSelect.value});
                });

                // Preview selector
                previewSelect.addEventListener("change", function() {
                    send({type: "preview:setPreview", id: previewSelect.value});
                });

                // Variant tabs
                variantTabs.addEventListener("click", function(e) {
                    var tab = e.target.closest(".variant-tab");
                    if (!tab) return;
                    var idx = parseInt(tab.getAttribute("data-variant"), 10);
                    currentVariant = idx;

                    // Update tab styles
                    var tabs = variantTabs.querySelectorAll(".variant-tab");
                    for (var i = 0; i < tabs.length; i++) {
                        tabs[i].classList.toggle("active", i === idx);
                    }

                    // Show the selected variant
                    if (currentPreview && currentPreview.variants && currentPreview.variants[idx]) {
                        previewContent.innerHTML = '<div id="sparrow-root-' + idx + '">' + currentPreview.variants[idx].html + '</div>';
                        setupEventDelegation();
                    }
                });

                // --- Resize handle ---

                var resizeHandle = document.getElementById("resize-handle");
                var isResizing = false;
                var startX = 0;
                var startWidth = 0;

                resizeHandle.addEventListener("mousedown", function(e) {
                    isResizing = true;
                    startX = e.clientX;
                    startWidth = previewFrame.offsetWidth;
                    document.body.style.cursor = "col-resize";
                    document.body.style.userSelect = "none";
                    e.preventDefault();
                });

                document.addEventListener("mousemove", function(e) {
                    if (!isResizing) return;
                    var diff = e.clientX - startX;
                    var newWidth = Math.max(200, Math.min(2560, startWidth + diff));
                    previewFrame.style.width = newWidth + "px";
                    widthInput.value = newWidth;
                    // Clear active preset
                    btnMobile.classList.remove("active");
                    btnTablet.classList.remove("active");
                    btnDesktop.classList.remove("active");
                    if (newWidth === 375) btnMobile.classList.add("active");
                    if (newWidth === 768) btnTablet.classList.add("active");
                    if (newWidth === 1280) btnDesktop.classList.add("active");
                });

                document.addEventListener("mouseup", function() {
                    if (isResizing) {
                        isResizing = false;
                        document.body.style.cursor = "";
                        document.body.style.userSelect = "";
                        viewportWidth = previewFrame.offsetWidth;
                    }
                });

                // --- File list population ---

                function updateFileSelect() {
                    fileSelect.innerHTML = "";
                    for (var i = 0; i < files.length; i++) {
                        var opt = document.createElement("option");
                        opt.value = files[i].path;
                        opt.textContent = files[i].path.split("/").pop();
                        fileSelect.appendChild(opt);
                    }
                }

                // Fetch initial file list
                fetch("/_preview/files").then(function(r) { return r.json(); }).then(function(data) {
                    files = data.files || [];
                    updateFileSelect();
                }).catch(function() {});

                // --- Heartbeat ---
                setInterval(function() { send({type: "ping"}); }, 30000);

                // --- Boot ---
                connect();
            })();
            </script>
        </body>
        </html>
        """
    }
}
