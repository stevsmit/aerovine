# MkDocs Setup Guide for AeroVine

This guide will help you set up and deploy the AeroVine documentation site using MkDocs.

## Prerequisites

- Python 3.7 or higher
- pip (Python package manager)

## Installation

1. **Install MkDocs and dependencies:**

```bash
pip install -r requirements.txt
```

Or install manually:

```bash
pip install mkdocs mkdocs-material mkdocs-git-revision-date-localized-plugin pymdown-extensions
```

## Local Development

1. **Start the development server:**

```bash
mkdocs serve
```

2. **View the site:**

Open your browser to `http://127.0.0.1:8000`

The site will automatically reload when you make changes to the documentation.

## Building the Site

To build a static version of the site:

```bash
mkdocs build
```

This creates a `site/` directory with the static HTML files.

## Deployment to GitHub Pages

### Option 1: Using GitHub Actions (Recommended)

1. Create `.github/workflows/docs.yml`:

```yaml
name: Deploy Docs

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'
      - 'mkdocs.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: 3.x
      - run: pip install -r requirements.txt
      - run: mkdocs gh-deploy --force
```

2. Push to GitHub - the site will automatically deploy.

### Option 2: Manual Deployment

1. **Build and deploy:**

```bash
mkdocs gh-deploy
```

This will:
- Build the site
- Create/update the `gh-pages` branch
- Deploy to GitHub Pages

2. **Enable GitHub Pages:**

- Go to repository Settings → Pages
- Select source: `gh-pages` branch
- Save

Your site will be available at: `https://stevsmit.github.io/aerovine/`

## Project Structure

```
aerovine/
├── mkdocs.yml          # MkDocs configuration
├── requirements.txt    # Python dependencies
├── docs/              # Documentation source files
│   ├── index.md       # Homepage
│   ├── about/         # About section
│   ├── software/      # Software documentation
│   ├── marketing/     # Marketing materials
│   ├── sales/         # Sales resources
│   ├── hr/            # HR documentation
│   ├── finance/       # Finance documents
│   ├── manufacturing/ # Manufacturing docs
│   └── resources/     # Additional resources
└── site/              # Generated site (created by mkdocs build)
```

## Customization

### Theme Settings

Edit `mkdocs.yml` to customize:
- Colors and palette
- Navigation structure
- Plugins and extensions
- Social links

### Adding New Pages

1. Create a new `.md` file in the appropriate directory under `docs/`
2. Add it to the `nav` section in `mkdocs.yml`
3. The page will appear in the navigation

## Troubleshooting

### Port Already in Use

If port 8000 is in use:

```bash
mkdocs serve -a 127.0.0.1:8001
```

### Build Errors

- Check that all files referenced in `nav` exist
- Ensure markdown syntax is correct
- Check for special characters in file names

### GitHub Pages Not Updating

- Wait a few minutes for GitHub to rebuild
- Check the Actions tab for deployment status
- Verify the `gh-pages` branch exists and has content

## Resources

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

---

*Last Updated: 2025*

