"""Normalize app icon assets for launcher + splash (exact #1A1A2E background)."""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

APP_ICON_DIR = Path(__file__).resolve().parent.parent / "assets" / "app_icon"
SOURCE = APP_ICON_DIR / "app_icon_source.png"
LAUNCHER = APP_ICON_DIR / "app_icon_source.png"
SPLASH_FG = APP_ICON_DIR / "app_icon_splash_foreground.png"

TARGET_SIZE = 1024
BG = (0x1A, 0x1A, 0x2E)  # #1A1A2E
BG_TOLERANCE = 42


def _center_square(img: Image.Image) -> Image.Image:
    w, h = img.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    return img.crop((left, top, left + side, top + side))


def _is_background(r: int, g: int, b: int) -> bool:
    # Dark navy / near-black pixels from AI export or subtle vignette.
    if max(r, g, b) < 72 and b >= r - 8:
        return True
    dr, dg, db = abs(r - BG[0]), abs(g - BG[1]), abs(b - BG[2])
    return dr + dg + db <= BG_TOLERANCE


def _resize(img: Image.Image) -> Image.Image:
    if img.size == (TARGET_SIZE, TARGET_SIZE):
        return img
    return img.resize((TARGET_SIZE, TARGET_SIZE), Image.Resampling.LANCZOS)


def build_launcher_icon(img: Image.Image) -> Image.Image:
    out = Image.new("RGB", (TARGET_SIZE, TARGET_SIZE), BG)
    rgb = img.convert("RGB")
    px = rgb.load()
    out_px = out.load()
    for y in range(TARGET_SIZE):
        for x in range(TARGET_SIZE):
            r, g, b = px[x, y]
            if _is_background(r, g, b):
                out_px[x, y] = BG
            else:
                out_px[x, y] = (r, g, b)
    return out


def build_splash_foreground(img: Image.Image) -> Image.Image:
    out = Image.new("RGBA", (TARGET_SIZE, TARGET_SIZE), (0, 0, 0, 0))
    rgb = img.convert("RGB")
    px = rgb.load()
    out_px = out.load()
    for y in range(TARGET_SIZE):
        for x in range(TARGET_SIZE):
            r, g, b = px[x, y]
            if _is_background(r, g, b):
                continue
            out_px[x, y] = (r, g, b, 255)
    return out


def main() -> int:
    if not SOURCE.exists():
        print(f"ERROR: missing {SOURCE}", file=sys.stderr)
        return 1

    raw = Image.open(SOURCE)
    square = _center_square(raw)
    square = _resize(square)

    launcher = build_launcher_icon(square)
    splash_fg = build_splash_foreground(square)

    launcher.save(LAUNCHER, format="PNG", optimize=True)
    splash_fg.save(SPLASH_FG, format="PNG", optimize=True)

    print(f"Wrote launcher: {LAUNCHER} ({launcher.size})")
    print(f"Wrote splash fg: {SPLASH_FG} ({splash_fg.size})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
