# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a German grammar learning resource consisting of 43 static HTML files organized into 5 main topics:
- **Articles** (articles, demonstrative/possessive/personal/reflexive pronouns)
- **Prepositions** (local/temporal/miscellaneous/dual-function)
- **Numbers** (ordinal numbers, fractions)
- **Directions** (directional prepositions for persons/animals/plants/places)
- **Time** (time vocabulary, clock expressions)

Each topic has two organizational variants:
- **Option A** (Thematisch): Content split into separate pages by subtopic
- **Option B** (Kompakt): Related content combined on fewer pages (marked as "Empfohlen"/Recommended)

## Architecture

### File Structure
```
Grammar/
├── index.html                    # Main landing page with topic cards
├── Article/
│   ├── Article.html             # Legacy article page
│   ├── option-a/                # Thematic organization
│   │   ├── index.html           # Navigation page
│   │   ├── articles.html
│   │   └── pronouns-*.html      # 4 pronoun types
│   └── option-b/                # Compact organization
│       ├── index.html
│       ├── articles-and-determiners.html
│       └── pronouns.html
├── Prepositions/
│   ├── dual-function-prepositions.html  # Special: Wechselpräpositionen
│   ├── option-a/                # 8 thematic pages
│   └── option-b/                # 4 compact pages
├── [Numbers|Directions|Time]/   # Similar option-a/option-b structure
└── Prepositions/images/         # Contains dual-function-diagram.png
```

### HTML Page Components

All content pages follow a consistent structure:

1. **Global Navigation** (`global-nav`): Links to all 5 topics + Home
2. **Section Navigation** (`nav`): Links within current topic (only on content pages, not index pages)
3. **Content Area**: Tables with German grammar data
4. **Interactive Buttons**:
   - Style Toggle Button: Switches between color mode and newspaper mode (black/white/gray)
   - Print Button: Single button that calls `window.print()` directly

### CSS Architecture

**Default Mode**: All pages start in `extra-compact-mode` class on `<body>` tag.

**Key CSS Patterns**:
- Base styles: Standard table layout with max-width 950px
- `.extra-compact-mode`: Smaller font (0.75em), reduced padding (4px 6px)
- `.newspaper-style`: Black/white/gray color scheme for book-like appearance
- `@media print`: Hides navigation/buttons, prevents table page breaks

**Critical Print CSS**:
```css
@media print {
    table {
        page-break-inside: avoid !important;
        break-inside: avoid-page !important;
        table-layout: fixed !important;
    }
    tr {
        page-break-inside: avoid !important;
        break-inside: avoid-page !important;
    }
    h1, h2, h3 {
        page-break-after: avoid !important;
        break-after: avoid-page !important;
    }
}
```

### JavaScript Functions

Content pages include:
- `toggleStyle()`: Toggles `newspaper-style` class and updates button text
- No compact mode toggle (removed - pages stay in extra-compact permanently)
- Print button uses direct `window.print()` call

## Maintenance Scripts (PowerShell)

### Verification Scripts
- `check-utf8-encoding.ps1`: Verify UTF-8 without BOM, check for meta charset tags
- `check-page-break-prevention.ps1`: Verify print CSS prevents table breaks
- `final-verification.ps1`: Check for buttons and headers on all pages

### Modification Scripts
- `add-page-break-protection.ps1`: Add/fix print CSS for table protection
- `check-and-add-buttons.ps1`: Add missing style-toggle and print buttons
- `fix-print-simple.ps1`: Replace complex print buttons with single button
- `fix-umlauts-and-default-compact.ps1`: Fix encoding issues, set extra-compact as default

### Content Extraction
- `extract-image-from-odt.ps1`: Extract images from ODT files to `images/` folder
- `Article/read_excel.ps1`: Example of reading Excel source files

### Usage Pattern
```powershell
cd "C:\Users\pc\Documents\Phoenix Code\Grammar"
powershell -ExecutionPolicy Bypass -File <script-name>.ps1
```

## Critical Constraints

### 1. UTF-8 Encoding
- All HTML files MUST use UTF-8 **without BOM**
- Save files using PowerShell:
  ```powershell
  $utf8NoBom = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
  ```
- Emojis encoded as HTML entities (e.g., `&#127968;` for 🏠)

### 2. Table Layout
- All tables use `table-layout: fixed` for equal column widths
- Max-width: 950px
- Tables must have page-break prevention in print CSS

### 3. Page Modes
- **Default**: Extra-compact mode (smallest, most compact)
- **Newspaper Style**: Optional black/white/gray overlay
- **No toggle between modes**: Pages stay in extra-compact permanently

### 4. Print Requirements
- Single print button per page
- Tables MUST NOT break across pages
- Headers MUST NOT separate from their tables
- Use both legacy (`page-break-*`) and modern (`break-*`) CSS properties

### 5. Navigation
- Global nav required on all content pages (not on index pages)
- Section nav only on content pages within topics
- Main index.html has custom card-based navigation

## Common Operations

### Adding New Content Page
1. Copy existing content page as template
2. Ensure `<body class="extra-compact-mode">` is present
3. Add global-nav with correct relative paths
4. Add section-nav with current page marked `class="active"`
5. Include style-toggle-btn and single print-btn
6. Add complete print CSS with page-break prevention
7. Save as UTF-8 without BOM

### Modifying Tables
- Keep `table-layout: fixed` at all times
- Maintain max-width: 950px
- Ensure print CSS includes the table in page-break prevention
- Test that umlauts (ä, ö, ü, ß) display correctly

### Fixing Encoding Issues
- Check for `�` characters (indicates wrong encoding)
- Re-read file and save as UTF-8 without BOM
- Common broken patterns: `f�nf` → `fünf`, `zw�lf` → `zwölf`, `drei�ig` → `dreißig`

### Verifying Changes
Run verification scripts in order:
1. `check-utf8-encoding.ps1` - Ensure UTF-8 compliance
2. `check-and-add-buttons.ps1` - Verify buttons present
3. `check-page-break-prevention.ps1` - Verify print protection
4. `final-verification.ps1` - Overall status check

## Important Notes

- **Option B is recommended**: Main index highlights Option B with ⭐ and larger buttons
- **Dual Function Prepositions**: Special standalone page with visual diagram (`images/dual-function-diagram.png`)
- **Index pages have no buttons**: Only content pages have style-toggle and print buttons
- **Consistent styling**: Do not drastically change layout - maintain existing visual design
- **Test printing**: Always verify tables don't break across pages when printing
