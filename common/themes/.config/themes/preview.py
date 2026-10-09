"""Render palette previews: python preview.py [flavor ...]  (default: all)."""
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

palettes = Path(__file__).resolve().parent / "palettes"
flavors = sys.argv[1:] or [p.stem for p in palettes.glob("*.json")]

swatch_w, row_h, padding, width = 120, 40, 10, 500
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 16)
except IOError:
    font = ImageFont.load_default()

for flavor in flavors:
    colors = json.loads((palettes / f"{flavor}.json").read_text())
    img = Image.new("RGB", (width, row_h * len(colors) + 2 * padding), "#000000")
    draw = ImageDraw.Draw(img)
    y = padding
    for name, hexcol in colors.items():
        draw.rectangle([padding, y, padding + swatch_w, y + row_h - 10], fill=hexcol)
        draw.text((padding + swatch_w + 15, y + 8), f"{name}  {hexcol}", fill="#ffffff", font=font)
        y += row_h
    img.save(palettes / f"{flavor}.png")
