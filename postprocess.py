from PIL import Image, ImageSequence, ImageFilter

def smooth(image, scale=2):
    # Step 1: Scale down by 50%
    width, height = image.size
    image_small = image.resize((width // scale, height // scale), resample=Image.BICUBIC)

    # Step 2: Scale up by 200%
    return image_small.resize((width, height), resample=Image.LANCZOS)

def process_gif(input_path, output_path, rgb_background):
    src = Image.open(input_path)
    size = src.size

    # This will hold the fully reconstructed frames
    full_frames = []

    # Create a "previous frame" canvas
    prev = Image.new("RGBA", size, (0, 0, 0, 0))

    # 1) Reconstruct full frames
    for frame in ImageSequence.Iterator(src):
        frame_rgba = frame.convert("RGBA")

        # if this frame has a box, paste it onto prev; otherwise it's a full-frame update
        if frame.tile:
            update_region = frame.tile[0][1]  # (x0,y0,x1,y1)
            prev.paste(frame_rgba.crop(update_region), update_region)
        else:
            prev = frame_rgba

        # Make a copy of the fully built frame
        full_frames.append(prev.copy())

    # Now process each full frame
    processed = []
    for frame in full_frames:
        # 2) Composite on your RGB background
        bg = Image.new("RGBA", size, rgb_background + (255,))
        comp = Image.alpha_composite(bg, frame)

        sm = smooth(comp)
        sm = sm.filter(ImageFilter.GaussianBlur(radius=0.5))


        # 4) Quantize back to P mode with adaptive palette
        pal = sm.convert("P", palette=Image.ADAPTIVE, colors=255)
        
        # Reserve palette index 255 for transparency
        # Find which palette entry in `pal` corresponds to the fully transparent pixels
        transparent_mask = sm.split()[3].point(lambda a: 255 if a == 0 else 0)
        pal.paste(255, mask=transparent_mask)

        processed.append(pal)

    # Finally, save as a new GIF
    processed[0].save(
        output_path,
        save_all=True,
        append_images=processed[1:],
        loop=src.info.get("loop", 0),
        duration=src.info.get("duration", 100),
        transparency=255,
        disposal=2,
    )

# Usage
# 240 240 240
rgb_background = (255, 0, 255)
process_gif("output.gif", "output_anti.gif", rgb_background)
