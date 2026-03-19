import Foundation

/// Injects a dev-reload script into HTML pages when SPARROW_DEV=1.
/// Polls /_sparrow/build-id (the server PID). When it changes, the page reloads.
enum DevReload {
    static let isDevMode = ProcessInfo.processInfo.environment["SPARROW_DEV"] == "1"

    static var scriptTag: String {
        guard isDevMode else { return "" }
        return """

                <script>
                (function() {
                    var buildId = null;
                    var indicator = null;

                    function showIndicator() {
                        if (indicator) return;
                        indicator = document.createElement('div');
                        indicator.style.cssText = 'position:fixed;top:0;left:0;right:0;padding:8px;background:#1a1a2e;color:#e0e0e0;text-align:center;font-family:system-ui;font-size:14px;z-index:99999';
                        indicator.textContent = 'Reloading...';
                        document.body.appendChild(indicator);
                    }

                    setInterval(function() {
                        fetch('/_sparrow/build-id').then(function(r) {
                            return r.text();
                        }).then(function(id) {
                            if (!buildId) { buildId = id; return; }
                            if (id !== buildId) location.reload();
                        }).catch(function() {
                            if (buildId) showIndicator();
                        });
                    }, 300);
                })();
                </script>
        """
    }
}
