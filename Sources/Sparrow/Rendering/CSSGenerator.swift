/// Generates the default Sparrow CSS stylesheet.
public enum CSSGenerator {
    public static let defaultStylesheet: String = """
    /* Sparrow Default Stylesheet */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
        --color-primary: #007AFF;
        --color-secondary: #5856D6;
        --color-accent: #FF9500;
        --color-background: #FFFFFF;
        --color-surface: #F2F2F7;
        --color-surfaceSecondary: #E5E5EA;
        --color-text: #000000;
        --color-textSecondary: rgba(60, 60, 67, 0.6);
        --color-textTertiary: rgba(60, 60, 67, 0.3);
        --color-error: #FF3B30;
        --color-success: #34C759;
        --color-warning: #FF9500;
        --color-info: #5AC8FA;
        --color-red: #FF3B30;
        --color-orange: #FF9500;
        --color-yellow: #FFCC00;
        --color-green: #34C759;
        --color-mint: #00C7BE;
        --color-teal: #30B0C7;
        --color-cyan: #32ADE6;
        --color-blue: #007AFF;
        --color-indigo: #5856D6;
        --color-purple: #AF52DE;
        --color-pink: #FF2D55;
        --color-brown: #A2845E;
        --color-gray: #8E8E93;
        --color-white: #FFFFFF;
        --color-black: #000000;
        --color-clear: transparent;
        --spacing-0: 0px;
        --spacing-1: 4px;
        --spacing-2: 8px;
        --spacing-3: 12px;
        --spacing-4: 16px;
        --spacing-5: 20px;
        --spacing-6: 24px;
        --spacing-8: 32px;
        --spacing-10: 40px;
        --spacing-12: 48px;
        --spacing-16: 64px;
        --radius-none: 0px;
        --radius-sm: 4px;
        --radius-md: 8px;
        --radius-lg: 12px;
        --radius-xl: 16px;
        --radius-2xl: 24px;
        --radius-full: 9999px;
        --shadow-none: none;
        --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
        --shadow-md: 0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06);
        --shadow-lg: 0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05);
        --shadow-xl: 0 20px 25px rgba(0,0,0,0.1), 0 8px 10px rgba(0,0,0,0.04);
        --font-body: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    }

    @media (prefers-color-scheme: dark) {
        :root {
            --color-primary: #0A84FF;
            --color-secondary: #5E5CE6;
            --color-accent: #FF9F0A;
            --color-background: #000000;
            --color-surface: #1C1C1E;
            --color-surfaceSecondary: #2C2C2E;
            --color-text: #FFFFFF;
            --color-textSecondary: rgba(235, 235, 245, 0.6);
            --color-textTertiary: rgba(235, 235, 245, 0.3);
            --color-error: #FF453A;
            --color-success: #30D158;
            --color-warning: #FF9F0A;
            --color-info: #64D2FF;
            --color-red: #FF453A;
            --color-orange: #FF9F0A;
            --color-yellow: #FFD60A;
            --color-green: #30D158;
            --color-mint: #63E6E2;
            --color-teal: #40CBE0;
            --color-cyan: #64D2FF;
            --color-blue: #0A84FF;
            --color-indigo: #5E5CE6;
            --color-purple: #BF5AF2;
            --color-pink: #FF375F;
            --color-brown: #AC8E68;
            --color-gray: #8E8E93;
        }
    }

    body {
        font: 400 17px/1.5 var(--font-body);
        color: var(--color-text);
        background: var(--color-background);
    }

    #sparrow-root {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }

    /* Layout */
    .flex { display: flex; }
    .flex-col { flex-direction: column; }
    .flex-row { flex-direction: row; }
    .flex-grow { flex-grow: 1; }
    .items-start { align-items: flex-start; }
    .items-center { align-items: center; }
    .items-end { align-items: flex-end; }

    /* Gap (spacing tokens) */
    .gap-0 { gap: var(--spacing-0); }
    .gap-1 { gap: var(--spacing-1); }
    .gap-2 { gap: var(--spacing-2); }
    .gap-3 { gap: var(--spacing-3); }
    .gap-4 { gap: var(--spacing-4); }
    .gap-5 { gap: var(--spacing-5); }
    .gap-6 { gap: var(--spacing-6); }
    .gap-8 { gap: var(--spacing-8); }
    .gap-10 { gap: var(--spacing-10); }
    .gap-12 { gap: var(--spacing-12); }
    .gap-16 { gap: var(--spacing-16); }

    /* Padding */
    .p-0 { padding: var(--spacing-0); }
    .p-1 { padding: var(--spacing-1); }
    .p-2 { padding: var(--spacing-2); }
    .p-3 { padding: var(--spacing-3); }
    .p-4 { padding: var(--spacing-4); }
    .p-5 { padding: var(--spacing-5); }
    .p-6 { padding: var(--spacing-6); }
    .p-8 { padding: var(--spacing-8); }
    .p-10 { padding: var(--spacing-10); }
    .p-12 { padding: var(--spacing-12); }
    .p-16 { padding: var(--spacing-16); }
    .px-4 { padding-left: var(--spacing-4); padding-right: var(--spacing-4); }
    .py-4 { padding-top: var(--spacing-4); padding-bottom: var(--spacing-4); }
    .pt-2 { padding-top: var(--spacing-2); }
    .pb-2 { padding-bottom: var(--spacing-2); }
    .pl-4 { padding-left: var(--spacing-4); }
    .pr-4 { padding-right: var(--spacing-4); }

    /* Typography */
    .font-largeTitle { font: 700 34px/1.2 var(--font-body); }
    .font-title { font: 700 28px/1.2 var(--font-body); }
    .font-title2 { font: 700 22px/1.3 var(--font-body); }
    .font-title3 { font: 600 20px/1.3 var(--font-body); }
    .font-headline { font: 600 17px/1.4 var(--font-body); }
    .font-body { font: 400 17px/1.5 var(--font-body); }
    .font-callout { font: 400 16px/1.5 var(--font-body); }
    .font-subheadline { font: 400 15px/1.4 var(--font-body); }
    .font-footnote { font: 400 13px/1.4 var(--font-body); }
    .font-caption { font: 400 12px/1.3 var(--font-body); }

    /* Foreground colors */
    .fg-primary { color: var(--color-primary); }
    .fg-secondary { color: var(--color-secondary); }
    .fg-accent { color: var(--color-accent); }
    .fg-text { color: var(--color-text); }
    .fg-textSecondary { color: var(--color-textSecondary); }
    .fg-textTertiary { color: var(--color-textTertiary); }
    .fg-error { color: var(--color-error); }
    .fg-success { color: var(--color-success); }
    .fg-warning { color: var(--color-warning); }
    .fg-info { color: var(--color-info); }
    .fg-red { color: var(--color-red); }
    .fg-orange { color: var(--color-orange); }
    .fg-yellow { color: var(--color-yellow); }
    .fg-green { color: var(--color-green); }
    .fg-mint { color: var(--color-mint); }
    .fg-teal { color: var(--color-teal); }
    .fg-cyan { color: var(--color-cyan); }
    .fg-blue { color: var(--color-blue); }
    .fg-indigo { color: var(--color-indigo); }
    .fg-purple { color: var(--color-purple); }
    .fg-pink { color: var(--color-pink); }
    .fg-brown { color: var(--color-brown); }
    .fg-gray { color: var(--color-gray); }
    .fg-white { color: var(--color-white); }
    .fg-black { color: var(--color-black); }
    .fg-clear { color: transparent; }

    /* Background colors */
    .bg-primary { background: var(--color-primary); }
    .bg-secondary { background: var(--color-secondary); }
    .bg-surface { background: var(--color-surface); }
    .bg-surfaceSecondary { background: var(--color-surfaceSecondary); }
    .bg-background { background: var(--color-background); }
    .bg-error { background: var(--color-error); }
    .bg-success { background: var(--color-success); }
    .bg-red { background: var(--color-red); }
    .bg-orange { background: var(--color-orange); }
    .bg-yellow { background: var(--color-yellow); }
    .bg-green { background: var(--color-green); }
    .bg-mint { background: var(--color-mint); }
    .bg-teal { background: var(--color-teal); }
    .bg-cyan { background: var(--color-cyan); }
    .bg-blue { background: var(--color-blue); }
    .bg-indigo { background: var(--color-indigo); }
    .bg-purple { background: var(--color-purple); }
    .bg-pink { background: var(--color-pink); }
    .bg-brown { background: var(--color-brown); }
    .bg-gray { background: var(--color-gray); }
    .bg-white { background: var(--color-white); }
    .bg-black { background: var(--color-black); }
    .bg-clear { background: transparent; }

    /* Border radius */
    .rounded-none { border-radius: var(--radius-none); }
    .rounded-sm { border-radius: var(--radius-sm); }
    .rounded-md { border-radius: var(--radius-md); }
    .rounded-lg { border-radius: var(--radius-lg); }
    .rounded-xl { border-radius: var(--radius-xl); }
    .rounded-2xl { border-radius: var(--radius-2xl); }
    .rounded-full { border-radius: var(--radius-full); }

    /* Shadows */
    .shadow-none { box-shadow: var(--shadow-none); }
    .shadow-sm { box-shadow: var(--shadow-sm); }
    .shadow-md { box-shadow: var(--shadow-md); }
    .shadow-lg { box-shadow: var(--shadow-lg); }
    .shadow-xl { box-shadow: var(--shadow-xl); }

    /* Divider */
    .divider { border: none; border-top: 1px solid var(--color-surfaceSecondary); width: 100%; }

    /* Link */
    .link { color: var(--color-primary); text-decoration: none; cursor: pointer; }
    .link:hover { text-decoration: underline; }

    /* Button */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: var(--spacing-2) var(--spacing-4);
        font: 600 17px/1.4 var(--font-body);
        color: var(--color-white);
        background: var(--color-primary);
        border: none;
        border-radius: var(--radius-md);
        cursor: pointer;
        transition: opacity 0.15s ease;
    }

    /* Clip shapes */
    .clip-circle { border-radius: var(--radius-full); aspect-ratio: 1; padding: var(--spacing-2); }
    .btn:hover { opacity: 0.85; }
    .btn:active { opacity: 0.7; }
    .btn:disabled { opacity: 0.4; cursor: not-allowed; }

    /* ZStack */
    .zstack { position: relative; display: grid; }
    .zstack > * { grid-area: 1 / 1; }
    .justify-start { justify-items: start; }
    .justify-center { justify-items: center; }
    .justify-end { justify-items: end; }

    /* ScrollView */
    .scroll { overflow: hidden; }
    .scroll-y { overflow-y: auto; }
    .scroll-x { overflow-x: auto; }
    .scroll-both { overflow: auto; }

    /* Grid */
    .grid { display: grid; }
    .grid-cols-1 { grid-template-columns: repeat(1, 1fr); }
    .grid-cols-2 { grid-template-columns: repeat(2, 1fr); }
    .grid-cols-3 { grid-template-columns: repeat(3, 1fr); }
    .grid-cols-4 { grid-template-columns: repeat(4, 1fr); }
    .grid-cols-5 { grid-template-columns: repeat(5, 1fr); }
    .grid-cols-6 { grid-template-columns: repeat(6, 1fr); }

    /* Label */
    .label { display: inline-flex; align-items: center; gap: var(--spacing-1); }
    .label-icon { display: inline-flex; }

    /* Markdown */
    .markdown { line-height: 1.6; }

    /* Input */
    .input {
        display: block;
        width: 100%;
        padding: var(--spacing-2) var(--spacing-3);
        font: 400 17px/1.5 var(--font-body);
        color: var(--color-text);
        background: var(--color-surface);
        border: 1px solid var(--color-surfaceSecondary);
        border-radius: var(--radius-md);
    }
    .input:focus { outline: 2px solid var(--color-primary); outline-offset: -1px; }

    /* Textarea */
    .textarea {
        display: block;
        width: 100%;
        min-height: 100px;
        padding: var(--spacing-2) var(--spacing-3);
        font: 400 17px/1.5 var(--font-body);
        color: var(--color-text);
        background: var(--color-surface);
        border: 1px solid var(--color-surfaceSecondary);
        border-radius: var(--radius-md);
        resize: vertical;
    }
    .textarea:focus { outline: 2px solid var(--color-primary); outline-offset: -1px; }

    /* Toggle */
    .toggle { display: inline-flex; align-items: center; gap: var(--spacing-2); cursor: pointer; }

    /* Picker */
    .picker {
        display: block;
        width: 100%;
        padding: var(--spacing-2) var(--spacing-3);
        font: 400 17px/1.5 var(--font-body);
        color: var(--color-text);
        background: var(--color-surface);
        border: 1px solid var(--color-surfaceSecondary);
        border-radius: var(--radius-md);
    }

    /* Slider */
    .slider { width: 100%; cursor: pointer; }

    /* Image */
    .img { max-width: 100%; height: auto; }

    /* Icon */
    .icon { display: inline-flex; align-items: center; justify-content: center; }

    /* NavigationLink */
    .nav-link { color: var(--color-primary); text-decoration: none; cursor: pointer; }
    .nav-link:hover { text-decoration: underline; }

    /* List */
    .list { list-style: disc; padding-left: var(--spacing-6); }
    ol.list { list-style: decimal; }

    /* Form */
    .form { display: flex; flex-direction: column; gap: var(--spacing-4); }

    /* Section */
    .section { display: flex; flex-direction: column; gap: var(--spacing-3); }
    .section-header { font: 600 20px/1.3 var(--font-body); }

    /* Card */
    .card {
        background: var(--color-surface);
        border-radius: var(--radius-md);
        padding: var(--spacing-4);
        box-shadow: var(--shadow-sm);
    }

    /* Modal */
    .modal { border: none; border-radius: var(--radius-lg); padding: var(--spacing-6); background: var(--color-background); box-shadow: var(--shadow-xl); }
    .modal::backdrop { background: rgba(0, 0, 0, 0.5); }

    /* Sheet */
    .sheet {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background: var(--color-background);
        border-radius: var(--radius-lg) var(--radius-lg) 0 0;
        padding: var(--spacing-6);
        box-shadow: var(--shadow-xl);
        transform: translateY(100%);
        transition: transform 0.3s ease;
    }
    .sheet-open { transform: translateY(0); }

    /* Menu */
    .menu { position: relative; display: inline-block; }
    .menu-trigger { background: none; border: none; cursor: pointer; font: inherit; color: inherit; }
    .menu-content {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        min-width: 160px;
        background: var(--color-background);
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-lg);
        padding: var(--spacing-1) 0;
        z-index: 100;
    }

    /* Alert */
    .alert {
        padding: var(--spacing-4);
        border-radius: var(--radius-md);
        background: var(--color-surface);
        border-left: 4px solid var(--color-primary);
    }
    .alert-title { font: 600 17px/1.4 var(--font-body); }
    .alert-message { font: 400 15px/1.4 var(--font-body); color: var(--color-textSecondary); margin-top: var(--spacing-1); }

    /* Toast */
    .toast {
        position: fixed;
        bottom: var(--spacing-6);
        left: 50%;
        transform: translateX(-50%);
        padding: var(--spacing-3) var(--spacing-5);
        border-radius: var(--radius-md);
        font: 400 15px/1.4 var(--font-body);
        color: var(--color-white);
        z-index: 1000;
    }
    .toast-info { background: var(--color-info); }
    .toast-success { background: var(--color-success); }
    .toast-warning { background: var(--color-warning); }
    .toast-error { background: var(--color-error); }

    /* Badge */
    .badge {
        display: inline-flex;
        align-items: center;
        padding: var(--spacing-0) var(--spacing-2);
        border-radius: var(--radius-full);
        font: 600 12px/1.3 var(--font-body);
    }
    .badge-default { background: var(--color-surface); color: var(--color-text); }
    .badge-success { background: var(--color-success); color: var(--color-white); }
    .badge-warning { background: var(--color-warning); color: var(--color-white); }
    .badge-error { background: var(--color-error); color: var(--color-white); }
    .badge-info { background: var(--color-info); color: var(--color-white); }

    /* Progress */
    progress { width: 100%; height: 8px; border-radius: var(--radius-full); }
    progress::-webkit-progress-bar { background: var(--color-surface); border-radius: var(--radius-full); }
    progress::-webkit-progress-value { background: var(--color-primary); border-radius: var(--radius-full); }

    /* Spinner */
    .spinner {
        width: 24px;
        height: 24px;
        border: 3px solid var(--color-surface);
        border-top-color: var(--color-primary);
        border-radius: 50%;
        animation: spin 0.6s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    """
}
