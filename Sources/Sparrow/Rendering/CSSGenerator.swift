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
    .font-largeTitle { font-size: 2.25rem; line-height: 2.5rem; font-weight: 700; letter-spacing: -0.025em; font-family: var(--font-body); }
    .font-title { font-size: 1.875rem; line-height: 2.25rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-body); }
    .font-title2 { font-size: 1.5rem; line-height: 2rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-body); }
    .font-title3 { font-size: 1.25rem; line-height: 1.75rem; font-weight: 600; letter-spacing: -0.025em; font-family: var(--font-body); }
    .font-headline { font-size: 1rem; line-height: 1.5rem; font-weight: 600; font-family: var(--font-body); }
    .font-body { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-callout { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-subheadline { font-size: 0.875rem; line-height: 1.25rem; font-weight: 400; font-family: var(--font-body); }
    .font-footnote { font-size: 0.75rem; line-height: 1rem; font-weight: 400; font-family: var(--font-body); }
    .font-caption { font-size: 0.75rem; line-height: 1rem; font-weight: 400; color: var(--muted-foreground); font-family: var(--font-body); }

    /* ============================================
       FOREGROUND COLORS
       ============================================ */
    .fg-primary { color: var(--primary); }
    .fg-secondary { color: var(--muted-foreground); }
    .fg-accent { color: var(--accent-foreground); }
    .fg-text { color: var(--foreground); }
    .fg-textSecondary { color: var(--muted-foreground); }
    .fg-textTertiary { color: var(--muted-foreground); }
    .fg-error { color: var(--destructive); }
    .fg-success { color: var(--success); }
    .fg-warning { color: var(--warning); }
    .fg-info { color: var(--info); }
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
    .bg-surface { background: var(--muted); }
    .bg-surfaceSecondary { background: var(--accent); }
    .bg-background { background: var(--background); }
    .bg-error { background: var(--destructive); }
    .bg-success { background: var(--success); }
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

    /* Divider */
    .divider { border: none; border-top: 1px solid var(--border); width: 100%; }

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

    /* Button */
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
        height: 2.25rem;
        padding: 0.5rem 1rem;
        background: var(--primary);
        color: var(--primary-foreground);
        border: 1px solid transparent;
        cursor: pointer;
        transition-property: color, background-color, border-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .btn:hover { opacity: 0.9; }
    .btn:focus-visible { outline: 2px solid var(--ring); outline-offset: 2px; }
    .btn:active { opacity: 0.8; }
    .btn:disabled { pointer-events: none; opacity: 0.5; }

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

    /* Label */
    .label { display: inline-flex; align-items: center; gap: var(--spacing-1); font-size: 0.875rem; font-weight: 500; line-height: 1; }
    .label-icon { display: inline-flex; }

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

    /* Toggle */
    .toggle { display: inline-flex; align-items: center; gap: var(--spacing-2); cursor: pointer; font-size: 0.875rem; }

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

    /* Slider */
    .slider { width: 100%; cursor: pointer; accent-color: var(--primary); }

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

    /* Card */
    .card {
        border-radius: var(--radius);
        border: 1px solid var(--border);
        background: var(--card);
        color: var(--card-foreground);
        box-shadow: var(--shadow-sm);
        padding: var(--spacing-6);
    }

    /* Modal / Dialog */
    .modal {
        border: 1px solid var(--border);
        background: var(--background);
        padding: var(--spacing-6);
        box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
        border-radius: var(--radius);
        max-width: 32rem;
        width: 100%;
    }
    .modal::backdrop { background: rgb(0 0 0 / 0.8); }

    /* Sheet */
    .sheet {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background: var(--background);
        border-top: 1px solid var(--border);
        padding: var(--spacing-6);
        box-shadow: var(--shadow-xl);
        border-radius: var(--radius) var(--radius) 0 0;
        transform: translateY(100%);
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sheet-open { transform: translateY(0); }

    /* Menu / DropdownMenu */
    .menu { position: relative; display: inline-block; }
    .menu-trigger { background: none; border: none; cursor: pointer; font: inherit; color: inherit; }
    .menu-content {
        display: none;
        position: absolute;
        top: 100%;
        left: 0;
        min-width: 8rem;
        background: var(--popover);
        color: var(--popover-foreground);
        border: 1px solid var(--border);
        border-radius: calc(var(--radius) - 2px);
        box-shadow: var(--shadow-md);
        padding: 0.25rem;
        z-index: 100;
    }

    /* Alert */
    .alert {
        position: relative;
        width: 100%;
        border-radius: var(--radius);
        border: 1px solid var(--border);
        padding: var(--spacing-4);
        font-size: 0.875rem;
        line-height: 1.25rem;
    }
    .alert-title { font-weight: 500; line-height: 1.5; letter-spacing: -0.025em; margin-bottom: 0.25rem; }
    .alert-message { font-size: 0.875rem; line-height: 1.25rem; color: var(--muted-foreground); }

    /* Toast (sonner style) */
    .toast {
        position: fixed;
        bottom: var(--spacing-6);
        left: 50%;
        transform: translateX(-50%);
        padding: var(--spacing-3) var(--spacing-4);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        font-size: 0.875rem;
        line-height: 1.25rem;
        z-index: 1000;
        box-shadow: var(--shadow-lg);
        background: var(--background);
        color: var(--foreground);
    }
    .toast-info { border-left: 4px solid var(--info); }
    .toast-success { border-left: 4px solid var(--success); }
    .toast-warning { border-left: 4px solid var(--warning); }
    .toast-error { border-left: 4px solid var(--destructive); }

    /* Badge */
    .badge {
        display: inline-flex;
        align-items: center;
        border-radius: 9999px;
        border: 1px solid transparent;
        padding: 0.125rem 0.625rem;
        font-size: 0.75rem;
        font-weight: 600;
        line-height: 1rem;
        font-family: var(--font-body);
        transition-property: color, background-color, border-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .badge-default { background: var(--primary); color: var(--primary-foreground); }
    .badge-success { background: var(--success); color: var(--success-foreground); }
    .badge-warning { background: var(--warning); color: var(--warning-foreground); }
    .badge-error { background: var(--destructive); color: var(--destructive-foreground); }
    .badge-info { background: var(--info); color: var(--info-foreground); }

    /* Progress */
    progress { width: 100%; height: 0.5rem; border-radius: 9999px; overflow: hidden; }
    progress::-webkit-progress-bar { background: var(--secondary); border-radius: 9999px; }
    progress::-webkit-progress-value { background: var(--primary); border-radius: 9999px; }

    /* Spinner */
    .spinner {
        width: 1.5rem;
        height: 1.5rem;
        border: 2px solid var(--muted);
        border-top-color: var(--primary);
        border-radius: 50%;
        animation: spin 0.6s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }

    /* Stepper */
    .stepper { display: inline-flex; align-items: center; gap: var(--spacing-3); }
    .stepper-label { font-size: 0.875rem; font-family: var(--font-body); }
    .stepper-controls {
        display: inline-flex;
        align-items: center;
        border: 1px solid var(--input);
        border-radius: calc(var(--radius) - 2px);
        overflow: hidden;
    }
    .stepper-btn {
        display: flex; align-items: center; justify-content: center;
        width: 2.25rem; height: 2.25rem;
        background: var(--background); border: none; cursor: pointer;
        font-size: 1rem; color: var(--foreground);
        transition-property: background-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .stepper-btn:hover { background: var(--accent); }
    .stepper-btn:disabled { color: var(--muted-foreground); cursor: not-allowed; }
    .stepper-value { display: flex; align-items: center; justify-content: center; min-width: 2.5rem; font-size: 0.875rem; font-family: var(--font-body); }

    /* Segmented Control (shadcn Tabs trigger style) */
    .segmented {
        display: inline-flex;
        height: 2.5rem;
        align-items: center;
        border-radius: var(--radius);
        background: var(--muted);
        padding: 0.25rem;
        color: var(--muted-foreground);
    }
    .segmented-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0.375rem 0.75rem;
        font-size: 0.875rem;
        font-weight: 500;
        font-family: var(--font-body);
        border-radius: calc(var(--radius) - 2px);
        background: transparent;
        color: inherit;
        border: none;
        cursor: pointer;
        white-space: nowrap;
        transition-property: all;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .segmented-btn:hover { color: var(--foreground); }
    .segmented-btn-active {
        background: var(--background);
        color: var(--foreground);
        box-shadow: var(--shadow-sm);
    }
    .segmented-btn-active:hover { background: var(--background); }

    /* Radio Group */
    .radio-group { border: none; display: flex; flex-direction: column; gap: var(--spacing-3); padding: 0; }
    .radio-legend { font-size: 0.875rem; font-weight: 500; margin-bottom: var(--spacing-1); font-family: var(--font-body); }
    .radio-option { display: flex; align-items: center; gap: var(--spacing-2); cursor: pointer; font-size: 0.875rem; font-family: var(--font-body); }
    .radio-option input[type="radio"] { accent-color: var(--primary); width: 1rem; height: 1rem; }

    /* Checkbox */
    .checkbox { display: flex; align-items: center; gap: var(--spacing-2); cursor: pointer; font-size: 0.875rem; font-family: var(--font-body); }
    .checkbox input[type="checkbox"] { accent-color: var(--primary); width: 1rem; height: 1rem; }

    /* Combobox */
    .combobox { cursor: text; }

    /* Color Picker */
    .color-picker { display: inline-flex; align-items: center; gap: var(--spacing-2); cursor: pointer; font-size: 0.875rem; font-family: var(--font-body); }
    .color-picker input[type="color"] { width: 2.25rem; height: 2.25rem; border: 1px solid var(--input); border-radius: calc(var(--radius) - 4px); cursor: pointer; padding: 2px; }

    /* Search Field */
    .search-field { padding-left: 2rem; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%2371717a' stroke-width='2'%3E%3Ccircle cx='11' cy='11' r='8'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: 0.5rem center; }

    /* Skeleton */
    .skeleton { background: var(--muted); border-radius: calc(var(--radius) - 2px); animation: shimmer 2s infinite; }
    .skeleton-rect { width: 100%; height: 1.25rem; }
    .skeleton-circle { width: 3rem; height: 3rem; border-radius: 9999px; }
    .skeleton-text { display: flex; flex-direction: column; gap: var(--spacing-2); }
    .skeleton-line { height: 0.875rem; border-radius: calc(var(--radius) - 4px); }
    .skeleton-line-short { width: 60%; }
    @keyframes shimmer {
        0% { opacity: 0.5; }
        50% { opacity: 1; }
        100% { opacity: 0.5; }
    }

    /* Banner */
    .banner {
        width: 100%; padding: var(--spacing-3) var(--spacing-4);
        font-size: 0.875rem;
        display: flex; align-items: center;
        border-radius: var(--radius);
        border: 1px solid var(--border);
    }
    .banner-info { background: var(--info); color: var(--info-foreground); border-color: transparent; }
    .banner-success { background: var(--success); color: var(--success-foreground); border-color: transparent; }
    .banner-warning { background: var(--warning); color: var(--warning-foreground); border-color: transparent; }
    .banner-error { background: var(--destructive); color: var(--destructive-foreground); border-color: transparent; }

    /* Gauge */
    meter { width: 100%; height: 0.5rem; }
    meter::-webkit-meter-bar { background: var(--secondary); border-radius: 9999px; border: none; }
    meter::-webkit-meter-optimum-value { background: var(--primary); border-radius: 9999px; }

    /* Accordion */
    .accordion { display: flex; flex-direction: column; }
    .accordion-item { border-bottom: 1px solid var(--border); }
    .accordion-item:last-child { border-bottom: none; }
    .accordion-header {
        padding: var(--spacing-4) 0; cursor: pointer;
        font-size: 0.875rem; font-weight: 500; font-family: var(--font-body);
        background: transparent;
        list-style: none;
        display: flex; align-items: center; justify-content: space-between;
        transition-property: all;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .accordion-header:hover { text-decoration: underline; }
    .accordion-header::after {
        content: "";
        display: block;
        width: 0.5rem; height: 0.5rem;
        flex-shrink: 0;
        margin-left: var(--spacing-2);
        border-right: 2px solid var(--muted-foreground);
        border-bottom: 2px solid var(--muted-foreground);
        transform: rotate(45deg);
        transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .accordion-item[open] > .accordion-header::after { transform: rotate(-135deg); }
    .accordion-header::-webkit-details-marker { display: none; }
    .accordion-content { padding-bottom: var(--spacing-4); font-size: 0.875rem; color: var(--muted-foreground); }

    /* Breadcrumb */
    .breadcrumb { display: flex; align-items: center; gap: var(--spacing-1); font-size: 0.875rem; }
    .breadcrumb-link { color: var(--muted-foreground); text-decoration: none; transition: color 150ms; }
    .breadcrumb-link:hover { color: var(--foreground); }
    .breadcrumb-current { color: var(--foreground); font-weight: 500; }
    .breadcrumb-sep { color: var(--muted-foreground); }

    /* Pagination */
    .pagination { display: flex; align-items: center; gap: var(--spacing-1); }
    .pagination-btn {
        display: inline-flex; align-items: center; justify-content: center;
        min-width: 2.25rem; height: 2.25rem; padding: 0 var(--spacing-2);
        font-size: 0.875rem; color: var(--foreground);
        background: transparent; border: 1px solid var(--input);
        border-radius: calc(var(--radius) - 2px); cursor: pointer;
        transition-property: background-color, border-color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .pagination-btn:hover { background: var(--accent); }
    .pagination-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .pagination-btn-active { background: var(--primary); color: var(--primary-foreground); border-color: var(--primary); }
    .pagination-btn-active:hover { background: var(--primary); opacity: 0.9; }

    /* Data Table */
    .data-table-wrapper { width: 100%; overflow-x: auto; border: 1px solid var(--border); border-radius: var(--radius); }
    .data-table {
        width: 100%; border-collapse: collapse;
        font-size: 0.875rem;
    }
    .data-table th {
        height: 3rem; padding: 0 var(--spacing-4);
        font-weight: 500; color: var(--muted-foreground);
        text-align: left;
        border-bottom: 1px solid var(--border);
        white-space: nowrap;
    }
    .data-table td {
        padding: var(--spacing-4);
        border-bottom: 1px solid var(--border);
    }
    .data-table tbody tr:last-child td { border-bottom: none; }
    .data-table tbody tr:hover { background: var(--muted); }
    .text-start { text-align: left; }
    .text-center { text-align: center; }
    .text-end { text-align: right; }

    /* Tooltip */
    .tooltip-wrapper { position: relative; display: inline-block; }
    .tooltip-text {
        visibility: hidden; opacity: 0;
        position: absolute; bottom: calc(100% + 8px); left: 50%; transform: translateX(-50%);
        padding: var(--spacing-1) var(--spacing-2);
        background: var(--primary); color: var(--primary-foreground);
        border-radius: calc(var(--radius) - 2px); font-size: 0.75rem;
        white-space: nowrap; z-index: 200; pointer-events: none;
        transition: opacity 0.15s ease, visibility 0.15s ease;
    }
    .tooltip-wrapper:hover .tooltip-text { visibility: visible; opacity: 1; }

    /* Popover */
    .popover { display: none; }
    .popover-open { display: block; }
    .popover-content {
        position: absolute; z-index: 150;
        background: var(--popover); color: var(--popover-foreground);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        box-shadow: var(--shadow-md);
        padding: var(--spacing-4);
        min-width: 12rem;
    }

    /* Hover Card */
    .hover-card { position: relative; display: inline-block; }
    .hover-card-content {
        display: none; position: absolute; top: calc(100% + 8px); left: 0;
        z-index: 150;
        background: var(--popover); color: var(--popover-foreground);
        border: 1px solid var(--border);
        border-radius: var(--radius);
        box-shadow: var(--shadow-md);
        padding: var(--spacing-4); min-width: 16rem;
    }
    .hover-card:hover .hover-card-content { display: block; }

    /* Drawer / Sheet */
    .drawer { display: none; position: fixed; inset: 0; z-index: 300; }
    .drawer-open { display: block; }
    .drawer-backdrop { position: absolute; inset: 0; background: rgb(0 0 0 / 0.8); }
    .drawer-panel {
        position: absolute;
        background: var(--background);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-xl);
        padding: var(--spacing-6);
        overflow-y: auto;
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .drawer-trailing .drawer-panel { top: 0; right: 0; bottom: 0; width: 24rem; border-left: 1px solid var(--border); }
    .drawer-leading .drawer-panel { top: 0; left: 0; bottom: 0; width: 24rem; border-right: 1px solid var(--border); }
    .drawer-bottom .drawer-panel { left: 0; right: 0; bottom: 0; max-height: 80vh; border-radius: var(--radius) var(--radius) 0 0; border-top: 1px solid var(--border); }

    /* Disclosure Group */
    .disclosure { border: 1px solid var(--border); border-radius: var(--radius); }
    .disclosure-header {
        padding: var(--spacing-3) var(--spacing-4); cursor: pointer;
        font-size: 0.875rem; font-weight: 500; font-family: var(--font-body);
        list-style: none;
        display: flex; align-items: center; justify-content: space-between;
    }
    .disclosure-header::after {
        content: "";
        display: block;
        width: 0.5rem; height: 0.5rem;
        flex-shrink: 0;
        border-right: 2px solid var(--muted-foreground);
        border-bottom: 2px solid var(--muted-foreground);
        transform: rotate(-45deg);
        transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .disclosure[open] > .disclosure-header::after { transform: rotate(45deg); }
    .disclosure-header::-webkit-details-marker { display: none; }
    .disclosure-content { padding: var(--spacing-3) var(--spacing-4); border-top: 1px solid var(--border); }

    /* Tab View (shadcn Tabs) */
    .tab-view { display: flex; flex-direction: column; width: 100%; }
    .tab-bar {
        display: inline-flex;
        height: 2.5rem;
        align-items: center;
        border-radius: var(--radius);
        background: var(--muted);
        padding: 0.25rem;
        color: var(--muted-foreground);
        overflow-x: auto;
    }
    .tab-btn {
        display: inline-flex; align-items: center; gap: var(--spacing-1);
        padding: 0.375rem 0.75rem;
        font-size: 0.875rem; font-weight: 500; color: inherit;
        background: transparent; border: none;
        border-radius: calc(var(--radius) - 2px);
        cursor: pointer; white-space: nowrap;
        transition-property: all;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 150ms;
    }
    .tab-btn:hover { color: var(--foreground); }
    .tab-btn-active {
        background: var(--background);
        color: var(--foreground);
        box-shadow: var(--shadow-sm);
    }
    .tab-content { padding: var(--spacing-4); flex: 1; }
    .tab-icon { display: inline-flex; }

    /* Navigation Bar */
    .nav-bar {
        display: flex; align-items: center;
        padding: var(--spacing-3) var(--spacing-4);
        background: var(--background);
        border-bottom: 1px solid var(--border);
        width: 100%;
    }
    .nav-bar-leading { display: flex; align-items: center; gap: var(--spacing-2); }
    .nav-bar-title { flex: 1; font-size: 1.125rem; font-weight: 600; letter-spacing: -0.025em; text-align: center; font-family: var(--font-body); }
    .nav-bar-trailing { display: flex; align-items: center; gap: var(--spacing-2); }

    /* Sidebar */
    .sidebar {
        display: flex; flex-direction: column;
        background: var(--sidebar-background);
        color: var(--sidebar-foreground);
        padding: var(--spacing-4);
        border-right: 1px solid var(--sidebar-border);
        min-height: 100vh; width: 16rem;
    }

    /* Sidebar Header / Footer */
    .sidebar-header {
        flex-shrink: 0;
        padding: var(--spacing-3) var(--spacing-2);
        border-bottom: 1px solid var(--sidebar-border);
    }
    .sidebar-footer {
        flex-shrink: 0;
        padding: var(--spacing-3) var(--spacing-2);
        border-top: 1px solid var(--sidebar-border);
    }

    /* Footer */
    .footer {
        margin-top: auto;
        padding: var(--spacing-6) var(--spacing-6) var(--spacing-4);
        border-top: 1px solid var(--border);
        color: var(--muted-foreground);
        font-size: 0.75rem;
    }
    .footer-column {
        display: flex; flex-direction: column; gap: var(--spacing-2);
    }
    .footer-column-heading {
        font-weight: 600; font-size: 0.75rem;
        color: var(--foreground); margin: 0 0 var(--spacing-1) 0;
    }
    .footer-bottom {
        margin-top: var(--spacing-4);
        padding-top: var(--spacing-4);
        border-top: 1px solid var(--border);
        font-size: 0.75rem;
        color: var(--muted-foreground);
    }

    /* Sidebar Layout */
    .sidebar-layout { display: flex; width: 100%; height: 100vh; }
    .sidebar-layout-sidebar {
        position: relative;
        width: 16rem; flex-shrink: 0;
        display: flex; flex-direction: column;
        background: var(--sidebar-background);
        color: var(--sidebar-foreground);
        border-right: 1px solid var(--sidebar-border);
        overflow-y: auto;
        padding: var(--spacing-4);
        transition: width 0.2s cubic-bezier(0.4, 0, 0.2, 1), padding 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sidebar-layout-sidebar.sidebar-collapsed {
        width: 0; padding: 0; overflow: hidden;
        border-right: none;
    }
    .sidebar-layout-main {
        flex: 1; overflow-y: auto;
        display: flex; flex-direction: column;
    }

    /* Sidebar collapse button */
    .sidebar-collapse-btn {
        position: absolute; top: var(--spacing-3); right: calc(-1 * var(--spacing-3));
        z-index: 10;
        width: 1.5rem; height: 1.5rem;
        display: flex; align-items: center; justify-content: center;
        background: var(--sidebar-background);
        border: 1px solid var(--sidebar-border);
        border-radius: 50%;
        cursor: pointer;
        color: var(--muted-foreground);
        box-shadow: var(--shadow-sm);
        transition-property: transform, color;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        transition-duration: 200ms;
    }
    .sidebar-collapse-btn:hover { color: var(--foreground); }
    .sidebar-collapsed .sidebar-collapse-btn {
        position: fixed; left: 0; top: var(--spacing-3);
        right: auto;
        border-radius: 0 50% 50% 0;
        border-left: none;
        transform: rotate(180deg);
    }

    /* Mobile hamburger toggle */
    .sidebar-mobile-toggle {
        display: none;
        padding: var(--spacing-2) var(--spacing-3);
        background: none; border: none;
        cursor: pointer; color: var(--foreground);
    }

    /* ============================================
       RESPONSIVE — mobile (<768px)
       ============================================ */
    @media (max-width: 767px) {
        .desktop-only { display: none !important; }
        .desktop-only-hover { pointer-events: auto; }
        .desktop-only-hover .tooltip-text { display: none !important; }
        .desktop-only-hover .hover-card-content { display: none !important; }

        .modal { width: 100%; max-width: 100%; margin: auto 0 0 0; border-radius: var(--radius) var(--radius) 0 0; }

        .popover-content {
            position: fixed; bottom: 0; left: 0; right: 0;
            border-radius: var(--radius) var(--radius) 0 0;
            max-height: 80vh; overflow-y: auto;
        }

        .drawer-trailing .drawer-panel,
        .drawer-leading .drawer-panel {
            top: auto; left: 0; right: 0; bottom: 0; width: 100%;
            max-height: 80vh; border-radius: var(--radius) var(--radius) 0 0;
        }

        .menu-content {
            position: fixed; bottom: 0; left: 0; right: 0; top: auto;
            border-radius: var(--radius) var(--radius) 0 0;
            min-width: 100%;
        }

        .tab-view { flex-direction: column-reverse; }
        .tab-bar {
            position: fixed; bottom: 0; left: 0; right: 0;
            border-radius: 0;
            border-bottom: none; border-top: 1px solid var(--border);
            justify-content: space-around; z-index: 100;
            height: auto;
        }
        .tab-btn { flex-direction: column; font-size: 0.75rem; padding: var(--spacing-1) var(--spacing-2); min-height: 3.125rem; border-radius: 0; }
        .tab-btn-active { box-shadow: none; color: var(--primary); }
        .tab-content { padding-bottom: 4.375rem; }

        .nav-bar-title { font-size: 1rem; }

        .sidebar-layout-sidebar {
            position: fixed; left: 0; top: 0; bottom: 0; z-index: 250;
            width: 17.5rem;
            transform: translateX(-100%); transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: var(--shadow-xl);
        }
        .sidebar-layout-sidebar.sidebar-open { transform: translateX(0); }
        .sidebar-layout-sidebar.sidebar-collapsed { transform: translateX(-100%); }
        .sidebar-collapse-btn { display: none; }
        .sidebar-mobile-toggle { display: block; }

        .pagination-page { display: none; }

        .data-table { min-width: 37.5rem; }

        .segmented { display: flex; width: 100%; }
        .segmented-btn { flex: 1; text-align: center; }

        .accordion-header { padding: var(--spacing-4) 0; min-height: 3rem; }
        .disclosure-header { padding: var(--spacing-4) var(--spacing-4); min-height: 3rem; }

        .search-field { width: 100%; }
    }

    /* ============================================
       RESPONSIVE — desktop (>=768px)
       ============================================ */
    @media (min-width: 768px) {
        .mobile-only { display: none !important; }
    }
    """
}
