#!/usr/bin/env python3
"""
从带浅灰/黑底的图标图中去掉背景，圆角外为透明；输出 1024×1024 PNG。

去背景后会对整图施加「超采样圆角矩形」alpha 蒙版，与常见 App 图标圆角一致，
可压平 flood-fill 在抗锯齿边缘留下的锯齿与杂边。

用法: python tool/process_app_icon.py [输入.png] [输出.png]
圆角比例: 修改 DEFAULT_CORNER_RADIUS_RATIO（默认约 iOS 常用 0.2237）。
"""

from __future__ import annotations

import sys
from collections import deque

from PIL import Image, ImageChops, ImageDraw


def color_distance(
    r1: int, g1: int, b1: int, r2: int, g2: int, b2: int
) -> int:
    return abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)


def flood_fill_background_transparent(
    img: Image.Image, thresh: int = 55
) -> Image.Image:
    """从四角种子 flood-fill，与角点平均色足够接近的像素变透明。"""
    w, h = img.size
    px = img.load()
    rgba = img.convert("RGBA")
    px = rgba.load()

    corners = [
        px[0, 0],
        px[w - 1, 0],
        px[0, h - 1],
        px[w - 1, h - 1],
    ]
    ar = sum(c[0] for c in corners) // 4
    ag = sum(c[1] for c in corners) // 4
    ab = sum(c[2] for c in corners) // 4

    def is_background(r: int, g: int, b: int, a: int) -> bool:
        if a < 30:
            return True
        return color_distance(r, g, b, ar, ag, ab) <= thresh * 3

    seen: set[tuple[int, int]] = set()
    q: deque[tuple[int, int]] = deque()
    for sx, sy in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        q.append((sx, sy))

    while q:
        x, y = q.popleft()
        if x < 0 or x >= w or y < 0 or y >= h:
            continue
        if (x, y) in seen:
            continue
        seen.add((x, y))
        r, g, b, a = px[x, y]
        if not is_background(r, g, b, a):
            continue
        px[x, y] = (r, g, b, 0)
        for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen:
                q.append((nx, ny))

    return rgba


def bbox_nontransparent(img: Image.Image) -> tuple[int, int, int, int]:
    w, h = img.size
    px = img.load()
    min_x, min_y = w, h
    max_x, max_y = 0, 0
    for y in range(h):
        for x in range(w):
            if px[x, y][3] > 20:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x < min_x:
        return 0, 0, w - 1, h - 1
    return min_x, min_y, max_x, max_y


def pad_to_square(img: Image.Image) -> Image.Image:
    w, h = img.size
    side = max(w, h)
    out = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    ox = (side - w) // 2
    oy = (side - h) // 2
    out.paste(img, (ox, oy), img)
    return out


# 与常见 App 图标模板接近的圆角比例（可略调以贴合原图）
DEFAULT_CORNER_RADIUS_RATIO = 0.2237


def smooth_rounded_rect_mask(
    side: int,
    corner_radius_ratio: float = DEFAULT_CORNER_RADIUS_RATIO,
    supersample: int = 4,
) -> Image.Image:
    """在更高分辨率绘制圆角矩形再缩小，边缘抗锯齿，避免锯齿与台阶感。"""
    ss = max(1, side * supersample)
    r = max(1, int(round(side * corner_radius_ratio * supersample)))
    half = ss // 2
    if r > half:
        r = half
    mask = Image.new("L", (ss, ss), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, ss - 1, ss - 1), radius=r, fill=255)
    return mask.resize((side, side), Image.Resampling.LANCZOS)


def apply_smooth_rounded_clip(
    img: Image.Image,
    corner_radius_ratio: float = DEFAULT_CORNER_RADIUS_RATIO,
) -> Image.Image:
    """用平滑圆角矩形与 alpha 相乘，压平 flood-fill 在抗锯齿边上的杂色与锯齿。"""
    w, h = img.size
    if w != h:
        raise ValueError("apply_smooth_rounded_clip 需要正方形图")
    mask = smooth_rounded_rect_mask(w, corner_radius_ratio=corner_radius_ratio)
    r, g, b, a = img.split()
    new_a = ImageChops.multiply(a, mask)
    return Image.merge("RGBA", (r, g, b, new_a))


def main() -> None:
    src = (
        sys.argv[1]
        if len(sys.argv) > 1
        else r"C:\Users\mx\.cursor\projects\d-Users-mx-Desktop-aihome-work\assets\c__Users_mx_AppData_Roaming_Cursor_User_workspaceStorage_bfddc2bd9b1e172464b0e86579cae317_images_image-15233ec1-cabe-4acc-8f07-af1eb0b4e53c.png"
    )
    dst = (
        sys.argv[2]
        if len(sys.argv) > 2
        else r"d:\Users\mx\Desktop\aihome-work\family_smart_center\assets\app_icon\app_icon_source.png"
    )

    im = Image.open(src).convert("RGBA")
    im = flood_fill_background_transparent(im, thresh=50)
    x0, y0, x1, y1 = bbox_nontransparent(im)
    cropped = im.crop((x0, y0, x1 + 1, y1 + 1))
    squared = pad_to_square(cropped)
    out = squared.resize((1024, 1024), Image.Resampling.LANCZOS)
    out = apply_smooth_rounded_clip(out)
    out.save(dst, "PNG")
    print(f"OK -> {dst} ({out.size})")


if __name__ == "__main__":
    main()
