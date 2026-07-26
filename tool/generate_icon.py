"""Generate the LyricChord app icon.

Draws a guitar chord diagram (fretboard + finger dots) with an eighth note on a
rounded violet gradient background, matching the app palette in
``lib/theme/app_colors.dart``.

This is a build-time developer tool only. It draws everything at 4x supersample
and downsamples with LANCZOS for crisp anti-aliased edges. It writes two files:

* ``assets/icon/app_icon.png``            - 1024 full-bleed master (launcher +
                                            iOS + legacy Android).
* ``assets/icon/app_icon_foreground.png`` - 1024 transparent foreground for the
                                            Android adaptive icon (art kept
                                            inside the centre safe zone).

Run:  python tool/generate_icon.py
"""

from __future__ import annotations

import math
import os

import numpy as np
from PIL import Image, ImageDraw

# --- Palette (from lib/theme/app_colors.dart) --------------------------------
GRAD_TOP = (124, 99, 199)   # brighter violet (top-left)
GRAD_BOT = (42, 18, 89)     # deep violet     (bottom-right)  ~ onSecondaryContainer
WHITE = (255, 255, 255)
INK = (247, 242, 255)       # very light violet-white for the art

SS = 4                       # supersample factor
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")


# --- Helpers -----------------------------------------------------------------
def diagonal_gradient(size: int) -> Image.Image:
    """Top-left -> bottom-right linear violet gradient with a soft top glow."""
    y, x = np.mgrid[0:size, 0:size].astype(np.float32)
    t = (x + y) / (2.0 * (size - 1))          # 0 at top-left, 1 at bottom-right
    t = t[..., None]
    top = np.array(GRAD_TOP, np.float32)
    bot = np.array(GRAD_BOT, np.float32)
    rgb = top * (1.0 - t) + bot * t

    # Soft circular highlight in the upper-left for a bit of depth.
    cx, cy = size * 0.30, size * 0.24
    d = np.sqrt((x - cx) ** 2 + (y - cy) ** 2) / (size * 0.75)
    glow = np.clip(1.0 - d, 0.0, 1.0)[..., None] ** 2 * 26.0
    rgb = np.clip(rgb + glow, 0, 255)
    return Image.fromarray(rgb.astype(np.uint8), "RGB")


def rounded_mask(size: int, radius_frac: float) -> Image.Image:
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    r = int(size * radius_frac)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=255)
    return m


def qbezier(p0, p1, p2, n=40):
    """Sample a quadratic bezier into ``n`` points."""
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt * mt * p0[0] + 2 * mt * t * p1[0] + t * t * p2[0]
        y = mt * mt * p0[1] + 2 * mt * t * p1[1] + t * t * p2[1]
        pts.append((x, y))
    return pts


def draw_line(d, a, b, width, fill):
    d.line([a, b], fill=fill, width=int(width))
    r = width / 2.0
    for p in (a, b):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


# --- The artwork -------------------------------------------------------------
def draw_art(base: Image.Image, cx: float, cy: float, U: float) -> None:
    """Draw the chord diagram + eighth note centred at (cx, cy), size ``U``."""
    d = ImageDraw.Draw(base)

    # ----- Chord diagram (fretboard) -----
    grid_cx = cx - 0.10 * U
    grid_cy = cy + 0.07 * U
    gw, gh = 0.46 * U, 0.52 * U
    gx0, gx1 = grid_cx - gw / 2, grid_cx + gw / 2
    gy0, gy1 = grid_cy - gh / 2, grid_cy + gh / 2

    n_strings = 4          # vertical lines
    n_gaps = 3             # fret gaps -> 4 horizontal lines (top = nut)
    lw = 0.020 * U
    nut_w = 0.044 * U

    col_x = [gx0 + (gx1 - gx0) * i / (n_strings - 1) for i in range(n_strings)]
    row_y = [gy0 + (gy1 - gy0) * i / n_gaps for i in range(n_gaps + 1)]

    # strings
    for x in col_x:
        draw_line(d, (x, gy0), (x, gy1), lw, INK)
    # frets (skip the top; the nut replaces it)
    for y in row_y[1:]:
        draw_line(d, (gx0, y), (gx1, y), lw, INK)
    # nut (thick top bar)
    d.rounded_rectangle(
        [gx0 - lw / 2, gy0 - nut_w / 2, gx1 + lw / 2, gy0 + nut_w / 2],
        radius=nut_w / 2, fill=INK,
    )

    # finger dots (filled) at chosen intersections
    def mid(i):
        return (row_y[i] + row_y[i + 1]) / 2

    dot_r = 0.050 * U
    dots = [
        (col_x[0], mid(0)),   # low string, first fret
        (col_x[2], mid(0)),   # high-mid string, first fret
        (col_x[1], mid(1)),   # mid string, second fret
    ]
    for (x, y) in dots:
        d.ellipse([x - dot_r, y - dot_r, x + dot_r, y + dot_r], fill=INK)

    # ----- Eighth note (top-right) -----
    head_cx = cx + 0.34 * U
    head_cy = cy - 0.10 * U
    head_rx, head_ry = 0.105 * U, 0.082 * U
    tilt = -22.0  # degrees

    stem_w = 0.032 * U
    stem_top_x = head_cx + head_rx * math.cos(math.radians(tilt)) + stem_w * 0.15
    stem_top_y = cy - 0.44 * U

    # stem: from top of the (right side of) head up
    stem_x = head_cx + head_rx * 0.86
    draw_line(d, (stem_x, head_cy - head_ry * 0.2),
              (stem_x, stem_top_y), stem_w, INK)

    # flag: a filled wing off the stem top
    flag_outer = qbezier(
        (stem_x, stem_top_y),
        (stem_x + 0.28 * U, stem_top_y + 0.06 * U),
        (stem_x + 0.16 * U, stem_top_y + 0.30 * U),
    )
    flag_inner = qbezier(
        (stem_x + 0.11 * U, stem_top_y + 0.24 * U),
        (stem_x + 0.16 * U, stem_top_y + 0.10 * U),
        (stem_x, stem_top_y + 0.12 * U),
    )
    d.polygon(flag_outer + flag_inner, fill=INK)

    # note head: draw on its own layer, rotate, paste
    pad = int(head_rx * 3)
    hl = Image.new("RGBA", (pad * 2, pad * 2), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hl)
    hd.ellipse([pad - head_rx, pad - head_ry, pad + head_rx, pad + head_ry],
               fill=INK + (255,))
    hl = hl.rotate(tilt, resample=Image.BICUBIC, center=(pad, pad))
    base.paste(hl, (int(head_cx - pad), int(head_cy - pad)), hl)


# --- Compose -----------------------------------------------------------------
def build_master(size: int) -> Image.Image:
    S = size * SS
    bg = diagonal_gradient(S).convert("RGBA")
    draw_art(bg, S * 0.470, S * 0.500, S * 0.62)
    # round the corners slightly for the master (OS masks further as needed)
    bg.putalpha(rounded_mask(S, 0.235))
    return bg.resize((size, size), Image.LANCZOS)


def build_foreground(size: int) -> Image.Image:
    S = size * SS
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    # Match the master art size. flutter_launcher_icons adds a further 16%
    # inset, which supplies the adaptive-icon safe-zone margin on top of this.
    draw_art(fg, S * 0.470, S * 0.500, S * 0.62)
    return fg.resize((size, size), Image.LANCZOS)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    master = build_master(1024)
    fg = build_foreground(1024)
    master_path = os.path.join(OUT_DIR, "app_icon.png")
    fg_path = os.path.join(OUT_DIR, "app_icon_foreground.png")
    master.save(master_path)
    fg.save(fg_path)
    print("wrote", os.path.normpath(master_path))
    print("wrote", os.path.normpath(fg_path))


if __name__ == "__main__":
    main()
