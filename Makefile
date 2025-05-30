TEX = spinner.tex
PDF = spinner.pdf
FRAMES_DIR = frames
FRAME_PREFIX = frame_
FRAME_FORMAT = $(FRAMES_DIR)/$(FRAME_PREFIX)%03d.png
GIF = output.gif
STAMP = $(FRAMES_DIR)/frames-stamp

all: $(GIF)

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
	convert -resize 256x256 $(PDF) $(FRAME_FORMAT)
	touch $(STAMP)

# Build GIF after all frames are generated
$(GIF): $(STAMP)
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX)*.png" -vf palettegen=reserve_transparent=1 palette.png
	ffmpeg -framerate 50 -pattern_type glob -i "$(FRAMES_DIR)/$(FRAME_PREFIX)*.png" -i palette.png -lavfi "paletteuse" -gifflags -offsetting -loop 0 $(GIF)

# Clean up generated files
clean:
	rm -f *.aux *.log *.pdf $(GIF)
	rm -rf $(FRAMES_DIR)
	rm -f palette.png

.PHONY: all clean

