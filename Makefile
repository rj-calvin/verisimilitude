CONTEXT ?= context
CONTEXTFLAGS ?=
PDFVIEWER ?= zathura
OUTDIR ?= out
products = $(patsubst %.tex,%.pdf,$(wildcard *.tex))
components = $(patsubst %.tex,%.pdf,$(wildcard src/*.tex))

all: $(products)

.PHONY: clean outdir

outdir:
	if [ ! -d $(OUTDIR) ]; then mkdir $(OUTDIR); fi

clean:
	rm -rf $(OUTDIR)

products: $(products)

$(products): %.pdf: %.tex outdir
	cd $(OUTDIR); \
	$(CONTEXT) \
		$(CONTEXTFLAGS) \
		--path=$(PWD)/src,$(PWD)/cls \
		--batchmode \
		$(addprefix $(PWD)/,$<)

view: $(products)
	$(PDFVIEWER) $(addprefix $(PWD)/$(OUTDIR)/,$<) &

watch: view
	cd $(OUTDIR); \
	while inotifywait \
			--event modify \
			--recursive \
			--include '.tex|.mkiv' $(PWD); do \
		$(CONTEXT) \
			$(CONTEXTFLAGS) \
			--path=$(PWD)/src,$(PWD)/cls \
			--batchmode \
			$(addprefix $(PWD)/,$(wildcard *.tex)); \
	done; \
	true
