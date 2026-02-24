.PHONY: website pdf dev clean

website:
	npm ci
	npm run build

pdf:
	quarto render --to pdf

dev:
	npm run dev

clean:
	rm -rf dist .astro _book
