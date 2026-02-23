# Psoriasis: A Comprehensive Meta-Analysis

A collaborative book covering the pathogenesis, immunology, genetics, and therapeutics of psoriasis.

**Read online:** [psoriasis.fyi](https://psoriasis.fyi)

## Project structure

```
src/content/docs/   Chapters (Starlight markdown)
pdf/                PDF build pipeline (Pandoc + XeLaTeX)
public/             Static assets (visual guide, CNAME)
.github/workflows/  CI/CD (build, deploy, release)
```

## Development

```bash
npm install
npm run dev        # Local Starlight dev server
npm run build      # Production build
```

## PDF generation

Requires [Pandoc](https://pandoc.org/) and XeLaTeX (e.g. TeX Live):

```bash
bash pdf/build-pdf.sh    # Produces psoriasis-book.pdf
```

## CI/CD

| Trigger | Action |
|---------|--------|
| Every push / PR | Build website + PDF |
| Merge to `main` | Deploy to GitHub Pages |
| Tag `v*` | Create GitHub Release with PDF |
