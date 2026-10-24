# Draws the addon icon (needs Pillow): python tools/make_icon.py art
import sys
from PIL import Image, ImageDraw, ImageFilter
SS = 4                      # supersample
N = 256 * SS
def P(v): return int(v * SS)

img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# background: dark plum rounded square
d.rounded_rectangle([P(4), P(4), P(252), P(252)], radius=P(44), fill=(30, 18, 40, 255))
d.rounded_rectangle([P(4), P(4), P(252), P(252)], radius=P(44), outline=(255, 255, 255, 255), width=P(3))

# pumpkin: overlapping vertical lobes, darker at the sides, lighter in the middle
cx, cy = 124, 128
lobes = [(-76, 40, 78, (196, 84, 10)), (76, 40, 78, (196, 84, 10)),
         (-42, 58, 84, (226, 108, 16)), (42, 58, 84, (226, 108, 16)),
         (0, 62, 88, (255, 140, 26))]
for dx, rx, ry, col in lobes:
    d.ellipse([P(cx + dx - rx), P(cy - ry), P(cx + dx + rx), P(cy + ry)], fill=col + (255,))
    d.ellipse([P(cx + dx - rx), P(cy - ry), P(cx + dx + rx), P(cy + ry)], outline=(150, 58, 6, 255), width=P(2))
# stem
d.polygon([(P(116), P(cy - 84)), (P(134), P(cy - 84)), (P(142), P(cy - 108)), (P(124), P(cy - 114))], fill=(92, 112, 36, 255), outline=(52, 70, 18, 255))

# jack-o-lantern face (dark)
face = (40, 16, 6, 255)
d.polygon([(P(70), P(108)), (P(104), P(108)), (P(87), P(76))], fill=face)
d.polygon([(P(124), P(108)), (P(158), P(108)), (P(141), P(76))], fill=face)
d.polygon([(P(106), P(130)), (P(122), P(130)), (P(114), P(144))], fill=face)
d.polygon([(P(64), P(158)), (P(170), P(158)), (P(158), P(184)), (P(142), P(170)), (P(117), P(188)), (P(92), P(170)), (P(76), P(184))], fill=face)

# "no entry" sign: red disc, white rim, white bar
sx, sy, r = 160, 168, 52
d.ellipse([P(sx - r - 6), P(sy - r - 6), P(sx + r + 6), P(sy + r + 6)], fill=(255, 255, 255, 255))
d.ellipse([P(sx - r), P(sy - r), P(sx + r), P(sy + r)], fill=(214, 24, 24, 255))
d.rounded_rectangle([P(sx - 36), P(sy - 9), P(sx + 36), P(sy + 9)], radius=P(3), fill=(255, 255, 255, 255))

img = img.resize((256, 256), Image.LANCZOS)
out = sys.argv[1]
img.save(out + "/icon-256.png")
img.resize((128, 128), Image.LANCZOS).save(out + "/icon-128.png")
img.resize((64, 64), Image.LANCZOS).save(out + "/icon-64.png")
img.resize((128, 128), Image.LANCZOS).save(out + "/icon-128.tga")   # WoW IconTexture: power-of-two, 32-bit
print("ok")
