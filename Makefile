.PHONY: website pdf dev clean

website:
	npm ci
	npm run build

pdf:
	sh pdf/build-pdf.sh

dev:
	npm run dev

clean:
	rm -rf dist .astro pdf/build psoriasis-book.pdf
