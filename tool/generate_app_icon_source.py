#!/usr/bin/env python3
"""
生成与 AppTheme 主页风格一致的 1024×1024 app_icon_source.png。

配色对齐 lib/core/theme/app_theme.dart：
  shellBackground #1A1A2E、primary #7C9EFF、secondary #80D8FF、onSurface #E8E8E8

用法:
  python tool/generate_app_icon_source.py [输出路径，默认 assets/app_icon/app_icon_source.png]
"""

from __future__ import annotations

import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

# --- 与 AppTheme.dark() / ColorScheme 一致 ---
SHELL = (0x1A, 0x1A, 0x2E)
PRIMARY = (0x7C, 0x9E, 0xFF)
SECONDARY = (0x80, 0xD8, 0xFF)
ON_SURFACE = (0xE8, 0xE8, 0xE8)

SIDE = 1024
CORNER_RATIO = 0.2237


def _lerp_rgb(
    a: tuple[int, int, int], b: tuple[int, int, int], t: float
) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def _diagonal_gradient(w: int, h: int) -> Image.Image:
    """左上偏 primary 光感、右下压暗，贴近主页深色底 + 强调色。"""
    tl = _lerp_rgb(SHELL, PRIMARY, 0.38)
    br = _lerp_rgb(SHELL, (0x10, 0x12, 0x22), 0.55)
    im = Image.new("RGB", (w, h))
    px = im.load()
    wm, hm = max(w - 1, 1), max(h - 1, 1)
    for y in range(h):
        for x in range(w):
            t = ((x / wm) + (y / hm)) * 0.5
            px[x, y] = _lerp_rgb(tl, br, t)
    return im


def _glass_highlight(w: int, h: int) -> Image.Image:
    """顶部轻微高光，与卡片/玻璃质感协调。"""
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(layer)
    dr.ellipse(
        (-w * 0.15, -h * 0.35, w * 1.15, h * 0.45),
        fill=(255, 255, 255, 38),
    )
    return layer.filter(ImageFilter.GaussianBlur(radius=28))


def _smooth_rounded_mask(side: int, supersample: int = 4) -> Image.Image:
    ss = max(1, side * supersample)
    r = max(1, int(round(side * CORNER_RATIO * supersample)))
    r = min(r, ss // 2)
    mask = Image.new("L", (ss, ss), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, ss - 1, ss - 1), radius=r, fill=255)
    return mask.resize((side, side), Image.Resampling.LANCZOS)


def _draw_home_glyph(base: Image.Image) -> None:
    """简约「家」轮廓 + 顶部 secondary 光点，小尺寸仍可辨。"""
    d = ImageDraw.Draw(base)
    cx, cy = SIDE // 2, int(SIDE * 0.52)
    s = SIDE * 0.22
    stroke = max(14, int(SIDE * 0.022))

    peak = (cx, int(cy - s * 0.95))
    left = (int(cx - s * 0.92), int(cy - s * 0.12))
    right = (int(cx + s * 0.92), int(cy - s * 0.12))
    bot_l = (int(cx - s * 0.72), int(cy + s * 0.88))
    bot_r = (int(cx + s * 0.72), int(cy + s * 0.88))

    # 外轮廓：屋顶三角 + 房体（五边形一笔闭合）
    shell_pts = [peak, left, bot_l, bot_r, right]
    d.polygon(
        shell_pts,
        outline=(*ON_SURFACE, 255),
        width=stroke,
    )

    # 门（深色凹入感，与主页卡片对比一致）
    door_half = int(s * 0.16)
    door_top = int(cy + s * 0.12)
    door_bot = bot_l[1]
    d.rounded_rectangle(
        (
            cx - door_half,
            door_top,
            cx + door_half,
            door_bot,
        ),
        radius=max(6, stroke // 2),
        outline=(*_lerp_rgb(SHELL, PRIMARY, 0.45), 230),
        width=max(8, stroke - 5),
    )

    # secondary：智能/连接暗示
    dot_y = int(cy - s * 1.22)
    r0 = int(SIDE * 0.03)
    d.ellipse(
        (cx - r0, dot_y - r0, cx + r0, dot_y + r0),
        fill=(*SECONDARY, 255),
        outline=(*_lerp_rgb(SECONDARY, (255, 255, 255), 0.4), 180),
        width=3,
    )


def generate() -> Image.Image:
    rgb = _diagonal_gradient(SIDE, SIDE)
    rgba = rgb.convert("RGBA")
    hi = _glass_highlight(SIDE, SIDE)
    rgba = Image.alpha_composite(rgba, hi)
    _draw_home_glyph(rgba)

    mask = _smooth_rounded_mask(SIDE)
    r, g, b, a = rgba.split()
    a = ImageChops.multiply(a, mask)
    return Image.merge("RGBA", (r, g, b, a))


def main() -> None:
    out = (
        sys.argv[1]
        if len(sys.argv) > 1
        else r"assets/app_icon/app_icon_source.png"
    )
    img = generate()
    img.save(out, "PNG")
    print(f"OK -> {out} ({img.size})")


if __name__ == "__main__":
    main()
