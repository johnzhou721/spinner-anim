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
	convert -resize 32x32 $(PDF) $(FRAME_FORMAT)
	touch $(STAMP)

$(STAMP2X): $(PDF) | $(FRAMES_DIR)
	# Remove old frames first
	rm -f $(FRAMES_DIR)/$(FRAME_PREFIX_2X)*.png
	convert -resize 64x64 $(PDF) $(FRAME_FORMAT_2X)
	touch $(STAMP2X)

# Build GIF after all frames are generated
$(GIF): $(STAMP)
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX)*.png" -vf palettegen=reserve_transparent=1 palette.png
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX)*.png" -i palette.png -lavfi "paletteuse" -gifflags -offsetting -loop 0 $(GIF)

$(GIF2X): $(STAMP2X)
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX_2X)*.png" -vf palettegen=reserve_transparent=1 palette2x.png
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX_2X)*.png" -i palette2x.png -lavfi "paletteuse" -gifflags -offsetting -loop 0 $(GIF2X)

# Clean up generated files
clean:
	rm -f *.aux *.log *.pdf $(GIF) $(GIF2X)
	rm -rf $(FRAMES_DIR)
	rm -f palette.png palette2x.png


.PHONY: all clean

