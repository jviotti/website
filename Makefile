HERE := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
.DEFAULT_GOAL = all
PORT ?= 4000

PANDOC ?= pandoc
SED ?= sed
INSTALL ?= install
CONVERT ?= convert
RMRF ?= rm -rf
MKDIR ?= mkdir
SASSC ?= sassc
PYTHON ?= python3

define INVOKE_PANDOC
$(PANDOC) \
	--standalone \
	--mathml \
	--table-of-contents \
	--toc-depth 4 \
	--metadata email=jv@jviotti.com \
	--from markdown \
	--to html5 \
	--template $< \
	--output $@
endef

define ARTICLE
ALL_ARTICLES += dist/out/$1/$2/$3/$4.html
dist/out/$1/$2/$3/$4.html: dist/templates/article.html articles/$1-$2-$3-$4.markdown \
	dist/out/style.min.css
	$(MKDIR) -p $$(dir $$@)
	$$(call INVOKE_PANDOC) $$(word 2,$$^) \
		--metadata base=../../.. \
		--metadata url=$1/$2/$3/$4.html
endef

define NOTE
ALL_NOTES += dist/out/notes/$1.html
endef

define PAGE
ALL_PAGES += dist/out/$1.html
endef

define IMAGE
ALL_IMAGES += dist/out/images/$1
endef

define STATIC
ALL_STATIC += dist/out/$1
endef

# Define which content to process here
include content.mk

ALL_STATIC += dist/out/style.min.css
ALL_STATIC += dist/out/icon.svg
ALL_STATIC += dist/out/favicon.ico
ALL_STATIC += dist/out/icon-192x192.png
ALL_STATIC += dist/out/icon-512x512.png
ALL_STATIC += dist/out/manifest.webmanifest
ALL_STATIC += dist/out/robots.txt

# Rules
dist:; $(MKDIR) $@
dist/out: | dist; $(MKDIR) $@
dist/templates: | dist; $(MKDIR) $@
dist/out/images: | dist/out; $(MKDIR) $@
dist/out/notes: | dist/out; $(MKDIR) $@
dist/out/notes/%.html: dist/templates/note.html notes/%.markdown \
	| dist/out/notes
	$(call INVOKE_PANDOC) $(word 2,$^) \
		--metadata base=.. \
		--metadata url=notes/$(basename $(notdir $@)).html
dist/out/%.html: dist/templates/page.html pages/%.markdown \
	| dist/out
	$(call INVOKE_PANDOC) $(word 2,$^) \
		--metadata base=. \
		--metadata url=$(basename $(notdir $@)).html
dist/out/index.html: dist/templates/index.html index.markdown \
	| dist/out
	$(call INVOKE_PANDOC) $(word 2,$^) --metadata base=.
dist/out/style.min.css: style.scss | dist/out
	$(SASSC) --style compressed $< $@
dist/templates/%.html: scripts/partials.sed templates/%.in.html \
	partials/navigation.html \
	partials/book.html \
	| dist/templates
	$(SED) -f $< $(word 2,$^) > $@
dist/out/icon-192x192.png: static/icon.svg | dist/out
	$(CONVERT) -background none -resize 192x192 $< $@
dist/out/icon-512x512.png: static/icon.svg | dist/out
	$(CONVERT) -background none -resize 512x512 $< $@
dist/out/favicon.ico: static/icon.svg | dist/out
	$(CONVERT) -background none -resize 32x32 $< $@
dist/out/%: static/% | dist/out
	$(INSTALL) -m 0664 $< $@
dist/out/images/%: images/% | dist/out/images
	$(INSTALL) -m 0664 $< $@
dist/out/feed.xml: scripts/rss.sh $(ALL_ARTICLES) | dist/out
	./$^ > $@

build: dist/out/feed.xml $(ALL_PAGES) $(ALL_ARTICLES) $(ALL_NOTES) $(ALL_IMAGES) $(ALL_STATIC)

.PHONY: all
all: build
.PHONY: serve
serve: build
	$(PYTHON) -m http.server $(PORT) --directory $(HERE)/dist/out
.PHONY: clean
clean:
	$(RMRF) dist
