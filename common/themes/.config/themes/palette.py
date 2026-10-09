from PIL import Image, ImageDraw, ImageFont
import re

css_file = "latte.css"

# Read colors from file
colors = []
with open(css_file, "r") as f:
    for line in f:
        match = re.match(r"@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6});", line)
        if match:
            colors.append((match.group(1), match.group(2)))

# Layout parameters
swatch_w = 120
row_h = 40
padding = 10
width = 500
height = row_h * len(colors) + 2 * padding

# Create image
img = Image.new("RGB", (width, height), "#000000")
draw = ImageDraw.Draw(img)

# Font
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 16)
except IOError:
    font = ImageFont.load_default()

y = padding
for name, hexcol in colors:
    # Draw swatch
    draw.rectangle(
        [padding, y, padding + swatch_w, y + row_h - 10],
        fill=hexcol
    )
    # Draw text
    draw.text(
        (padding + swatch_w + 15, y + 8),
        f"{name}  {hexcol}",
        fill="#ffffff",
        font=font
    )
    y += row_h

img.save(css_file.replace(".css", ".png"))
