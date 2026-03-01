# Psoriasis: The Missing Manual

A collaborative book covering the pathogenesis, immunology, genetics, and therapeutics of psoriasis.

**Not medical advice**.

**Read online:** [psoriasis.fyi](https://psoriasis.fyi)

## Project structure

```
src/content/docs/   Chapters (Starlight markdown)
_quarto.yml         PDF build config (Quarto)
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

Requires [Quarto](https://quarto.org/) and TinyTeX:

```bash
# Install Quarto — pick one:
brew install quarto          # macOS (Homebrew)
sudo apt install quarto      # Debian/Ubuntu
# or download from https://quarto.org/docs/get-started/

# Install TinyTeX (LaTeX distribution used by Quarto)
quarto install tinytex

# Build the PDF
quarto render --to pdf       # Produces _book/Psoriasis.pdf
```

## CI/CD

| Trigger | Action |
|---------|--------|
| Every push / PR | Build website + PDF |
| Merge to `main` | Deploy to GitHub Pages |
| Tag `v*` | Create GitHub Release with PDF |
