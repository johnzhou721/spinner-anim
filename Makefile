# Makefile to compile spinner.tex, convert pages to PNGs, and build a GIF

TEX = spinner.tex
PDF = spinner.pdf
FRAMES_DIR = frames
FRAME_PREFIX = frame_
FRAME_FORMAT = $(FRAMES_DIR)/$(FRAME_PREFIX)%03d.png
GIF = output.gif
DPI = 150
STAMP = $(FRAMES_DIR)/frames-stamp

# Default target
all: $(GIF)

# Compile LaTeX source to PDF
$(PDF): $(TEX)
	pdflatex -interaction=nonstopmode $<

# Ensure frames directory exists
$(FRAMES_DIR):
	mkdir -p $(FRAMES_DIR)

# Convert PDF pages to PNGs, then touch a stamp file for tracking
# Convert PDF pages to PNGs, then touch a stamp file for tracking
$(STAMP): $(PDF) | $(FRAMES_DIR)
	# Remove old frames first
	rm -f $(FRAMES_DIR)/$(FRAME_PREFIX)*.png
	convert -density $(DPI) $(PDF) -background white -alpha remove -alpha off $(FRAME_FORMAT)
	touch $(STAMP)

# Build GIF after all frames are generated
$(GIF): $(STAMP)
	convert -delay 2 -loop 0 $(FRAMES_DIR)/$(FRAME_PREFIX)*.png $(GIF)

# Clean up generated files
clean:
	rm -f *.aux *.log *.pdf $(GIF)
	rm -rf $(FRAMES_DIR)

.PHONY: all clean

