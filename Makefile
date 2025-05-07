# Makefile to compile spinner.tex, convert pages to PNGs, and build a GIF

TEX = spinner.tex
PDF = spinner.pdf
FRAMES_DIR = frames
FRAME_PREFIX = frame_
FRAME_PREFIX_2X = frame2X_
FRAME_FORMAT = $(FRAMES_DIR)/$(FRAME_PREFIX)%03d.png
FRAME_FORMAT_2X = $(FRAMES_DIR)/$(FRAME_PREFIX_2X)%03d.png
GIF = output.gif
GIF2X = output2x.gif
STAMP = $(FRAMES_DIR)/frames-stamp
STAMP2X = $(FRAMES_DIR)/frames-stamp_2x


# Default target
all: $(GIF) $(GIF2X)

# Compile LaTeX source to PDF
$(PDF): $(TEX)
	pdflatex -interaction=nonstopmode $<

# Ensure frames directory exists
$(FRAMES_DIR):
	mkdir -p $(FRAMES_DIR)

# Convert PDF pages to PNGs, then touch a stamp file for tracking
$(STAMP): $(PDF) | $(FRAMES_DIR)
	# Remove old frames first
	rm -f $(FRAMES_DIR)/$(FRAME_PREFIX)*.png
	convert -resize 32x32 $(PDF) -background white -alpha remove -alpha off $(FRAME_FORMAT)
	touch $(STAMP)

$(STAMP2X): $(PDF) | $(FRAMES_DIR)
	# Remove old frames first
	rm -f $(FRAMES_DIR)/$(FRAME_PREFIX_2X)*.png
	convert -resize 64x64 $(PDF) -background white -alpha remove -alpha off $(FRAME_FORMAT_2X)
	touch $(STAMP2X)

# Build GIF after all frames are generated
$(GIF): $(STAMP)
	convert -delay 2 -loop 0 $(FRAMES_DIR)/$(FRAME_PREFIX)*.png $(GIF)

$(GIF2X): $(STAMP2X)
	convert -delay 2 -loop 0 $(FRAMES_DIR)/$(FRAME_PREFIX_2X)*.png $(GIF2X)

# Clean up generated files
clean:
	rm -f *.aux *.log *.pdf $(GIF) $(GIF2X)
	rm -rf $(FRAMES_DIR)

.PHONY: all clean

