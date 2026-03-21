/// Generates the default Sparrow CSS stylesheet using the shadcn/ui design system.
public enum CSSGenerator {
    public static let defaultStylesheet: String = """
    /* Sparrow Stylesheet — shadcn/ui design system */

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    /* ============================================
       THEME VARIABLES — Light
       ============================================ */
    :root {
        --background: hsl(0 0% 100%);
        --foreground: hsl(240 10% 3.9%);
        --card: hsl(0 0% 100%);
        --card-foreground: hsl(240 10% 3.9%);
        --popover: hsl(0 0% 100%);
        --popover-foreground: hsl(240 10% 3.9%);
        --primary: hsl(240 5.9% 10%);
        --primary-foreground: hsl(0 0% 98%);
        --secondary: hsl(240 4.8% 95.9%);
        --secondary-foreground: hsl(240 5.9% 10%);
        --muted: hsl(240 4.8% 95.9%);
        --muted-foreground: hsl(240 3.8% 46.1%);
        --accent: hsl(240 4.8% 95.9%);
        --accent-foreground: hsl(240 5.9% 10%);
        --destructive: hsl(0 84.2% 60.2%);
        --destructive-foreground: hsl(0 0% 98%);
        --border: hsl(240 5.9% 90%);
        --input: hsl(240 5.9% 90%);
        --ring: hsl(240 5.9% 10%);
        --radius: 0.5rem;

        --success: hsl(142.1 76.2% 36.3%);
        --success-foreground: hsl(0 0% 98%);
        --warning: hsl(38 92% 50%);
        --warning-foreground: hsl(48 96% 5%);
        --info: hsl(199 89% 48%);
        --info-foreground: hsl(0 0% 98%);

        --color-red: hsl(0 84.2% 60.2%);
        --color-orange: hsl(24.6 95% 53.1%);
        --color-yellow: hsl(47.9 95.8% 53.1%);
        --color-green: hsl(142.1 76.2% 36.3%);
        --color-mint: hsl(172 67% 45%);
        --color-teal: hsl(189 94% 43%);
        --color-cyan: hsl(199 89% 48%);
        --color-blue: hsl(221.2 83.2% 53.3%);
        --color-indigo: hsl(239 84% 67%);
        --color-purple: hsl(262 83% 58%);
        --color-pink: hsl(330 81% 60%);
        --color-brown: hsl(33 53% 31%);
        --color-gray: hsl(240 3.8% 46.1%);
        --color-white: hsl(0 0% 100%);
        --color-black: hsl(0 0% 0%);
        --color-clear: transparent;

        --sidebar-background: hsl(0 0% 98%);
        --sidebar-foreground: hsl(240 5.3% 26.1%);
        --sidebar-primary: hsl(240 5.9% 10%);
        --sidebar-primary-foreground: hsl(0 0% 98%);
        --sidebar-accent: hsl(240 4.8% 95.9%);
        --sidebar-accent-foreground: hsl(240 5.9% 10%);
        --sidebar-border: hsl(220 13% 91%);
        --sidebar-ring: hsl(240 5.9% 10%);

        --spacing-0: 0;
        --spacing-1: 0.25rem;
        --spacing-2: 0.5rem;
        --spacing-3: 0.75rem;
        --spacing-4: 1rem;
        --spacing-5: 1.25rem;
        --spacing-6: 1.5rem;
        --spacing-8: 2rem;
        --spacing-10: 2.5rem;
        --spacing-12: 3rem;
        --spacing-16: 4rem;

        --shadow-none: none;
        --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
        --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
        --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
        --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);

        --font-body: ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
        --font-heading: var(--font-body);
        --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
    }

    /* ============================================
       THEME VARIABLES — Dark
       ============================================ */
    @media (prefers-color-scheme: dark) {
        :root {
            --background: hsl(240 10% 3.9%);
            --foreground: hsl(0 0% 98%);
            --card: hsl(240 10% 3.9%);
            --card-foreground: hsl(0 0% 98%);
            --popover: hsl(240 10% 3.9%);
            --popover-foreground: hsl(0 0% 98%);
            --primary: hsl(0 0% 98%);
            --primary-foreground: hsl(240 5.9% 10%);
            --secondary: hsl(240 3.7% 15.9%);
            --secondary-foreground: hsl(0 0% 98%);
            --muted: hsl(240 3.7% 15.9%);
            --muted-foreground: hsl(240 5% 64.9%);
            --accent: hsl(240 3.7% 15.9%);
            --accent-foreground: hsl(0 0% 98%);
            --destructive: hsl(0 62.8% 30.6%);
            --destructive-foreground: hsl(0 0% 98%);
            --border: hsl(240 3.7% 15.9%);
            --input: hsl(240 3.7% 15.9%);
            --ring: hsl(240 4.9% 83.9%);

            --success: hsl(142 71% 45%);
            --warning: hsl(48 96% 53%);
            --info: hsl(199 89% 48%);

            --sidebar-background: hsl(240 5.9% 10%);
            --sidebar-foreground: hsl(240 4.8% 95.9%);
            --sidebar-primary: hsl(224.3 76.3% 48%);
            --sidebar-primary-foreground: hsl(0 0% 100%);
            --sidebar-accent: hsl(240 3.7% 15.9%);
            --sidebar-accent-foreground: hsl(240 4.8% 95.9%);
            --sidebar-border: hsl(240 3.7% 15.9%);
            --sidebar-ring: hsl(240 4.9% 83.9%);
        }
    }

    /* ============================================
       BASE
       ============================================ */
    body {
        font: 400 0.875rem/1.5 var(--font-body);
        color: var(--foreground);
        background: var(--background);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
    }

    #sparrow-root {
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
    }

    /* ============================================
       LAYOUT UTILITIES
       ============================================ */
    .flex { display: flex; }
    .flex-col { flex-direction: column; }
    .flex-row { flex-direction: row; }
    .flex-grow { flex-grow: 1; }
    .items-start { align-items: flex-start; }
    .items-center { align-items: center; }
    .items-end { align-items: flex-end; }

    /* Gap */
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
    .px-0 { padding-left: var(--spacing-0); padding-right: var(--spacing-0); }
    .px-1 { padding-left: var(--spacing-1); padding-right: var(--spacing-1); }
    .px-2 { padding-left: var(--spacing-2); padding-right: var(--spacing-2); }
    .px-3 { padding-left: var(--spacing-3); padding-right: var(--spacing-3); }
    .px-4 { padding-left: var(--spacing-4); padding-right: var(--spacing-4); }
    .px-5 { padding-left: var(--spacing-5); padding-right: var(--spacing-5); }
    .px-6 { padding-left: var(--spacing-6); padding-right: var(--spacing-6); }
    .px-8 { padding-left: var(--spacing-8); padding-right: var(--spacing-8); }
    .px-10 { padding-left: var(--spacing-10); padding-right: var(--spacing-10); }
    .px-12 { padding-left: var(--spacing-12); padding-right: var(--spacing-12); }
    .px-16 { padding-left: var(--spacing-16); padding-right: var(--spacing-16); }
    .py-0 { padding-top: var(--spacing-0); padding-bottom: var(--spacing-0); }
    .py-1 { padding-top: var(--spacing-1); padding-bottom: var(--spacing-1); }
    .py-2 { padding-top: var(--spacing-2); padding-bottom: var(--spacing-2); }
    .py-3 { padding-top: var(--spacing-3); padding-bottom: var(--spacing-3); }
    .py-4 { padding-top: var(--spacing-4); padding-bottom: var(--spacing-4); }
    .py-5 { padding-top: var(--spacing-5); padding-bottom: var(--spacing-5); }
    .py-6 { padding-top: var(--spacing-6); padding-bottom: var(--spacing-6); }
    .py-8 { padding-top: var(--spacing-8); padding-bottom: var(--spacing-8); }
    .py-10 { padding-top: var(--spacing-10); padding-bottom: var(--spacing-10); }
    .py-12 { padding-top: var(--spacing-12); padding-bottom: var(--spacing-12); }
    .py-16 { padding-top: var(--spacing-16); padding-bottom: var(--spacing-16); }
    .pt-0 { padding-top: var(--spacing-0); }
    .pt-1 { padding-top: var(--spacing-1); }
    .pt-2 { padding-top: var(--spacing-2); }
    .pt-3 { padding-top: var(--spacing-3); }
    .pt-4 { padding-top: var(--spacing-4); }
    .pt-5 { padding-top: var(--spacing-5); }
    .pt-6 { padding-top: var(--spacing-6); }
    .pt-8 { padding-top: var(--spacing-8); }
    .pt-10 { padding-top: var(--spacing-10); }
    .pt-12 { padding-top: var(--spacing-12); }
    .pt-16 { padding-top: var(--spacing-16); }
    .pb-0 { padding-bottom: var(--spacing-0); }
    .pb-1 { padding-bottom: var(--spacing-1); }
    .pb-2 { padding-bottom: var(--spacing-2); }
    .pb-3 { padding-bottom: var(--spacing-3); }
    .pb-4 { padding-bottom: var(--spacing-4); }
    .pb-5 { padding-bottom: var(--spacing-5); }
    .pb-6 { padding-bottom: var(--spacing-6); }
    .pb-8 { padding-bottom: var(--spacing-8); }
    .pb-10 { padding-bottom: var(--spacing-10); }
    .pb-12 { padding-bottom: var(--spacing-12); }
    .pb-16 { padding-bottom: var(--spacing-16); }
    .pl-0 { padding-left: var(--spacing-0); }
    .pl-1 { padding-left: var(--spacing-1); }
    .pl-2 { padding-left: var(--spacing-2); }
    .pl-3 { padding-left: var(--spacing-3); }
    .pl-4 { padding-left: var(--spacing-4); }
    .pl-5 { padding-left: var(--spacing-5); }
    .pl-6 { padding-left: var(--spacing-6); }
    .pl-8 { padding-left: var(--spacing-8); }
    .pl-10 { padding-left: var(--spacing-10); }
    .pl-12 { padding-left: var(--spacing-12); }
    .pl-16 { padding-left: var(--spacing-16); }
    .pr-0 { padding-right: var(--spacing-0); }
    .pr-1 { padding-right: var(--spacing-1); }
    .pr-2 { padding-right: var(--spacing-2); }
    .pr-3 { padding-right: var(--spacing-3); }
    .pr-4 { padding-right: var(--spacing-4); }
    .pr-5 { padding-right: var(--spacing-5); }
    .pr-6 { padding-right: var(--spacing-6); }
    .pr-8 { padding-right: var(--spacing-8); }
    .pr-10 { padding-right: var(--spacing-10); }
    .pr-12 { padding-right: var(--spacing-12); }
    .pr-16 { padding-right: var(--spacing-16); }

    /* Margin auto */
    .m-auto { margin: auto; }
    .mx-auto { margin-left: auto; margin-right: auto; }
    .my-auto { margin-top: auto; margin-bottom: auto; }
    .mt-auto { margin-top: auto; }
    .mb-auto { margin-bottom: auto; }
    .ml-auto { margin-left: auto; }
    .mr-auto { margin-right: auto; }

    /* ============================================
       TYPOGRAPHY
       ============================================ */
    .font-largeTitle { font-size: 2.25rem; line-height: 2.5rem; font-weight: 700; letter-spacing: -0.025em; font-family: var(--font-heading); }
    .font-title { font-size: 1.875rem; line-height: 2.25rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-heading); }
    .font-title2 { font-size: 1.5rem; line-height: 2rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-heading); }
    .font-title3 { font-size: 1.25rem; line-height: 1.75rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-heading); }
    .font-headline { font-size: 1rem; line-height: 1.5rem; font-weight: 600; font-family: var(--font-heading); }
    .font-body { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-callout { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-subheadline { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-footnote { font-size: 0.75rem; line-height: 1rem; font-weight: 400; font-family: var(--font-body); }
    .font-caption { font-size: 0.75rem; line-height: 1rem; font-weight: 400; color: var(--muted-foreground); font-family: var(--font-body); }

    /* Font weights */
    .font-weight-100 { font-weight: 100; }
    .font-weight-200 { font-weight: 200; }
    .font-weight-300 { font-weight: 300; }
    .font-weight-400 { font-weight: 400; }
    .font-weight-500 { font-weight: 500; }
    .font-weight-600 { font-weight: 600; }
    .font-weight-700 { font-weight: 700; }
    .font-weight-800 { font-weight: 800; }
    .font-weight-900 { font-weight: 900; }

    /* Font style */
    .italic { font-style: italic; }

    /* Text decoration */
    .underline { text-decoration: underline; }
    .line-through { text-decoration: line-through; }

    /* Text transform */
    .text-uppercase { text-transform: uppercase; }
    .text-lowercase { text-transform: lowercase; }
    .text-capitalize { text-transform: capitalize; }

    /* Font design families */
    .font-design-default { font-family: var(--font-body); }
    .font-design-serif { font-family: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif; }
    .font-design-monospaced { font-family: var(--font-mono); }
    .font-design-rounded { font-family: ui-rounded, "SF Pro Rounded", system-ui, sans-serif; }

    /* ============================================
       FOREGROUND COLORS
       ============================================ */
    .fg-primary { color: var(--primary); }
    .fg-secondary { color: var(--muted-foreground); }
    .fg-accent { color: var(--accent-foreground); }
    .fg-background { color: var(--background); }
    .fg-surface { color: var(--muted-foreground); }
    .fg-surfaceSecondary { color: var(--accent-foreground); }
    .fg-text { color: var(--foreground); }
    .fg-textSecondary { color: var(--muted-foreground); }
    .fg-textTertiary { color: var(--muted-foreground); }
    .fg-error { color: var(--destructive); }
    .fg-success { color: var(--success); }
    .fg-warning { color: var(--warning); }
    .fg-info { color: var(--info); }
    .fg-current { color: currentColor; }
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

    /* ============================================
       BACKGROUND COLORS
       ============================================ */
    .bg-primary { background: var(--primary); }
    .bg-secondary { background: var(--secondary); }
    .bg-accent { background: var(--accent); }
    .bg-surface { background: var(--muted); }
    .bg-surfaceSecondary { background: var(--accent); }
    .bg-background { background: var(--background); }
    .bg-text { background: var(--foreground); }
    .bg-textSecondary { background: var(--muted-foreground); }
    .bg-textTertiary { background: var(--muted-foreground); }
    .bg-error { background: var(--destructive); }
    .bg-success { background: var(--success); }
    .bg-warning { background: var(--warning); }
    .bg-info { background: var(--info); }
    .bg-current { background: currentColor; }
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

    /* ============================================
       BORDER RADIUS (shadcn --radius based)
       ============================================ */
    .rounded-none { border-radius: 0; }
    .rounded-sm { border-radius: calc(var(--radius) - 4px); }
    .rounded-md { border-radius: calc(var(--radius) - 2px); }
    .rounded-lg { border-radius: var(--radius); }
    .rounded-xl { border-radius: calc(var(--radius) + 4px); }
    .rounded-2xl { border-radius: calc(var(--radius) + 8px); }
    .rounded-full { border-radius: 9999px; }

    /* ============================================
       SHADOWS
       ============================================ */
    .shadow-none { box-shadow: var(--shadow-none); }
    .shadow-sm { box-shadow: var(--shadow-sm); }
    .shadow-md { box-shadow: var(--shadow-md); }
    .shadow-lg { box-shadow: var(--shadow-lg); }
    .shadow-xl { box-shadow: var(--shadow-xl); }

    /* ============================================
       COMPONENTS
       ============================================ */

    /* Separator / Divider (shadcn) */
    .divider { border: none; border-top: 1px solid var(--border); width: 100%; flex-shrink: 0; }

    /* Link */
    .link {
        color: var(--primary);
        text-decoration: underline;
        text-underline-offset: 4px;
        cursor: pointer;
        transition-property: color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .link:hover { text-decoration-color: var(--primary); }

    /* Button — base */
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        white-space: nowrap;
        border-radius: calc(var(--radius) - 2px);
        font-size: 0.875rem;
        font-weight: 500;
        line-height: 1.25rem;
        font-family: var(--font-body);
        border: 1px solid transparent;
        cursor: pointer;
        transition-property: color, background-color, border-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .btn:focus-visible { outline: 2px solid var(--ring); outline-offset: 2px; }
    .btn:disabled { pointer-events: none; opacity: 0.5; }

    /* Button variants (shadcn) */
    .btn-default { background: var(--primary); color: var(--primary-foreground); }
    .btn-default:hover { opacity: 0.9; }
    .btn-destructive { background: var(--destructive); color: var(--destructive-foreground); }
    .btn-destructive:hover { opacity: 0.9; }
    .btn-outline { border-color: var(--input); background: var(--background); color: var(--foreground); }
    .btn-outline:hover { background: var(--accent); color: var(--accent-foreground); }
    .btn-secondary { background: var(--secondary); color: var(--secondary-foreground); }
    .btn-secondary:hover { opacity: 0.8; }
    .btn-ghost { background: transparent; color: var(--foreground); }
    .btn-ghost:hover { background: var(--accent); color: var(--accent-foreground); }
    .btn-link { background: transparent; color: var(--primary); text-decoration: underline; text-underline-offset: 4px; }
    .btn-link:hover { text-decoration: underline; }

    /* Button sizes (shadcn) */
    .btn-md { height: 2.25rem; padding: 0.5rem 1rem; }
    .btn-sm { height: 2rem; padding: 0.25rem 0.75rem; font-size: 0.75rem; border-radius: calc(var(--radius) - 4px); }
    .btn-lg { height: 2.75rem; padding: 0.5rem 2rem; font-size: 1rem; border-radius: var(--radius); }
    .btn-icon { height: 2.25rem; width: 2.25rem; padding: 0; }

    /* Clip shapes */
    .clip-circle { border-radius: 9999px; aspect-ratio: 1; padding: var(--spacing-2); }

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

    /* Markdown — @tailwindcss/typography prose with shadcn colors */
    .markdown {
        color: var(--foreground);
        max-width: 65ch;
        font-size: 1rem;
        line-height: 1.75;
    }
    .markdown > :first-child { margin-top: 0; }
    .markdown > :last-child { margin-bottom: 0; }
    .markdown p { margin-top: 1.25em; margin-bottom: 1.25em; }
    .markdown h1 {
        color: var(--foreground);
        font-size: 2.25em; line-height: 1.1111111; font-weight: 800;
        letter-spacing: -0.025em; font-family: var(--font-body);
        margin-top: 0; margin-bottom: 0.8888889em;
        scroll-margin-top: 5rem;
    }
    .markdown h2 {
        color: var(--foreground);
        font-size: 1.5em; line-height: 1.3333333; font-weight: 700;
        letter-spacing: -0.025em; font-family: var(--font-body);
        margin-top: 2em; margin-bottom: 1em;
        padding-bottom: 0.3333333em;
        border-bottom: 1px solid var(--border);
        scroll-margin-top: 5rem;
    }
    .markdown h3 {
        color: var(--foreground);
        font-size: 1.25em; line-height: 1.6; font-weight: 600;
        letter-spacing: -0.025em; font-family: var(--font-body);
        margin-top: 1.6em; margin-bottom: 0.6em;
        scroll-margin-top: 5rem;
    }
    .markdown h4 {
        color: var(--foreground);
        font-weight: 600; font-family: var(--font-body);
        margin-top: 1.5em; margin-bottom: 0.5em;
        scroll-margin-top: 5rem;
    }
    .markdown a {
        color: var(--foreground);
        font-weight: 500;
        text-decoration: underline;
        text-underline-offset: 4px;
        text-decoration-color: var(--muted-foreground);
        transition: text-decoration-color 150ms;
    }
    .markdown a:hover { text-decoration-color: var(--foreground); }
    .markdown strong { color: var(--foreground); font-weight: 600; }
    .markdown em { font-style: italic; }
    .markdown ul { list-style-type: disc; margin-top: 1.25em; margin-bottom: 1.25em; padding-left: 1.625em; }
    .markdown ol { list-style-type: decimal; margin-top: 1.25em; margin-bottom: 1.25em; padding-left: 1.625em; }
    .markdown li { margin-top: 0.5em; margin-bottom: 0.5em; }
    .markdown ul > li::marker { color: var(--muted-foreground); }
    .markdown ol > li::marker { color: var(--muted-foreground); }
    .markdown blockquote {
        font-weight: 500; font-style: italic;
        color: var(--foreground);
        border-left: 0.25rem solid var(--border);
        margin-top: 1.6em; margin-bottom: 1.6em;
        padding-left: 1em;
    }
    .markdown blockquote p:first-child { margin-top: 0; }
    .markdown blockquote p:last-child { margin-bottom: 0; }
    .markdown code {
        color: var(--foreground); font-weight: 600;
        font-family: var(--font-mono); font-size: 0.875em;
        background: var(--muted);
        border-radius: calc(var(--radius) - 4px);
        padding: 0.2em 0.4em;
    }
    .markdown pre {
        color: var(--foreground);
        background: var(--muted);
        overflow-x: auto;
        font-weight: 400; font-size: 0.875em; line-height: 1.7142857;
        margin-top: 1.7142857em; margin-bottom: 1.7142857em;
        border-radius: var(--radius);
        padding: 0.8571429em 1.1428571em;
    }
    .markdown pre code { background: none; padding: 0; font-weight: inherit; font-size: inherit; color: inherit; border-radius: 0; }

    /* Syntax highlighting — GitHub theme (light / dark) */
    .hl-keyword { color: hsl(341 75% 48%); }
    .hl-string { color: hsl(220 62% 24%); }
    .hl-comment { color: hsl(212 12% 48%); font-style: italic; }
    .hl-number { color: hsl(216 85% 34%); }
    .hl-type { color: hsl(27 85% 30%); }
    .hl-attr { color: hsl(264 60% 50%); }
    @media (prefers-color-scheme: dark) {
        .hl-keyword { color: hsl(2 74% 72%); }
        .hl-string { color: hsl(210 100% 82%); }
        .hl-comment { color: hsl(212 10% 58%); }
        .hl-number { color: hsl(212 100% 75%); }
        .hl-type { color: hsl(28 100% 67%); }
        .hl-attr { color: hsl(264 100% 82%); }
    }
    .markdown hr { border: none; border-top: 1px solid var(--border); margin-top: 3em; margin-bottom: 3em; }
    .markdown img { max-width: 100%; height: auto; border-radius: var(--radius); margin-top: 2em; margin-bottom: 2em; }
    .markdown table {
        width: 100%; table-layout: auto; text-align: left;
        margin-top: 2em; margin-bottom: 2em;
        font-size: 0.875em; line-height: 1.7142857;
        border-collapse: collapse;
    }
    .markdown thead { border-bottom: 1px solid var(--border); }
    .markdown thead th {
        color: var(--foreground); font-weight: 600;
        vertical-align: bottom;
        padding: 0 0.5714286em 0.5714286em;
    }
    .markdown thead th:first-child { padding-left: 0; }
    .markdown tbody td {
        vertical-align: baseline;
        padding: 0.5714286em;
        border-bottom: 1px solid var(--border);
    }
    .markdown tbody td:first-child { padding-left: 0; }
    .markdown s { text-decoration: line-through; color: var(--muted-foreground); }

    /* Input */
    .input {
        display: flex;
        height: 2.25rem;
        width: 100%;
        border-radius: calc(var(--radius) - 2px);
        border: 1px solid var(--input);
        background: var(--background);
        padding: 0.5rem 0.75rem;
        font-size: 0.875rem;
        line-height: 1.25rem;
        font-family: var(--font-body);
        color: var(--foreground);
        transition-property: color, border-color, box-shadow;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .input::placeholder { color: var(--muted-foreground); }
    .input:focus { outline: none; border-color: var(--ring); box-shadow: 0 0 0 2px var(--ring); }
    .input:disabled { cursor: not-allowed; opacity: 0.5; }

    /* Textarea */
    .textarea {
        display: flex;
        width: 100%;
        min-height: 5rem;
        border-radius: calc(var(--radius) - 2px);
        border: 1px solid var(--input);
        background: var(--background);
        padding: 0.5rem 0.75rem;
        font-size: 0.875rem;
        line-height: 1.5;
        font-family: var(--font-body);
        color: var(--foreground);
        resize: vertical;
        transition-property: border-color, box-shadow;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .textarea::placeholder { color: var(--muted-foreground); }
    .textarea:focus { outline: none; border-color: var(--ring); box-shadow: 0 0 0 2px var(--ring); }

    /* Toggle / Switch (shadcn) */
    .toggle { display: inline-flex; align-items: center; gap: var(--spacing-2); cursor: pointer; font-size: 0.875rem; }
    .toggle input[type="checkbox"] {
        appearance: none; -webkit-appearance: none;
        width: 2.75rem; height: 1.5rem;
        border-radius: 9999px;
        background: var(--input);
        position: relative;
        cursor: pointer;
        transition: background-color 150ms;
        flex-shrink: 0;
    }
    .toggle input[type="checkbox"]::after {
        content: "";
        position: absolute;
        top: 2px; left: 2px;
        width: 1.25rem; height: 1.25rem;
        border-radius: 9999px;
        background: var(--background);
        box-shadow: var(--shadow-sm);
        transition: transform 150ms;
    }
    .toggle input[type="checkbox"]:checked { background: var(--primary); }
    .toggle input[type="checkbox"]:checked::after { transform: translateX(1.25rem); }
    .toggle input[type="checkbox"]:focus-visible { outline: 2px solid var(--ring); outline-offset: 2px; }
    .toggle input[type="checkbox"]:disabled { opacity: 0.5; cursor: not-allowed; }

    /* Picker / Select */
    .picker {
        display: flex;
        height: 2.25rem;
        width: 100%;
        border-radius: calc(var(--radius) - 2px);
        border: 1px solid var(--input);
        background: var(--background);
        padding: 0.5rem 0.75rem;
        font-size: 0.875rem;
        font-family: var(--font-body);
        color: var(--foreground);
    }
    .picker:focus { outline: none; border-color: var(--ring); box-shadow: 0 0 0 2px var(--ring); }

    /* Slider (shadcn) */
    .slider {
        width: 100%; cursor: pointer;
        appearance: none; -webkit-appearance: none;
        height: 0.5rem;
        border-radius: 9999px;
        background: var(--secondary);
    }
    .slider::-webkit-slider-thumb {
        appearance: none; -webkit-appearance: none;
        width: 1.25rem; height: 1.25rem;
        border-radius: 9999px;
        background: var(--background);
        border: 2px solid var(--primary);
        cursor: pointer;
        transition: background-color 150ms;
    }
    .slider::-webkit-slider-thumb:hover { background: var(--accent); }
    .slider:focus-visible { outline: 2px solid var(--ring); outline-offset: 2px; }
    .slider:disabled { opacity: 0.5; cursor: not-allowed; }

    /* Image */
    .img { max-width: 100%; height: auto; }

    /* Icon */
    .icon { display: inline-flex; align-items: center; justify-content: center; }

    /* NavigationLink */
    .nav-link {
        color: var(--sidebar-foreground);
        text-decoration: none;
        cursor: pointer;
        font-size: 0.875rem;
        display: block;
        padding: var(--spacing-1) var(--spacing-2);
        border-radius: calc(var(--radius) - 2px);
        transition-property: color, background-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .nav-link:hover { background: var(--sidebar-accent); color: var(--sidebar-accent-foreground); }

    /* NavigationLink active state */
    .nav-link-current {
        background: var(--sidebar-accent);
        color: var(--sidebar-accent-foreground);
        font-weight: 500;
    }

    /* List */
    .list { list-style: disc; padding-left: var(--spacing-6); }
    ol.list { list-style: decimal; }

    /* Form */
    .form { display: flex; flex-direction: column; gap: var(--spacing-6); }

    /* Section */
    .section { display: flex; flex-direction: column; gap: var(--spacing-3); }
    .section-header { font-size: 1.125rem; line-height: 1; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-body); }

    /* Progress */
    progress { width: 100%; height: 0.5rem; border-radius: 9999px; overflow: hidden; }
    progress::-webkit-progress-bar { background: var(--secondary); border-radius: 9999px; }
    progress::-webkit-progress-value { background: var(--primary); border-radius: 9999px; }

    /* ============================================
       ANIMATIONS & TRANSITIONS
       ============================================ */

    /* Transition state classes (used by .transition() modifier) */
    .sp-opacity-0 { opacity: 0; }
    .sp-opacity-1 { opacity: 1; }
    .sp-scale-0 { transform: scale(0); }
    .sp-scale-1 { transform: scale(1); }
    .sp-translate-0 { transform: translate(0, 0); }
    .sp-translate-x-full { transform: translateX(100%); }
    .sp-translate-x-neg-full { transform: translateX(-100%); }
    .sp-translate-y-full { transform: translateY(100%); }
    .sp-translate-y-neg-full { transform: translateY(-100%); }

    /* Keyframe animations */
    @keyframes sp-spin {
        to { transform: rotate(360deg); }
    }
    @keyframes sp-pulse {
        50% { opacity: 0.5; }
    }
    @keyframes sp-ping {
        75%, 100% { transform: scale(2); opacity: 0; }
    }
    @keyframes sp-bounce {
        0%, 100% {
            transform: translateY(-25%);
            animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
        }
        50% {
            transform: translateY(0);
            animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
        }
    }
    @keyframes sp-wiggle {
        0%, 100% { transform: rotate(0deg); }
        25% { transform: rotate(-12deg); }
        75% { transform: rotate(12deg); }
    }
    @keyframes sp-breathe {
        0%, 100% { opacity: 1; transform: scale(1); }
        50% { opacity: 0.6; transform: scale(0.97); }
    }
    @keyframes sp-shimmer {
        to { background-position: -200% 0; }
    }

    /* Animation utility classes */
    .sp-animate-spin { animation: sp-spin 1s linear infinite; }
    .sp-animate-pulse { animation: sp-pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
    .sp-animate-ping { animation: sp-ping 1s cubic-bezier(0, 0, 0.2, 1) infinite; }
    .sp-animate-bounce { animation: sp-bounce 1s infinite; }
    .sp-animate-wiggle { animation: sp-wiggle 0.5s ease-in-out infinite; }
    .sp-animate-breathe { animation: sp-breathe 3s ease-in-out infinite; }
    .sp-animate-shimmer {
        background: linear-gradient(90deg, transparent 25%, var(--muted) 50%, transparent 75%);
        background-size: 200% 100%;
        animation: sp-shimmer 1.5s infinite;
    }

    /* withAnimation — applied to sparrow-root during animated patches */
    .sp-animating * { transition: var(--sp-animation) !important; }

    /* View Transition API styles for navigation transitions */
    ::view-transition-old(sparrow-page) {
        animation: 200ms ease-out both sp-fade-out;
    }
    ::view-transition-new(sparrow-page) {
        animation: 200ms ease-in both sp-fade-in;
    }
    @keyframes sp-fade-out { to { opacity: 0; } }
    @keyframes sp-fade-in { from { opacity: 0; } }

    /* Reduced motion — disables all animations and transitions */
    @media (prefers-reduced-motion: reduce) {
        *, *::before, *::after {
            animation-duration: 0.01ms !important;
            animation-iteration-count: 1 !important;
            transition-duration: 0.01ms !important;
            scroll-behavior: auto !important;
        }
    }

    /* ============================================
       RESPONSIVE — mobile (<768px)
       ============================================ */
    @media (max-width: 767px) {
        .desktop-only { display: none !important; }
    }

    /* ============================================
       RESPONSIVE — desktop (>=768px)
       ============================================ */
    @media (min-width: 768px) {
        .mobile-only { display: none !important; }
    }
    """

    /// Generate theme-specific CSS (appended after the base stylesheet).
    /// Produces @font-face rules and CSS variable overrides.
    public static func stylesheet(for theme: Theme) -> String {
        var css = ""

        // @font-face rules from registered font sources
        for source in theme.fonts.sources {
            css += fontFaceRule(for: source)
        }

        // CSS variable overrides
        var rootVars: [String] = []

        // Font family overrides
        if theme.fonts.body != "system-ui" {
            rootVars.append("--font-body: '\(theme.fonts.body)', ui-sans-serif, system-ui, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\"")
        }
        if theme.fonts.heading != "system-ui" {
            rootVars.append("--font-heading: '\(theme.fonts.heading)', ui-sans-serif, system-ui, sans-serif")
        }
        if theme.fonts.mono != "ui-monospace" {
            rootVars.append("--font-mono: '\(theme.fonts.mono)', ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace")
        }

        // Color/token overrides
        for (key, value) in theme.cssOverrides.sorted(by: { $0.key < $1.key }) {
            rootVars.append("\(key): \(value)")
        }

        if !rootVars.isEmpty {
            css += "\n:root {\n"
            for v in rootVars {
                css += "    \(v);\n"
            }
            css += "}\n"
        }

        // Dark mode overrides
        if !theme.darkCSSOverrides.isEmpty {
            css += "\n@media (prefers-color-scheme: dark) {\n    :root {\n"
            for (key, value) in theme.darkCSSOverrides.sorted(by: { $0.key < $1.key }) {
                css += "        \(key): \(value);\n"
            }
            css += "    }\n}\n"
        }

        return css
    }

    private static func fontFaceRule(for registration: FontRegistration) -> String {
        let src: String
        switch registration.source {
        case .system:
            return ""
        case .local(let path):
            let format = fontFormat(for: path)
            src = "url('/assets/\(path)') format('\(format)')"
        case .google(let family):
            // Google fonts are fetched at build time and served locally
            let filename = family.replacingOccurrences(of: " ", with: "-")
            src = "url('/assets/fonts/\(filename).woff2') format('woff2')"
        case .url(let url):
            let format = fontFormat(for: url)
            src = "url('\(url)') format('\(format)')"
        }

        var rule = "@font-face {\n"
        rule += "    font-family: '\(registration.family)';\n"
        rule += "    src: \(src);\n"
        if let range = registration.weightRange {
            rule += "    font-weight: \(range.lowerBound) \(range.upperBound);\n"
        }
        if let style = registration.style {
            rule += "    font-style: \(style);\n"
        }
        rule += "    font-display: swap;\n"
        rule += "}\n"
        return rule
    }

    private static func fontFormat(for path: String) -> String {
        if path.hasSuffix(".woff2") { return "woff2" }
        if path.hasSuffix(".woff") { return "woff" }
        if path.hasSuffix(".ttf") { return "truetype" }
        if path.hasSuffix(".otf") { return "opentype" }
        return "woff2"
    }
}
