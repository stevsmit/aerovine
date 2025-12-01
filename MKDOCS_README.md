# AeroVine MkDocs Documentation Site

This repository now includes a complete MkDocs documentation site that organizes all AeroVine documentation into a beautiful, searchable website.

## Quick Start

### Local Development

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Start the development server:**
   ```bash
   mkdocs serve
   ```

3. **View the site:**
   Open `http://127.0.0.1:8000` in your browser

### Deploy to GitHub Pages

The site is automatically deployed via GitHub Actions when you push changes to the `main` branch.

**Manual deployment:**
```bash
mkdocs gh-deploy
```

**Site URL:** https://stevsmit.github.io/aerovine/

## Documentation Structure

The documentation is organized by department:

- **Home** - Overview and quick links
- **About** - Company mission, vision, and overview
- **Software** - API docs, architecture, technical requirements
- **Marketing** - Brand guidelines, campaigns, press releases
- **Sales** - Sales playbook and processes
- **HR** - Employee handbooks, job descriptions, org charts
- **Finance** - Financial models and projections
- **Manufacturing** - Operations and production docs
- **Resources** - Additional documentation and guides

## Features

- ✅ Material Design theme with dark mode
- ✅ Full-text search
- ✅ Responsive design (mobile-friendly)
- ✅ Automatic GitHub Pages deployment
- ✅ Git revision dates on pages
- ✅ Code syntax highlighting
- ✅ Navigation tabs and sections

## Configuration

- **Config file:** `mkdocs.yml`
- **Source files:** `docs/` directory
- **Build output:** `site/` directory (gitignored)

## Adding New Documentation

1. Create a new `.md` file in the appropriate `docs/` subdirectory
2. Add it to the `nav` section in `mkdocs.yml`
3. Commit and push - the site will automatically rebuild

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Setup Guide](MKDOCS_SETUP.md)

---

*For detailed setup instructions, see [MKDOCS_SETUP.md](MKDOCS_SETUP.md)*

