# shadcn/ui Component Specifications

Complete specifications for every shadcn/ui component, derived from the v4 source code in the official repository (`apps/v4/registry/new-york-v4/ui/`). All CSS classes shown are Tailwind v4. All interactive components delegate ARIA and keyboard behavior to Radix UI primitives unless otherwise noted.

---

## Theming System

### Color Format

OKLCH color space. Example: `oklch(0.205 0 0)`.

### CSS Custom Properties (Light Mode - `:root`)

| Variable | Purpose | Default (light) |
|---|---|---|
| `--radius` | Global border radius | `0.625rem` |
| `--background` | Page background | `oklch(1 0 0)` |
| `--foreground` | Primary text | `oklch(0.145 0 0)` |
| `--card` | Card background | `oklch(1 0 0)` |
| `--card-foreground` | Card text | `oklch(0.145 0 0)` |
| `--popover` | Popover/dropdown bg | `oklch(1 0 0)` |
| `--popover-foreground` | Popover text | `oklch(0.145 0 0)` |
| `--primary` | Primary action color | `oklch(0.205 0 0)` |
| `--primary-foreground` | Text on primary | `oklch(0.985 0 0)` |
| `--secondary` | Secondary actions | `oklch(0.97 0 0)` |
| `--secondary-foreground` | Text on secondary | `oklch(0.205 0 0)` |
| `--muted` | Muted/disabled bg | `oklch(0.97 0 0)` |
| `--muted-foreground` | Muted text | `oklch(0.556 0 0)` |
| `--accent` | Accent hover bg | `oklch(0.97 0 0)` |
| `--accent-foreground` | Accent text | `oklch(0.205 0 0)` |
| `--destructive` | Error/danger | `oklch(0.577 0.245 27.325)` |
| `--destructive-foreground` | Text on destructive | `oklch(0.985 0 0)` |
| `--border` | Default borders | `oklch(0.922 0 0)` |
| `--input` | Input borders | `oklch(0.922 0 0)` |
| `--ring` | Focus rings | `oklch(0.708 0 0)` |
| `--chart-1` through `--chart-5` | Chart colors | Varies |

#### Sidebar Variables

| Variable | Purpose |
|---|---|
| `--sidebar` | Sidebar background |
| `--sidebar-foreground` | Sidebar text |
| `--sidebar-primary` | Active sidebar items |
| `--sidebar-primary-foreground` | Active item text |
| `--sidebar-accent` | Sidebar hover bg |
| `--sidebar-accent-foreground` | Sidebar hover text |
| `--sidebar-border` | Sidebar borders |
| `--sidebar-ring` | Sidebar focus rings |

### Dark Mode

Activated via `.dark` class on an ancestor element. All variables redefined:

| Variable | Dark value |
|---|---|
| `--background` | `oklch(0.145 0 0)` |
| `--foreground` | `oklch(0.985 0 0)` |
| `--card` | `oklch(0.205 0 0)` |
| `--primary` | `oklch(0.922 0 0)` |
| `--primary-foreground` | `oklch(0.205 0 0)` |
| `--destructive` | `oklch(0.704 0.191 22.216)` |
| `--border` | `oklch(1 0 0 / 10%)` |
| `--input` | `oklch(1 0 0 / 15%)` |

### Naming Convention

- `bg-primary` uses `var(--primary)` (background = no suffix)
- `text-primary-foreground` uses `var(--primary-foreground)` (foreground = `-foreground` suffix)

### Base Color Presets

Neutral, Stone, Zinc, Mauve, Olive, Mist, Taupe.

---

## LAYOUT / CONTAINER COMPONENTS

---

### Card

**Underlying primitive**: None (plain HTML divs)
**HTML tag**: `<div>`
**Sub-components**: Card, CardHeader, CardTitle, CardDescription, CardAction, CardContent, CardFooter

#### Rendered HTML Structure

```html
<div data-slot="card" class="flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm">
  <div data-slot="card-header" class="@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6">
    <div data-slot="card-title" class="leading-none font-semibold">...</div>
    <div data-slot="card-description" class="text-sm text-muted-foreground">...</div>
    <div data-slot="card-action" class="col-start-2 row-span-2 row-start-1 self-start justify-self-end">...</div>
  </div>
  <div data-slot="card-content" class="px-6">...</div>
  <div data-slot="card-footer" class="flex items-center px-6 [.border-t]:pt-6">...</div>
</div>
```

#### Props

| Component | Props |
|---|---|
| Card | `className` |
| CardHeader | `className` |
| CardTitle | `className` |
| CardDescription | `className` |
| CardAction | `className` |
| CardContent | `className` |
| CardFooter | `className` |

#### ARIA: None (presentational)
#### Keyboard: None

---

### Separator

**Underlying primitive**: Radix `Separator`
**HTML tag**: Renders as a `<div>` with `role="separator"` (via Radix)

#### Rendered HTML

```html
<div data-slot="separator" role="separator"
  class="shrink-0 bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px">
</div>
```

#### Props

| Prop | Type | Default |
|---|---|---|
| `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |
| `decorative` | `boolean` | `true` |

#### ARIA

- `role="separator"` (when `decorative=false`)
- `aria-orientation="horizontal|vertical"`
- When `decorative=true`, rendered as presentational (no role)

#### Keyboard: None

---

### Collapsible

**Underlying primitive**: Radix `Collapsible`
**WAI-ARIA**: Disclosure pattern

#### Sub-components

- `Collapsible` - Root, manages open/closed state
- `CollapsibleTrigger` - Button that toggles content
- `CollapsibleContent` - Expandable content panel

#### Props

| Prop | Type | Description |
|---|---|---|
| `open` | `boolean` | Controlled open state |
| `onOpenChange` | `(open: boolean) => void` | State change callback |
| `defaultOpen` | `boolean` | Uncontrolled initial state |

#### ARIA

- Trigger: `aria-expanded="true|false"`, `aria-controls="[content-id]"`
- Content: `id` linked to trigger
- `data-state="open|closed"` on both trigger and content

#### Keyboard

| Key | Action |
|---|---|
| Space | Toggle open/closed |
| Enter | Toggle open/closed |

---

### Scroll Area

**Underlying primitive**: Radix `ScrollArea`

#### Sub-components

- `ScrollArea` - Root container with viewport
- `ScrollBar` - Custom scrollbar

#### Rendered HTML

```html
<div data-slot="scroll-area" class="relative">
  <div data-slot="scroll-area-viewport" class="size-full rounded-[inherit] ...">
    <!-- children -->
  </div>
  <div data-slot="scroll-area-scrollbar" class="flex touch-none p-px ...">
    <div data-slot="scroll-area-thumb" class="relative flex-1 rounded-full bg-border" />
  </div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| ScrollBar | `orientation` | `"vertical" \| "horizontal"` | `"vertical"` |

#### Scrollbar CSS

- Vertical: `h-full w-2.5 border-l border-l-transparent`
- Horizontal: `h-2.5 flex-col border-t border-t-transparent`
- Hides native scrollbar via `scrollbar-width: none` and `::-webkit-scrollbar { display: none }`

#### ARIA: Uses `data-radix-scroll-area-viewport` attribute
#### Keyboard: Native scroll behavior

---

### Aspect Ratio

**Underlying primitive**: Radix `AspectRatio`

#### Props

| Prop | Type | Required |
|---|---|---|
| `ratio` | `number` | Yes |

#### Usage

```html
<div data-slot="aspect-ratio" style="--radix-aspect-ratio: 1.778"> <!-- 16/9 -->
  <img ... />
</div>
```

#### ARIA: None
#### Keyboard: None

---

### Resizable

**Underlying primitive**: `react-resizable-panels` by bvaughn

#### Sub-components

- `ResizablePanelGroup` - Container (flex layout)
- `ResizablePanel` - Individual panel
- `ResizableHandle` - Drag handle between panels

#### Rendered HTML

```html
<div data-slot="resizable-panel-group"
  class="flex h-full w-full aria-[orientation=vertical]:flex-col">
  <div data-slot="resizable-panel">...</div>
  <div data-slot="resizable-handle"
    class="relative flex w-px items-center justify-center bg-border ...">
    <!-- optional visible handle: -->
    <div class="z-10 flex h-4 w-3 items-center justify-center rounded-xs border bg-border">
      <svg><!-- GripVerticalIcon --></svg>
    </div>
  </div>
  <div data-slot="resizable-panel">...</div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| ResizablePanelGroup | `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |
| ResizableHandle | `withHandle` | `boolean` | `false` |

#### ARIA

- Handle: `aria-orientation="horizontal|vertical"`, `role="separator"` (from library)
- `focus-visible:ring-1 focus-visible:ring-ring`

#### Keyboard

Arrow keys to resize panels when handle is focused.

---

## OVERLAY / POPUP COMPONENTS

---

### Dialog

**Underlying primitive**: Radix `Dialog`
**WAI-ARIA**: Dialog (modal) pattern

#### Sub-components

Dialog, DialogTrigger, DialogPortal, DialogOverlay, DialogContent, DialogHeader, DialogFooter, DialogTitle, DialogDescription, DialogClose

#### Rendered HTML Structure

```html
<!-- Trigger -->
<button data-slot="dialog-trigger">...</button>

<!-- Portal (appended to body) -->
<div data-slot="dialog-portal">
  <!-- Overlay -->
  <div data-slot="dialog-overlay"
    class="fixed inset-0 z-50 bg-black/50 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0">
  </div>

  <!-- Content -->
  <div data-slot="dialog-content" role="dialog" aria-modal="true"
    aria-labelledby="[title-id]" aria-describedby="[description-id]"
    class="fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 shadow-lg duration-200 ... sm:max-w-lg">

    <div data-slot="dialog-header" class="flex flex-col gap-2 text-center sm:text-left">
      <h2 data-slot="dialog-title" class="text-lg leading-none font-semibold">...</h2>
      <p data-slot="dialog-description" class="text-sm text-muted-foreground">...</p>
    </div>

    <!-- children -->

    <div data-slot="dialog-footer" class="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
      ...
    </div>

    <!-- Close button (when showCloseButton=true) -->
    <button data-slot="dialog-close"
      class="absolute top-4 right-4 rounded-xs opacity-70 ...">
      <svg><!-- XIcon --></svg>
      <span class="sr-only">Close</span>
    </button>
  </div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| DialogContent | `showCloseButton` | `boolean` | `true` |
| DialogFooter | `showCloseButton` | `boolean` | `false` |

#### ARIA

- Content: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby`
- Focus trapped inside modal
- Close button: `<span class="sr-only">Close</span>`

#### Keyboard

| Key | Action |
|---|---|
| Escape | Close dialog, focus returns to trigger |
| Tab | Move to next focusable element (trapped) |
| Shift+Tab | Move to previous focusable element (trapped) |
| Space/Enter | Open (on trigger) |

#### Animations

- Overlay: `fade-in-0` / `fade-out-0`
- Content: `fade-in-0 zoom-in-95` / `fade-out-0 zoom-out-95`

---

### Alert Dialog

**Underlying primitive**: Radix `AlertDialog`
**WAI-ARIA**: Alert Dialog pattern (requires explicit user action to dismiss)

#### Sub-components

AlertDialog, AlertDialogTrigger, AlertDialogPortal, AlertDialogOverlay, AlertDialogContent, AlertDialogHeader, AlertDialogFooter, AlertDialogTitle, AlertDialogDescription, AlertDialogMedia, AlertDialogAction, AlertDialogCancel

#### Key Differences from Dialog

- Cannot be dismissed by clicking overlay or pressing Escape without explicit action
- Uses `role="alertdialog"` instead of `role="dialog"`
- Has explicit Cancel and Action buttons (not just Close)
- AlertDialogAction and AlertDialogCancel render as Button components
- AlertDialogMedia provides an icon/image area

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| AlertDialogContent | `size` | `"default" \| "sm"` | `"default"` |
| AlertDialogAction | `variant` | Button variant | `"default"` |
| AlertDialogAction | `size` | Button size | `"default"` |
| AlertDialogCancel | `variant` | Button variant | `"outline"` |
| AlertDialogCancel | `size` | Button size | `"default"` |

#### Rendered HTML (Content)

```html
<div data-slot="alert-dialog-content" data-size="default" role="alertdialog"
  class="group/alert-dialog-content fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 shadow-lg ... data-[size=sm]:max-w-xs data-[size=default]:sm:max-w-lg">
  <div data-slot="alert-dialog-header" class="grid grid-rows-[auto_1fr] place-items-center gap-1.5 text-center ...">
    <div data-slot="alert-dialog-media" class="mb-2 inline-flex size-16 items-center justify-center rounded-md bg-muted ...">
      <!-- icon -->
    </div>
    <h2 data-slot="alert-dialog-title" class="text-lg font-semibold">...</h2>
    <p data-slot="alert-dialog-description" class="text-sm text-muted-foreground">...</p>
  </div>
  <div data-slot="alert-dialog-footer" class="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
    <button data-slot="alert-dialog-cancel">Cancel</button>
    <button data-slot="alert-dialog-action">Continue</button>
  </div>
</div>
```

#### ARIA

- Content: `role="alertdialog"`, `aria-modal="true"`, `aria-labelledby`, `aria-describedby`
- Focus trapped, Escape closes and returns focus to trigger

#### Keyboard: Same as Dialog

---

### Sheet

**Underlying primitive**: Radix `Dialog` (Sheet is a Dialog variant)

#### Sub-components

Sheet, SheetTrigger, SheetClose, SheetPortal, SheetOverlay, SheetContent, SheetHeader, SheetFooter, SheetTitle, SheetDescription

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| SheetContent | `side` | `"top" \| "right" \| "bottom" \| "left"` | `"right"` |
| SheetContent | `showCloseButton` | `boolean` | `true` |

#### Rendered HTML (Content)

```html
<div data-slot="sheet-content"
  class="fixed z-50 flex flex-col gap-4 bg-background shadow-lg transition ease-in-out
    data-[state=closed]:duration-300 data-[state=open]:duration-500
    inset-y-0 right-0 h-full w-3/4 border-l
    data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right
    sm:max-w-sm">
  <div data-slot="sheet-header" class="flex flex-col gap-1.5 p-4">
    <h2 data-slot="sheet-title" class="font-semibold text-foreground">...</h2>
    <p data-slot="sheet-description" class="text-sm text-muted-foreground">...</p>
  </div>
  <!-- children -->
  <div data-slot="sheet-footer" class="mt-auto flex flex-col gap-2 p-4">...</div>
  <!-- close button -->
</div>
```

#### Side-specific Classes

| Side | Position | Animation |
|---|---|---|
| right | `inset-y-0 right-0 h-full w-3/4 border-l sm:max-w-sm` | `slide-in-from-right` / `slide-out-to-right` |
| left | `inset-y-0 left-0 h-full w-3/4 border-r sm:max-w-sm` | `slide-in-from-left` / `slide-out-to-left` |
| top | `inset-x-0 top-0 h-auto border-b` | `slide-in-from-top` / `slide-out-to-top` |
| bottom | `inset-x-0 bottom-0 h-auto border-t` | `slide-in-from-bottom` / `slide-out-to-bottom` |

#### ARIA: Same as Dialog (role="dialog", aria-modal="true", etc.)
#### Keyboard: Same as Dialog

---

### Drawer

**Underlying primitive**: `vaul` by emilkowalski (NOT Radix)

#### Sub-components

Drawer, DrawerTrigger, DrawerPortal, DrawerOverlay, DrawerClose, DrawerContent, DrawerHeader, DrawerFooter, DrawerTitle, DrawerDescription

#### Props

| Prop | Type | Description |
|---|---|---|
| `direction` | `"top" \| "right" \| "bottom" \| "left"` | Drawer direction |

#### Rendered HTML (Content - bottom direction)

```html
<div data-slot="drawer-content" data-vaul-drawer-direction="bottom"
  class="group/drawer-content fixed z-50 flex h-auto flex-col bg-background
    inset-x-0 bottom-0 mt-24 max-h-[80vh] rounded-t-lg border-t">
  <!-- Drag handle (bottom only) -->
  <div class="mx-auto mt-4 hidden h-2 w-[100px] shrink-0 rounded-full bg-muted group-data-[vaul-drawer-direction=bottom]/drawer-content:block" />
  <div data-slot="drawer-header" class="flex flex-col gap-0.5 p-4 ... md:text-left">
    <h2 data-slot="drawer-title" class="font-semibold text-foreground">...</h2>
    <p data-slot="drawer-description" class="text-sm text-muted-foreground">...</p>
  </div>
  <!-- children -->
  <div data-slot="drawer-footer" class="mt-auto flex flex-col gap-2 p-4">...</div>
</div>
```

#### Direction-specific Classes

| Direction | Classes |
|---|---|
| bottom | `inset-x-0 bottom-0 mt-24 max-h-[80vh] rounded-t-lg border-t` |
| top | `inset-x-0 top-0 mb-24 max-h-[80vh] rounded-b-lg border-b` |
| right | `inset-y-0 right-0 w-3/4 border-l sm:max-w-sm` |
| left | `inset-y-0 left-0 w-3/4 border-r sm:max-w-sm` |

#### ARIA: Vaul manages dialog-like ARIA (role="dialog", focus trapping)
#### Keyboard: Escape to close; supports swipe/drag gestures

---

### Popover

**Underlying primitive**: Radix `Popover`
**WAI-ARIA**: Dialog pattern (non-modal)

#### Sub-components

Popover, PopoverTrigger, PopoverContent, PopoverAnchor, PopoverHeader, PopoverTitle, PopoverDescription

#### Rendered HTML (Content)

```html
<!-- Rendered in a Portal -->
<div data-slot="popover-content"
  class="z-50 w-72 origin-(--radix-popover-content-transform-origin) rounded-md border bg-popover p-4 text-popover-foreground shadow-md outline-hidden
    data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2
    data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2
    data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95
    data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95">
  ...
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| PopoverContent | `align` | `"start" \| "center" \| "end"` | `"center"` |
| PopoverContent | `sideOffset` | `number` | `4` |

#### ARIA

- Trigger: `aria-expanded`, `aria-controls`
- Content: focus managed, `onOpenAutoFocus` / `onCloseAutoFocus`

#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Toggle popover |
| Tab | Move to next focusable |
| Shift+Tab | Move to previous focusable |
| Escape | Close, focus returns to trigger |

---

### Tooltip

**Underlying primitive**: Radix `Tooltip`

#### Sub-components

TooltipProvider, Tooltip, TooltipTrigger, TooltipContent

#### Rendered HTML (Content)

```html
<!-- Provider wraps app root with delayDuration=0 -->
<!-- In portal: -->
<div data-slot="tooltip-content"
  class="z-50 w-fit origin-(--radix-tooltip-content-transform-origin) animate-in rounded-md bg-foreground px-3 py-1.5 text-xs text-balance text-background fade-in-0 zoom-in-95
    data-[side=bottom]:slide-in-from-top-2 ...
    data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95">
  <!-- children -->
  <!-- Arrow -->
  <div class="z-50 size-2.5 translate-y-[calc(-50%_-_2px)] rotate-45 rounded-[2px] bg-foreground fill-foreground" />
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| TooltipProvider | `delayDuration` | `number` | `0` |
| TooltipContent | `sideOffset` | `number` | `0` |
| TooltipContent | `side` | `"top" \| "right" \| "bottom" \| "left"` | (auto) |

#### ARIA

- Content is linked to trigger via `aria-describedby`
- Tooltip is supplemental (screen readers announce via describedby)

#### Keyboard

| Key | Action |
|---|---|
| Tab (focus trigger) | Opens tooltip |
| Escape | Closes tooltip |
| Space/Enter | Closes tooltip |

---

### Hover Card

**Underlying primitive**: Radix `HoverCard`

**Important**: Hover card content is supplemental only. It is **ignored by screen readers** and **inaccessible to keyboard-only users** by design. The underlying link/trigger must provide all essential information.

#### Sub-components

HoverCard, HoverCardTrigger, HoverCardContent

#### Rendered HTML (Content)

```html
<div data-slot="hover-card-content"
  class="z-50 w-64 origin-(--radix-hover-card-content-transform-origin) rounded-md border bg-popover p-4 text-popover-foreground shadow-md outline-hidden
    data-[side=bottom]:slide-in-from-top-2 ...
    data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95
    data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95">
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| HoverCard | `openDelay` | `number` | `700` |
| HoverCard | `closeDelay` | `number` | `300` |
| HoverCardContent | `align` | `"start" \| "center" \| "end"` | `"center"` |
| HoverCardContent | `sideOffset` | `number` | `4` |
| HoverCardContent | `side` | `"top" \| "right" \| "bottom" \| "left"` | (auto) |

#### ARIA: Content ignored by screen readers
#### Keyboard: Tab opens/closes; Enter activates underlying link

---

### Context Menu

**Underlying primitive**: Radix `ContextMenu`
**WAI-ARIA**: Menu pattern with roving tabindex

#### Sub-components

ContextMenu, ContextMenuTrigger, ContextMenuContent, ContextMenuItem, ContextMenuCheckboxItem, ContextMenuRadioGroup, ContextMenuRadioItem, ContextMenuLabel, ContextMenuSeparator, ContextMenuShortcut, ContextMenuGroup, ContextMenuPortal, ContextMenuSub, ContextMenuSubTrigger, ContextMenuSubContent

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| ContextMenuItem | `variant` | `"default" \| "destructive"` | `"default"` |
| ContextMenuItem | `inset` | `boolean` | `false` |
| ContextMenuSubTrigger | `inset` | `boolean` | `false` |
| ContextMenuLabel | `inset` | `boolean` | `false` |

#### Common Item Classes

```
relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none
focus:bg-accent focus:text-accent-foreground
data-[disabled]:pointer-events-none data-[disabled]:opacity-50
data-[inset]:pl-8
data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10
```

#### CheckboxItem / RadioItem Structure

```html
<div class="relative flex cursor-default items-center gap-2 rounded-sm py-1.5 pr-2 pl-8 text-sm ...">
  <span class="pointer-events-none absolute left-2 flex size-3.5 items-center justify-center">
    <!-- ItemIndicator: CheckIcon (checkbox) or CircleIcon (radio) -->
  </span>
  <!-- children -->
</div>
```

#### ARIA: `role="menu"`, `role="menuitem"`, `role="menuitemcheckbox"`, `role="menuitemradio"`
#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Activate focused item |
| ArrowDown | Next item |
| ArrowUp | Previous item |
| ArrowRight | Open submenu (on SubTrigger) |
| ArrowLeft | Close submenu |
| Escape | Close menu |

---

### Dropdown Menu

**Underlying primitive**: Radix `DropdownMenu`
**WAI-ARIA**: Menu Button pattern with roving tabindex

#### Sub-components

DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuGroup, DropdownMenuLabel, DropdownMenuItem, DropdownMenuCheckboxItem, DropdownMenuRadioGroup, DropdownMenuRadioItem, DropdownMenuSeparator, DropdownMenuShortcut, DropdownMenuSub, DropdownMenuSubTrigger, DropdownMenuSubContent, DropdownMenuPortal

#### Structure is identical to Context Menu (same classes, same sub-component patterns)

The only difference is:
- Triggered by button click (not right-click)
- Content has `sideOffset={4}` by default
- Content uses `--radix-dropdown-menu-content-available-height` and `--radix-dropdown-menu-content-transform-origin`

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| DropdownMenuContent | `sideOffset` | `number` | `4` |
| DropdownMenuItem | `variant` | `"default" \| "destructive"` | `"default"` |
| DropdownMenuItem | `inset` | `boolean` | `false` |

#### ARIA & Keyboard: Same as Context Menu, plus:

| Key | Action |
|---|---|
| Space/Enter (on trigger) | Open menu, focus first item |
| ArrowDown (on trigger) | Open menu |

---

### Menubar

**Underlying primitive**: Radix `Menubar`
**WAI-ARIA**: Menu Button pattern with roving tabindex

#### Sub-components

Menubar, MenubarMenu, MenubarTrigger, MenubarContent, MenubarItem, MenubarGroup, MenubarSeparator, MenubarLabel, MenubarShortcut, MenubarCheckboxItem, MenubarRadioGroup, MenubarRadioItem, MenubarSub, MenubarSubTrigger, MenubarSubContent, MenubarPortal

#### Root Menubar HTML

```html
<div data-slot="menubar"
  class="flex h-9 items-center gap-1 rounded-md border bg-background p-1 shadow-xs">
  <!-- MenubarMenu + MenubarTrigger pairs -->
</div>
```

#### Trigger Classes

```
flex items-center rounded-sm px-2 py-1 text-sm font-medium outline-hidden select-none
focus:bg-accent focus:text-accent-foreground
data-[state=open]:bg-accent data-[state=open]:text-accent-foreground
```

#### Content default positioning: `align="start"`, `alignOffset={-4}`, `sideOffset={8}`

Item classes and CheckboxItem/RadioItem structure are identical to DropdownMenu/ContextMenu.

#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Open menu / activate item |
| ArrowDown | Open menu / next item |
| ArrowUp | Previous item |
| ArrowRight/Left | Navigate between menubar triggers; open/close submenus |
| Escape | Close current menu |

---

### Command (Command Palette)

**Underlying primitive**: `cmdk` by pacocoursey (NOT Radix)

#### Sub-components

Command, CommandDialog, CommandInput, CommandList, CommandEmpty, CommandGroup, CommandItem, CommandShortcut, CommandSeparator

#### Rendered HTML

```html
<div data-slot="command"
  class="flex h-full w-full flex-col overflow-hidden rounded-md bg-popover text-popover-foreground">

  <!-- Input wrapper -->
  <div data-slot="command-input-wrapper" class="flex h-9 items-center gap-2 border-b px-3">
    <svg><!-- SearchIcon --></svg>
    <input data-slot="command-input"
      class="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-hidden placeholder:text-muted-foreground ..." />
  </div>

  <!-- List -->
  <div data-slot="command-list" class="max-h-[300px] scroll-py-1 overflow-x-hidden overflow-y-auto">
    <!-- Empty state -->
    <div data-slot="command-empty" class="py-6 text-center text-sm">No results found.</div>

    <!-- Group -->
    <div data-slot="command-group" class="overflow-hidden p-1 text-foreground [&_[cmdk-group-heading]]:px-2 [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-xs [&_[cmdk-group-heading]]:font-medium [&_[cmdk-group-heading]]:text-muted-foreground">
      <!-- Items -->
      <div data-slot="command-item" cmdk-item=""
        class="relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none
          data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50
          data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground
          [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground">
        ...
      </div>
    </div>
  </div>
</div>
```

#### CommandDialog

Wraps Command in a Dialog with `sr-only` header. Props: `title`, `description`, `showCloseButton`.

#### Keyboard

| Key | Action |
|---|---|
| ArrowDown/Up | Navigate items |
| Enter | Select item |
| Escape | Close (in dialog mode) |
| Type-ahead | Filter items in real time |

---

## FORM COMPONENTS

---

### Button

**Underlying primitive**: None (uses Radix `Slot` for `asChild`)
**HTML tag**: `<button>` (or child element when `asChild=true`)

#### Variants (via class-variance-authority)

| Variant | Classes |
|---|---|
| `default` | `bg-primary text-primary-foreground hover:bg-primary/90` |
| `destructive` | `bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:bg-destructive/60` |
| `outline` | `border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50` |
| `secondary` | `bg-secondary text-secondary-foreground hover:bg-secondary/80` |
| `ghost` | `hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50` |
| `link` | `text-primary underline-offset-4 hover:underline` |

#### Sizes

| Size | Classes |
|---|---|
| `default` | `h-9 px-4 py-2 has-[>svg]:px-3` |
| `xs` | `h-6 gap-1 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3` |
| `sm` | `h-8 gap-1.5 rounded-md px-3 has-[>svg]:px-2.5` |
| `lg` | `h-10 rounded-md px-6 has-[>svg]:px-4` |
| `icon` | `size-9` |
| `icon-xs` | `size-6 rounded-md [&_svg:not([class*='size-'])]:size-3` |
| `icon-sm` | `size-8` |
| `icon-lg` | `size-10` |

#### Base Classes (all variants)

```
inline-flex shrink-0 items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap
transition-all outline-none
focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
disabled:pointer-events-none disabled:opacity-50
aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4
```

#### Data Attributes

- `data-slot="button"`
- `data-variant={variant}`
- `data-size={size}`

#### Props

| Prop | Type | Default |
|---|---|---|
| `variant` | `"default" \| "destructive" \| "outline" \| "secondary" \| "ghost" \| "link"` | `"default"` |
| `size` | `"default" \| "xs" \| "sm" \| "lg" \| "icon" \| "icon-xs" \| "icon-sm" \| "icon-lg"` | `"default"` |
| `asChild` | `boolean` | `false` |

#### ARIA: Standard `<button>` semantics
#### Keyboard: Standard button (Space/Enter to activate)

---

### Input

**HTML tag**: `<input>`

#### Rendered HTML

```html
<input data-slot="input" type="text"
  class="h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-xs
    transition-[color,box-shadow] outline-none
    selection:bg-primary selection:text-primary-foreground
    file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground
    placeholder:text-muted-foreground
    disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50
    md:text-sm dark:bg-input/30
    focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
    aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40" />
```

#### Props: All standard HTML `<input>` props plus `className`
#### ARIA: `aria-invalid` for validation state
#### Keyboard: Standard input behavior

---

### Textarea

**HTML tag**: `<textarea>`

#### Rendered HTML

```html
<textarea data-slot="textarea"
  class="flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs
    transition-[color,box-shadow] outline-none
    placeholder:text-muted-foreground
    focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
    disabled:cursor-not-allowed disabled:opacity-50
    aria-invalid:border-destructive aria-invalid:ring-destructive/20
    md:text-sm dark:bg-input/30 dark:aria-invalid:ring-destructive/40" />
```

Note: `field-sizing-content` enables auto-resize based on content (CSS `field-sizing: content`).

#### ARIA: `aria-invalid` for validation
#### Keyboard: Standard textarea behavior

---

### Select

**Underlying primitive**: Radix `Select`
**WAI-ARIA**: ListBox / Select-Only Combobox pattern

#### Sub-components

Select, SelectTrigger, SelectValue, SelectContent, SelectGroup, SelectLabel, SelectItem, SelectSeparator, SelectScrollUpButton, SelectScrollDownButton

#### Rendered HTML (Trigger)

```html
<button data-slot="select-trigger" data-size="default"
  class="flex w-fit items-center justify-between gap-2 rounded-md border border-input bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs
    transition-[color,box-shadow] outline-none
    focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
    disabled:cursor-not-allowed disabled:opacity-50
    aria-invalid:border-destructive
    data-[placeholder]:text-muted-foreground
    data-[size=default]:h-9 data-[size=sm]:h-8
    dark:bg-input/30 dark:hover:bg-input/50">
  <span data-slot="select-value"><!-- selected value --></span>
  <svg><!-- ChevronDownIcon (opacity-50) --></svg>
</button>
```

#### Rendered HTML (Content in Portal)

```html
<div data-slot="select-content"
  class="relative z-50 max-h-(--radix-select-content-available-height) min-w-[8rem] ... rounded-md border bg-popover text-popover-foreground shadow-md">
  <!-- ScrollUpButton -->
  <div class="p-1">
    <!-- SelectItem -->
    <div data-slot="select-item"
      class="relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none focus:bg-accent focus:text-accent-foreground ...">
      <span data-slot="select-item-indicator" class="absolute right-2 flex size-3.5 items-center justify-center">
        <!-- CheckIcon when selected -->
      </span>
      <span><!-- item text --></span>
    </div>
  </div>
  <!-- ScrollDownButton -->
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| SelectTrigger | `size` | `"sm" \| "default"` | `"default"` |
| SelectContent | `position` | `"item-aligned" \| "popper"` | `"item-aligned"` |
| SelectContent | `align` | `"start" \| "center" \| "end"` | `"center"` |
| SelectValue | `placeholder` | `string` | - |

#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Open select / select item |
| ArrowDown/Up | Navigate items |
| Escape | Close select |

---

### Checkbox

**Underlying primitive**: Radix `Checkbox`
**WAI-ARIA**: Tri-state Checkbox pattern

#### Rendered HTML

```html
<button data-slot="checkbox" role="checkbox" aria-checked="true|false|mixed"
  data-state="checked|unchecked|indeterminate"
  class="peer size-4 shrink-0 rounded-[4px] border border-input shadow-xs transition-shadow outline-none
    focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
    disabled:cursor-not-allowed disabled:opacity-50
    aria-invalid:border-destructive aria-invalid:ring-destructive/20
    data-[state=checked]:border-primary data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground
    dark:bg-input/30 dark:data-[state=checked]:bg-primary">
  <span data-slot="checkbox-indicator" class="grid place-content-center text-current transition-none">
    <svg><!-- CheckIcon size-3.5 --></svg>
  </span>
</button>
```

#### Props (from Radix)

| Prop | Type | Description |
|---|---|---|
| `checked` | `boolean \| "indeterminate"` | Controlled state |
| `defaultChecked` | `boolean` | Uncontrolled initial state |
| `onCheckedChange` | `(checked: boolean \| "indeterminate") => void` | Change handler |
| `disabled` | `boolean` | Disabled state |

#### ARIA

- `role="checkbox"`
- `aria-checked="true|false|mixed"`
- `data-state="checked|unchecked|indeterminate"`

#### Keyboard

| Key | Action |
|---|---|
| Space | Toggle checked state |

---

### Radio Group

**Underlying primitive**: Radix `RadioGroup`
**WAI-ARIA**: Radio Group pattern with roving tabindex

#### Sub-components

RadioGroup, RadioGroupItem

#### Rendered HTML

```html
<div data-slot="radio-group" role="radiogroup" class="grid gap-3">
  <button data-slot="radio-group-item" role="radio" aria-checked="true|false"
    class="aspect-square size-4 shrink-0 rounded-full border border-input text-primary shadow-xs
      transition-[color,box-shadow] outline-none
      focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
      disabled:cursor-not-allowed disabled:opacity-50
      dark:bg-input/30">
    <span data-slot="radio-group-indicator" class="relative flex items-center justify-center">
      <svg><!-- CircleIcon size-2 fill-primary (centered absolutely) --></svg>
    </span>
  </button>
</div>
```

#### ARIA

- Group: `role="radiogroup"`
- Item: `role="radio"`, `aria-checked="true|false"`

#### Keyboard

| Key | Action |
|---|---|
| Tab | Focus checked item (or first item) |
| Space | Check focused item |
| ArrowDown/Right | Focus and check next item |
| ArrowUp/Left | Focus and check previous item |

---

### Switch

**Underlying primitive**: Radix `Switch`
**WAI-ARIA**: Switch role

#### Rendered HTML

```html
<button data-slot="switch" role="switch" aria-checked="true|false"
  data-state="checked|unchecked" data-size="default"
  class="peer group/switch inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs
    transition-all outline-none
    focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
    disabled:cursor-not-allowed disabled:opacity-50
    data-[size=default]:h-[1.15rem] data-[size=default]:w-8
    data-[size=sm]:h-3.5 data-[size=sm]:w-6
    data-[state=checked]:bg-primary data-[state=unchecked]:bg-input">
  <span data-slot="switch-thumb"
    class="pointer-events-none block rounded-full bg-background ring-0 transition-transform
      group-data-[size=default]/switch:size-4 group-data-[size=sm]/switch:size-3
      data-[state=checked]:translate-x-[calc(100%-2px)] data-[state=unchecked]:translate-x-0" />
</button>
```

#### Props

| Prop | Type | Default |
|---|---|---|
| `size` | `"sm" \| "default"` | `"default"` |
| `checked` | `boolean` | - |
| `onCheckedChange` | `(checked: boolean) => void` | - |

#### Size Dimensions

| Size | Track | Thumb |
|---|---|---|
| `default` | `h-[1.15rem] w-8` | `size-4` |
| `sm` | `h-3.5 w-6` | `size-3` |

#### ARIA: `role="switch"`, `aria-checked="true|false"`
#### Keyboard: Space and Enter toggle

---

### Slider

**Underlying primitive**: Radix `Slider`
**WAI-ARIA**: Slider pattern

#### Rendered HTML

```html
<span data-slot="slider" data-orientation="horizontal"
  class="relative flex w-full touch-none items-center select-none data-[disabled]:opacity-50 ...">
  <span data-slot="slider-track"
    class="relative grow overflow-hidden rounded-full bg-muted data-[orientation=horizontal]:h-1.5 data-[orientation=horizontal]:w-full ...">
    <span data-slot="slider-range" class="absolute bg-primary data-[orientation=horizontal]:h-full ..." />
  </span>
  <span data-slot="slider-thumb"
    class="block size-4 shrink-0 rounded-full border border-primary bg-white shadow-sm ring-ring/50
      transition-[color,box-shadow] hover:ring-4 focus-visible:ring-4 focus-visible:outline-hidden" />
</span>
```

#### Props

| Prop | Type | Default |
|---|---|---|
| `defaultValue` | `number[]` | - |
| `value` | `number[]` | - |
| `min` | `number` | `0` |
| `max` | `number` | `100` |
| `step` | `number` | `1` |
| `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |
| `onValueChange` | `(value: number[]) => void` | - |

Multiple thumbs: pass array with multiple values (e.g., `[20, 80]` for range).

#### ARIA: `role="slider"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`, `aria-orientation`

#### Keyboard

| Key | Action |
|---|---|
| ArrowRight/Up | Increment by step |
| ArrowLeft/Down | Decrement by step |
| PageUp | Increment by larger step |
| PageDown | Decrement by larger step |
| Home | Set to minimum |
| End | Set to maximum |

---

### Date Picker

**Composite component** built from Popover + Calendar + Button. No dedicated source file.

#### Composition Pattern

```html
<Popover>
  <PopoverTrigger asChild>
    <Button variant="outline" data-empty={!date}>
      <CalendarIcon />
      {date ? format(date, "PPP") : "Pick a date"}
    </Button>
  </PopoverTrigger>
  <PopoverContent>
    <Calendar mode="single" selected={date} onSelect={setDate} />
  </PopoverContent>
</Popover>
```

For range: `<Calendar mode="range" />`

---

### Form (React Hook Form Integration)

**Sub-components**: Form (= FormProvider), FormField, FormItem, FormLabel, FormControl, FormDescription, FormMessage

#### Key ARIA Integration

FormControl (a Radix `Slot`) injects these attributes onto the form control:
- `id={formItemId}`
- `aria-describedby="{formDescriptionId}"` (or `"{formDescriptionId} {formMessageId}"` when error exists)
- `aria-invalid={!!error}`

FormLabel uses `htmlFor={formItemId}` to associate with the control.

FormMessage renders with `id={formMessageId}` so `aria-describedby` references it.

FormDescription renders with `id={formDescriptionId}`.

#### Rendered HTML

```html
<div data-slot="form-item" class="grid gap-2">
  <label data-slot="form-label" data-error="false" for="[id]-form-item"
    class="data-[error=true]:text-destructive">Email</label>
  <!-- FormControl wraps the actual input, injecting id, aria-describedby, aria-invalid -->
  <input id="[id]-form-item" aria-describedby="[id]-form-item-description [id]-form-item-message" aria-invalid="false" />
  <p data-slot="form-description" id="[id]-form-item-description"
    class="text-sm text-muted-foreground">Enter your email</p>
  <p data-slot="form-message" id="[id]-form-item-message"
    class="text-sm text-destructive">Error message</p>
</div>
```

---

### Field (Layout Component)

**Sub-components**: Field, FieldSet, FieldLegend, FieldGroup, FieldLabel, FieldContent, FieldTitle, FieldDescription, FieldSeparator, FieldError

This is a layout component for composing form fields with labels, descriptions, and error messages. It uses `role="group"` and supports orientation variants.

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| Field | `orientation` | `"vertical" \| "horizontal" \| "responsive"` | `"vertical"` |
| FieldLegend | `variant` | `"legend" \| "label"` | `"legend"` |

#### Key CSS patterns

- Field: `data-[invalid=true]:text-destructive`
- FieldLabel wraps content and supports "choice card" pattern via border styling when child has `data-[state=checked]`
- FieldError: `role="alert"`

---

### Label

**Underlying primitive**: Radix `Label`
**HTML tag**: `<label>`

#### Rendered HTML

```html
<label data-slot="label"
  class="flex items-center gap-2 text-sm leading-none font-medium select-none
    group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50
    peer-disabled:cursor-not-allowed peer-disabled:opacity-50">
</label>
```

---

## DATA DISPLAY COMPONENTS

---

### Table

**HTML tags**: Native `<table>`, `<thead>`, `<tbody>`, `<tfoot>`, `<tr>`, `<th>`, `<td>`, `<caption>`

#### Sub-components

Table, TableHeader, TableBody, TableFooter, TableHead, TableRow, TableCell, TableCaption

#### Rendered HTML

```html
<div data-slot="table-container" class="relative w-full overflow-x-auto">
  <table data-slot="table" class="w-full caption-bottom text-sm">
    <caption data-slot="table-caption" class="mt-4 text-sm text-muted-foreground">...</caption>
    <thead data-slot="table-header" class="[&_tr]:border-b">
      <tr data-slot="table-row" class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
        <th data-slot="table-head" class="h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-foreground [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]">...</th>
      </tr>
    </thead>
    <tbody data-slot="table-body" class="[&_tr:last-child]:border-0">
      <tr data-slot="table-row">
        <td data-slot="table-cell" class="p-2 align-middle whitespace-nowrap [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]">...</td>
      </tr>
    </tbody>
    <tfoot data-slot="table-footer" class="border-t bg-muted/50 font-medium [&>tr]:last:border-b-0">...</tfoot>
  </table>
</div>
```

#### Row selection: `data-[state=selected]:bg-muted` on TableRow
#### ARIA: Native table semantics
#### Keyboard: Standard table navigation

---

### Badge

**HTML tag**: `<span>` (or child via `asChild`)

#### Variants (via class-variance-authority)

| Variant | Classes |
|---|---|
| `default` | `bg-primary text-primary-foreground [a&]:hover:bg-primary/90` |
| `secondary` | `bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90` |
| `destructive` | `bg-destructive text-white focus-visible:ring-destructive/20 dark:bg-destructive/60 [a&]:hover:bg-destructive/90` |
| `outline` | `border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground` |
| `ghost` | `[a&]:hover:bg-accent [a&]:hover:text-accent-foreground` |
| `link` | `text-primary underline-offset-4 [a&]:hover:underline` |

#### Base Classes

```
inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden rounded-full
border border-transparent px-2 py-0.5 text-xs font-medium whitespace-nowrap
transition-[color,box-shadow]
focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
[&>svg]:pointer-events-none [&>svg]:size-3
```

#### Data Attributes: `data-slot="badge"`, `data-variant={variant}`

#### Props

| Prop | Type | Default |
|---|---|---|
| `variant` | `"default" \| "secondary" \| "destructive" \| "outline" \| "ghost" \| "link"` | `"default"` |
| `asChild` | `boolean` | `false` |

---

### Avatar

**Underlying primitive**: Radix `Avatar`

#### Sub-components

Avatar, AvatarImage, AvatarFallback, AvatarBadge, AvatarGroup, AvatarGroupCount

#### Rendered HTML

```html
<span data-slot="avatar" data-size="default"
  class="group/avatar relative flex size-8 shrink-0 overflow-hidden rounded-full select-none
    data-[size=lg]:size-10 data-[size=sm]:size-6">
  <img data-slot="avatar-image" class="aspect-square size-full" src="..." alt="..." />
  <!-- OR fallback when image fails: -->
  <span data-slot="avatar-fallback"
    class="flex size-full items-center justify-center rounded-full bg-muted text-sm text-muted-foreground group-data-[size=sm]/avatar:text-xs">
    CN
  </span>
  <!-- Optional badge: -->
  <span data-slot="avatar-badge"
    class="absolute right-0 bottom-0 z-10 inline-flex items-center justify-center rounded-full bg-primary text-primary-foreground ring-2 ring-background select-none
      group-data-[size=default]/avatar:size-2.5 ..." />
</span>
```

#### Avatar Group

```html
<div data-slot="avatar-group"
  class="group/avatar-group flex -space-x-2 *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background">
  <!-- Avatar components -->
  <div data-slot="avatar-group-count" class="relative flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm text-muted-foreground ring-2 ring-background">
    +3
  </div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| Avatar | `size` | `"default" \| "sm" \| "lg"` | `"default"` |

#### Size Dimensions

| Size | Dimension |
|---|---|
| `sm` | `size-6` (24px) |
| `default` | `size-8` (32px) |
| `lg` | `size-10` (40px) |

---

### Calendar

**Underlying primitive**: `react-day-picker`

#### Props

| Prop | Type | Default |
|---|---|---|
| `mode` | `"single" \| "range" \| "multiple"` | - |
| `selected` | `Date \| DateRange` | - |
| `onSelect` | callback | - |
| `showOutsideDays` | `boolean` | `true` |
| `captionLayout` | `"label" \| "dropdown"` | `"label"` |
| `showWeekNumber` | `boolean` | `false` |
| `buttonVariant` | Button variant | `"ghost"` |

#### Cell size: `--cell-size: --spacing(8)` (32px)

#### Day button renders as Button with `variant="ghost"` and `size="icon"`

#### Data attributes on day buttons

- `data-selected-single` - single date selected (not range)
- `data-range-start` - start of range
- `data-range-end` - end of range
- `data-range-middle` - middle of range

#### ARIA: DayPicker provides ARIA grid semantics
#### Keyboard: DayPicker keyboard navigation (arrow keys, Home/End, PageUp/PageDown for month navigation)

---

### Carousel

**Underlying primitive**: `embla-carousel-react`

#### Sub-components

Carousel, CarouselContent, CarouselItem, CarouselPrevious, CarouselNext

#### Rendered HTML

```html
<div data-slot="carousel" role="region" aria-roledescription="carousel" class="relative">
  <div data-slot="carousel-content" class="overflow-hidden">
    <div class="flex -ml-4"> <!-- or -mt-4 flex-col for vertical -->
      <div data-slot="carousel-item" role="group" aria-roledescription="slide"
        class="min-w-0 shrink-0 grow-0 basis-full pl-4"> <!-- or pt-4 for vertical -->
        ...
      </div>
    </div>
  </div>
  <button data-slot="carousel-previous" class="absolute size-8 rounded-full top-1/2 -left-12 -translate-y-1/2">
    <svg><!-- ArrowLeft --></svg>
    <span class="sr-only">Previous slide</span>
  </button>
  <button data-slot="carousel-next" class="absolute size-8 rounded-full top-1/2 -right-12 -translate-y-1/2">
    <svg><!-- ArrowRight --></svg>
    <span class="sr-only">Next slide</span>
  </button>
</div>
```

#### Props

| Prop | Type | Default |
|---|---|---|
| `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |
| `opts` | Embla options | - |
| `plugins` | Embla plugins | - |
| `setApi` | `(api) => void` | - |

#### ARIA

- Root: `role="region"`, `aria-roledescription="carousel"`
- Items: `role="group"`, `aria-roledescription="slide"`
- Previous: `<span class="sr-only">Previous slide</span>`
- Next: `<span class="sr-only">Next slide</span>`

#### Keyboard

| Key | Action |
|---|---|
| ArrowLeft | Previous slide |
| ArrowRight | Next slide |

---

### Chart

**Underlying primitive**: Recharts

#### Sub-components

ChartContainer, ChartTooltip, ChartTooltipContent, ChartLegend, ChartLegendContent, ChartStyle

#### ChartConfig Type

```typescript
type ChartConfig = {
  [key: string]: {
    label?: React.ReactNode
    icon?: React.ComponentType
  } & ({ color?: string } | { theme: { light: string; dark: string } })
}
```

#### CSS Variables

Charts use `--color-{key}` CSS variables, generated dynamically via `<style>` tag. Light/dark theme support via `.dark` selector.

Chart CSS variables: `--chart-1` through `--chart-5` defined in the global theme.

#### Tooltip indicator styles: `"dot"` (2.5x2.5), `"line"` (w-1), `"dashed"` (border dashed)

#### ARIA: `accessibilityLayer` prop on Recharts components enables keyboard/screen reader support

---

## NAVIGATION COMPONENTS

---

### Tabs

**Underlying primitive**: Radix `Tabs`
**WAI-ARIA**: Tabs pattern (tablist, tab, tabpanel)

#### Sub-components

Tabs, TabsList, TabsTrigger, TabsContent

#### Rendered HTML

```html
<div data-slot="tabs" data-orientation="horizontal"
  class="group/tabs flex gap-2 data-[orientation=horizontal]:flex-col">
  <div data-slot="tabs-list" data-variant="default"
    class="group/tabs-list inline-flex w-fit items-center justify-center rounded-lg p-[3px] text-muted-foreground
      group-data-[orientation=horizontal]/tabs:h-9 bg-muted">
    <button data-slot="tabs-trigger" data-state="active" role="tab"
      class="relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap
        data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm ...">
      Account
    </button>
  </div>
  <div data-slot="tabs-content" role="tabpanel" class="flex-1 outline-none">...</div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| Tabs | `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |
| Tabs | `defaultValue` | `string` | - |
| TabsList | `variant` | `"default" \| "line"` | `"default"` |
| TabsTrigger | `value` | `string` | (required) |
| TabsTrigger | `disabled` | `boolean` | - |
| TabsContent | `value` | `string` | (required) |

#### Line Variant

When `variant="line"` on TabsList:
- Background removed (`bg-transparent`)
- Active indicator: pseudo-element `after:` with `bg-foreground` and conditional position based on orientation
- Horizontal: bottom bar (`after:bottom-[-5px] after:h-0.5`)
- Vertical: right bar (`after:-right-1 after:w-0.5`)

#### ARIA

- TabsList: `role="tablist"`
- TabsTrigger: `role="tab"`, `aria-selected="true|false"`, `aria-controls="[panel-id]"`
- TabsContent: `role="tabpanel"`, `aria-labelledby="[tab-id]"`

#### Keyboard

| Key | Action |
|---|---|
| Tab | Focus active tab; then move to panel |
| ArrowRight/Down | Next tab (activates it) |
| ArrowLeft/Up | Previous tab (activates it) |
| Home | First tab |
| End | Last tab |

---

### Navigation Menu

**Underlying primitive**: Radix `NavigationMenu`
**WAI-ARIA**: `navigation` role (NOT `menu` role)

#### Sub-components

NavigationMenu, NavigationMenuList, NavigationMenuItem, NavigationMenuTrigger, NavigationMenuContent, NavigationMenuLink, NavigationMenuViewport, NavigationMenuIndicator

#### Rendered HTML

```html
<nav data-slot="navigation-menu" data-viewport="true"
  class="group/navigation-menu relative flex max-w-max flex-1 items-center justify-center">
  <ul data-slot="navigation-menu-list" class="group flex flex-1 list-none items-center justify-center gap-1">
    <li data-slot="navigation-menu-item" class="relative">
      <button data-slot="navigation-menu-trigger"
        class="group inline-flex h-9 w-max items-center justify-center rounded-md bg-background px-4 py-2 text-sm font-medium
          hover:bg-accent hover:text-accent-foreground
          data-[state=open]:bg-accent/50 data-[state=open]:text-accent-foreground">
        Getting started
        <svg aria-hidden="true"><!-- ChevronDownIcon, rotates when open --></svg>
      </button>
      <div data-slot="navigation-menu-content" class="top-0 left-0 w-full p-2 ...">
        <a data-slot="navigation-menu-link" class="flex flex-col gap-1 rounded-sm p-2 text-sm ...">
          ...
        </a>
      </div>
    </li>
  </ul>
  <!-- Viewport (portal for content) -->
  <div class="absolute top-full left-0 isolate z-50 flex justify-center">
    <div data-slot="navigation-menu-viewport"
      class="origin-top-center relative mt-1.5 h-[var(--radix-navigation-menu-viewport-height)] w-full overflow-hidden rounded-md border bg-popover text-popover-foreground shadow ...">
    </div>
  </div>
</nav>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| NavigationMenu | `viewport` | `boolean` | `true` |

#### Exported utility: `navigationMenuTriggerStyle` (cva class string for trigger styling)

#### Active link: `data-[active=true]` on NavigationMenuLink sets `aria-current`

#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Open content (on trigger) |
| Tab | Next focusable |
| ArrowDown | Into content or next trigger |
| ArrowUp | Previous trigger |
| ArrowRight/Left | Next/previous (vertical) |
| Home/End | First/last trigger |
| Escape | Close content |

---

### Breadcrumb

**HTML tags**: `<nav>`, `<ol>`, `<li>`, `<a>`, `<span>`

#### Sub-components

Breadcrumb, BreadcrumbList, BreadcrumbItem, BreadcrumbLink, BreadcrumbPage, BreadcrumbSeparator, BreadcrumbEllipsis

#### Rendered HTML

```html
<nav aria-label="breadcrumb" data-slot="breadcrumb">
  <ol data-slot="breadcrumb-list"
    class="flex flex-wrap items-center gap-1.5 text-sm break-words text-muted-foreground sm:gap-2.5">
    <li data-slot="breadcrumb-item" class="inline-flex items-center gap-1.5">
      <a data-slot="breadcrumb-link" class="transition-colors hover:text-foreground" href="/">Home</a>
    </li>
    <li data-slot="breadcrumb-separator" role="presentation" aria-hidden="true" class="[&>svg]:size-3.5">
      <svg><!-- ChevronRight --></svg>
    </li>
    <li data-slot="breadcrumb-item" class="inline-flex items-center gap-1.5">
      <span data-slot="breadcrumb-page" role="link" aria-disabled="true" aria-current="page"
        class="font-normal text-foreground">Current Page</span>
    </li>
  </ol>
</nav>
```

#### ARIA

- Nav: `aria-label="breadcrumb"`
- Separator: `role="presentation"`, `aria-hidden="true"`
- Current page: `aria-current="page"`, `aria-disabled="true"`, `role="link"`
- Ellipsis: `role="presentation"`, `aria-hidden="true"`, `<span class="sr-only">More</span>`

---

### Pagination

**HTML tags**: `<nav>`, `<ul>`, `<li>`, `<a>`

#### Sub-components

Pagination, PaginationContent, PaginationItem, PaginationLink, PaginationPrevious, PaginationNext, PaginationEllipsis

#### Rendered HTML

```html
<nav role="navigation" aria-label="pagination" data-slot="pagination"
  class="mx-auto flex w-full justify-center">
  <ul data-slot="pagination-content" class="flex flex-row items-center gap-1">
    <li data-slot="pagination-item">
      <a aria-label="Go to previous page" data-slot="pagination-link"
        class="gap-1 px-2.5 sm:pl-2.5 [buttonVariants ghost default]">
        <svg><!-- ChevronLeftIcon --></svg>
        <span class="hidden sm:block">Previous</span>
      </a>
    </li>
    <li data-slot="pagination-item">
      <a data-slot="pagination-link" data-active="true" aria-current="page"
        class="[buttonVariants outline icon]">1</a>
    </li>
    <li>
      <span aria-hidden data-slot="pagination-ellipsis" class="flex size-9 items-center justify-center">
        <svg><!-- MoreHorizontalIcon --></svg>
        <span class="sr-only">More pages</span>
      </span>
    </li>
  </ul>
</nav>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| PaginationLink | `isActive` | `boolean` | - |
| PaginationLink | `size` | Button size | `"icon"` |

Active link uses `variant="outline"`, inactive uses `variant="ghost"`.

#### ARIA

- Nav: `role="navigation"`, `aria-label="pagination"`
- Active page: `aria-current="page"`
- Previous: `aria-label="Go to previous page"`
- Next: `aria-label="Go to next page"`
- Ellipsis: `aria-hidden`, `<span class="sr-only">More pages</span>`

---

### Sidebar

**Composite component** using Sheet (mobile), Tooltip, Button, Input, Separator, Skeleton

#### Sub-components

SidebarProvider, Sidebar, SidebarTrigger, SidebarRail, SidebarInset, SidebarInput, SidebarHeader, SidebarFooter, SidebarSeparator, SidebarContent, SidebarGroup, SidebarGroupLabel, SidebarGroupAction, SidebarGroupContent, SidebarMenu, SidebarMenuItem, SidebarMenuButton, SidebarMenuAction, SidebarMenuBadge, SidebarMenuSkeleton, SidebarMenuSub, SidebarMenuSubItem, SidebarMenuSubButton

#### CSS Variables

| Variable | Default |
|---|---|
| `--sidebar-width` | `16rem` |
| `--sidebar-width-mobile` | `18rem` |
| `--sidebar-width-icon` | `3rem` |

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| SidebarProvider | `defaultOpen` | `boolean` | `true` |
| SidebarProvider | `open` | `boolean` | - |
| SidebarProvider | `onOpenChange` | `(open: boolean) => void` | - |
| Sidebar | `side` | `"left" \| "right"` | `"left"` |
| Sidebar | `variant` | `"sidebar" \| "floating" \| "inset"` | `"sidebar"` |
| Sidebar | `collapsible` | `"offcanvas" \| "icon" \| "none"` | `"offcanvas"` |
| SidebarMenuButton | `variant` | `"default" \| "outline"` | `"default"` |
| SidebarMenuButton | `size` | `"default" \| "sm" \| "lg"` | `"default"` |
| SidebarMenuButton | `isActive` | `boolean` | `false` |
| SidebarMenuButton | `tooltip` | `string \| TooltipContentProps` | - |
| SidebarMenuButton | `asChild` | `boolean` | `false` |

#### Collapsible Modes

| Mode | Behavior |
|---|---|
| `offcanvas` | Slides off-screen (sidebar width becomes 0) |
| `icon` | Collapses to `--sidebar-width-icon` (3rem), icon-only |
| `none` | Fixed, non-collapsible |

#### Mobile: Uses Sheet component with `side` prop
#### Desktop: Fixed position with CSS transition on width

#### Keyboard: `Cmd+B` (Mac) / `Ctrl+B` (Windows) toggles sidebar

#### useSidebar Hook

```typescript
{
  state: "expanded" | "collapsed"
  open: boolean
  setOpen: (open: boolean) => void
  openMobile: boolean
  setOpenMobile: (open: boolean) => void
  isMobile: boolean
  toggleSidebar: () => void
}
```

#### Data attributes used for styling

- `data-state="expanded|collapsed"` on Sidebar root
- `data-collapsible="offcanvas|icon"` on Sidebar root
- `data-variant="sidebar|floating|inset"` on Sidebar root
- `data-side="left|right"` on Sidebar root
- `data-active="true"` on SidebarMenuButton
- `data-size="default|sm|lg"` on SidebarMenuButton

#### SidebarMenuButton Size Classes

| Size | Classes |
|---|---|
| `default` | `h-8 text-sm` |
| `sm` | `h-7 text-xs` |
| `lg` | `h-12 text-sm` |

---

## FEEDBACK COMPONENTS

---

### Alert

**HTML tag**: `<div>` with `role="alert"`

#### Variants (via class-variance-authority)

| Variant | Classes |
|---|---|
| `default` | `bg-card text-card-foreground` |
| `destructive` | `bg-card text-destructive *:data-[slot=alert-description]:text-destructive/90 [&>svg]:text-current` |

#### Base Classes

```
relative grid w-full grid-cols-[0_1fr] items-start gap-y-0.5 rounded-lg border px-4 py-3 text-sm
has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>svg]:gap-x-3
[&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current
```

#### Rendered HTML

```html
<div data-slot="alert" role="alert" class="[alertVariants]">
  <svg><!-- Icon --></svg>
  <div data-slot="alert-title" class="col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight">Title</div>
  <div data-slot="alert-description" class="col-start-2 grid justify-items-start gap-1 text-sm text-muted-foreground [&_p]:leading-relaxed">
    Description
  </div>
</div>
```

#### ARIA: `role="alert"`
#### Keyboard: None (static content)

---

### Toast / Sonner

**Underlying library**: `sonner` by emilkowalski

#### Setup

Toaster component wraps Sonner with shadcn theming:

```html
<Toaster
  theme={theme}
  className="toaster group"
  icons={{ success: <CircleCheckIcon />, info: <InfoIcon />, warning: <TriangleAlertIcon />, error: <OctagonXIcon />, loading: <Loader2Icon class="animate-spin" /> }}
  style={{
    "--normal-bg": "var(--popover)",
    "--normal-text": "var(--popover-foreground)",
    "--normal-border": "var(--border)",
    "--border-radius": "var(--radius)"
  }}
/>
```

#### Toast Types

- `toast("message")` - default
- `toast.success("message")`
- `toast.info("message")`
- `toast.warning("message")`
- `toast.error("message")`
- `toast.promise(promise, { loading, success, error })`
- `toast.custom(component)`

#### Position options: `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`

#### ARIA: Sonner manages `role="status"` / `aria-live="polite"` internally

---

### Progress

**Underlying primitive**: Radix `Progress`
**WAI-ARIA**: Progressbar pattern

#### Rendered HTML

```html
<div data-slot="progress" role="progressbar"
  aria-valuenow="33" aria-valuemin="0" aria-valuemax="100"
  class="relative h-2 w-full overflow-hidden rounded-full bg-primary/20">
  <div data-slot="progress-indicator"
    class="h-full w-full flex-1 bg-primary transition-all"
    style="transform: translateX(-67%)">
  </div>
</div>
```

#### Props

| Prop | Type | Default |
|---|---|---|
| `value` | `number` | - |
| `max` | `number` | `100` |

The indicator position is calculated as `translateX(-${100 - (value || 0)}%)`.

#### ARIA: `role="progressbar"`, `aria-valuenow`, `aria-valuemin`, `aria-valuemax`

---

### Skeleton

**HTML tag**: `<div>`

#### Rendered HTML

```html
<div data-slot="skeleton" class="animate-pulse rounded-md bg-accent" />
```

Dimensions are set via className (e.g., `h-4 w-[250px]`, `h-12 w-12 rounded-full`).

#### Animation: `animate-pulse` (CSS opacity pulse animation)
#### ARIA: None (presentational loading placeholder)

---

### Accordion

**Underlying primitive**: Radix `Accordion`
**WAI-ARIA**: Accordion pattern

#### Sub-components

Accordion, AccordionItem, AccordionTrigger, AccordionContent

#### Rendered HTML

```html
<div data-slot="accordion" data-orientation="vertical">
  <div data-slot="accordion-item" data-state="open" class="border-b last:border-b-0">
    <h3 class="flex">
      <button data-slot="accordion-trigger"
        class="flex flex-1 items-start justify-between gap-4 rounded-md py-4 text-left text-sm font-medium
          transition-all outline-none hover:underline
          focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
          [&[data-state=open]>svg]:rotate-180">
        Is it accessible?
        <svg class="pointer-events-none size-4 shrink-0 translate-y-0.5 text-muted-foreground transition-transform duration-200">
          <!-- ChevronDownIcon -->
        </svg>
      </button>
    </h3>
    <div data-slot="accordion-content"
      class="overflow-hidden text-sm data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down">
      <div class="pt-0 pb-4">
        Yes. It adheres to the WAI-ARIA design pattern.
      </div>
    </div>
  </div>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| Accordion | `type` | `"single" \| "multiple"` | (required) |
| Accordion | `collapsible` | `boolean` | `false` |
| AccordionItem | `value` | `string` | (required) |
| AccordionItem | `disabled` | `boolean` | - |

#### Animations

- Opening: `animate-accordion-down` (height 0 to auto)
- Closing: `animate-accordion-up` (height auto to 0)

#### ARIA

- Trigger: `aria-expanded="true|false"`, `aria-controls="[content-id]"`
- Content: `role="region"`, `aria-labelledby="[trigger-id]"`

#### Keyboard

| Key | Action |
|---|---|
| Space/Enter | Toggle section |
| Tab/Shift+Tab | Navigate triggers |
| ArrowDown | Next trigger (vertical) |
| ArrowUp | Previous trigger (vertical) |
| Home | First trigger |
| End | Last trigger |

---

## MISCELLANEOUS COMPONENTS

---

### Toggle

**Underlying primitive**: Radix `Toggle`

#### Variants (via class-variance-authority)

| Variant | Classes |
|---|---|
| `default` | `bg-transparent` |
| `outline` | `border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground` |

#### Sizes

| Size | Classes |
|---|---|
| `default` | `h-9 min-w-9 px-2` |
| `sm` | `h-8 min-w-8 px-1.5` |
| `lg` | `h-10 min-w-10 px-2.5` |

#### Base Classes

```
inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap
transition-[color,box-shadow] outline-none
hover:bg-muted hover:text-muted-foreground
focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
disabled:pointer-events-none disabled:opacity-50
data-[state=on]:bg-accent data-[state=on]:text-accent-foreground
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4
```

#### ARIA: `aria-pressed="true|false"` (managed by Radix), `data-state="on|off"`
#### Keyboard: Space/Enter toggle

---

### Toggle Group

**Underlying primitive**: Radix `ToggleGroup`

#### Sub-components

ToggleGroup, ToggleGroupItem

#### Rendered HTML

```html
<div data-slot="toggle-group" data-variant="default" data-size="default" data-spacing="0"
  class="group/toggle-group flex w-fit items-center gap-[--spacing(var(--gap))] rounded-md">
  <button data-slot="toggle-group-item" data-variant="default" data-size="default" data-spacing="0"
    class="[toggleVariants] w-auto min-w-0 shrink-0 px-3
      data-[spacing=0]:rounded-none data-[spacing=0]:shadow-none
      data-[spacing=0]:first:rounded-l-md data-[spacing=0]:last:rounded-r-md
      data-[spacing=0]:data-[variant=outline]:border-l-0
      data-[spacing=0]:data-[variant=outline]:first:border-l">
    ...
  </button>
</div>
```

#### Props

| Component | Prop | Type | Default |
|---|---|---|---|
| ToggleGroup | `type` | `"single" \| "multiple"` | (required) |
| ToggleGroup | `variant` | `"default" \| "outline"` | `"default"` |
| ToggleGroup | `size` | `"default" \| "sm" \| "lg"` | `"default"` |
| ToggleGroup | `spacing` | `number` | `0` |
| ToggleGroup | `orientation` | `"horizontal" \| "vertical"` | `"horizontal"` |

When `spacing=0`, items are joined (no gap, shared borders, only first/last rounded).
When `spacing > 0`, items have gaps and individual rounding.

#### ARIA: Radix manages `role="group"`, individual items use `aria-pressed`
#### Keyboard: Arrow keys navigate between items, Space/Enter toggle

---

## COMMON PATTERNS

### data-slot Convention

Every shadcn/ui v4 component sets a `data-slot` attribute on its root element (e.g., `data-slot="button"`, `data-slot="dialog-content"`). This is used for:
1. CSS targeting from parent components (e.g., `*:data-[slot=select-value]:line-clamp-1`)
2. Styling children contextually (e.g., `has-data-[slot=card-action]:grid-cols-[1fr_auto]`)
3. Component identification in DOM

### Focus Ring Pattern

Nearly all interactive components use:
```
focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50
```

### Disabled Pattern

```
disabled:pointer-events-none disabled:opacity-50
```
or
```
disabled:cursor-not-allowed disabled:opacity-50
```

### Invalid/Error Pattern

```
aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40
```

### Animation Pattern (Popups/Overlays)

All popover-like content uses side-aware slide animations:
```
data-[side=bottom]:slide-in-from-top-2
data-[side=left]:slide-in-from-right-2
data-[side=right]:slide-in-from-left-2
data-[side=top]:slide-in-from-bottom-2
data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95
data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95
```

### Menu Item Pattern (shared across DropdownMenu, ContextMenu, Menubar)

All three menu types use identical item styling:
```
relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none
focus:bg-accent focus:text-accent-foreground
data-[disabled]:pointer-events-none data-[disabled]:opacity-50
data-[inset]:pl-8
data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4
[&_svg:not([class*='text-'])]:text-muted-foreground
```

Checkbox items: `pl-8` with absolute-positioned indicator at `left-2`, CheckIcon.
Radio items: `pl-8` with absolute-positioned indicator at `left-2`, filled CircleIcon.
Separator: `-mx-1 my-1 h-px bg-border`
Shortcut: `ml-auto text-xs tracking-widest text-muted-foreground`
Label: `px-2 py-1.5 text-sm font-medium`

### SVG Icon Sizing

Global pattern across all components:
```
[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4
```

This sets default icon size to 16px (size-4) but allows override via explicit `size-*` class.
