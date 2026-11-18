import os
import math
import random
from PIL import Image, ImageDraw, ImageFilter

def create_clover_forest_background(w=1170, h=2532):
    print("Generating Clover Forest Portrait Background (1170x2532)...")
    base = Image.new("RGBA", (w, h))

    # 1. Base vertical gradient (Dark teal top -> Open teal mid -> Emerald lower -> Bright green bottom)
    gradient_img = Image.new("RGBA", (w, h))
    draw_g = ImageDraw.Draw(gradient_img)

    stops = [
        (0.00, (8, 28, 34)),
        (0.15, (12, 42, 44)),
        (0.35, (18, 68, 60)),
        (0.55, (24, 90, 75)),
        (0.72, (38, 125, 88)),
        (0.85, (56, 160, 100)),
        (1.00, (76, 192, 108)),
    ]

    for y in range(h):
        t = y / (h - 1)
        # Find interval
        for i in range(len(stops) - 1):
            t1, c1 = stops[i]
            t2, c2 = stops[i+1]
            if t1 <= t <= t2:
                factor = (t - t1) / (t2 - t1)
                r = int(c1[0] * (1 - factor) + c2[0] * factor)
                g = int(c1[1] * (1 - factor) + c2[1] * factor)
                b = int(c1[2] * (1 - factor) + c2[2] * factor)
                draw_g.line([(0, y), (w, y)], fill=(r, g, b, 255))
                break

    base.paste(gradient_img, (0, 0))

    # 2. Central Soft Ambient Teal Glow
    glow_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    glow_draw.ellipse([w*0.1, h*0.25, w*0.9, h*0.65], fill=(35, 145, 120, 70))
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(120))
    base = Image.alpha_composite(base, glow_img)

    # 3. Top Forest Canopy & Silhouettes (y=0 to 750)
    top_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    tdraw = ImageDraw.Draw(top_layer)

    # Distant back canopy silhouette (#072124)
    back_canopy_color = (7, 33, 36, 240)
    for cx, cy, rx, ry in [
        (150, 120, 220, 180), (380, 80, 260, 200), (620, 140, 240, 190),
        (880, 90, 270, 210), (1080, 150, 220, 180), (50, 250, 180, 140),
        (300, 280, 230, 160), (750, 260, 250, 170), (1020, 290, 200, 150),
    ]:
        tdraw.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=back_canopy_color)

    # Mid canopy silhouette (#0e3834)
    mid_canopy_color = (14, 56, 52, 255)
    for cx, cy, rx, ry in [
        (0, 50, 280, 220), (250, 40, 220, 180), (550, 30, 290, 210),
        (850, 50, 250, 190), (1170, 40, 260, 220), (-30, 200, 220, 160),
        (200, 180, 190, 140), (450, 210, 240, 160), (700, 190, 220, 150),
        (950, 220, 230, 160), (1200, 190, 200, 140),
    ]:
        tdraw.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=mid_canopy_color)

    # Foreground canopy drooping foliage (#154a43)
    fore_canopy_color = (21, 74, 67, 255)
    for cx, cy, rx, ry in [
        (0, 0, 320, 250), (1170, 0, 320, 250), (150, 100, 180, 150),
        (1020, 100, 180, 150), (400, 80, 160, 110), (770, 80, 160, 110)
    ]:
        tdraw.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=fore_canopy_color)

    base = Image.alpha_composite(base, top_layer)

    # 4. Side Foliage & Large Leaves (Left & Right)
    side_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(side_layer)

    def draw_clover_leaf(draw, cx, cy, radius, rotation_deg, fill_color, vein_color):
        # 3 or 4 rounded heart-like lobes
        rad = math.radians(rotation_deg)
        for angle in [0, 90, 180, 270]:
            a = math.radians(angle) + rad
            lx = cx + math.cos(a) * (radius * 0.55)
            ly = cy + math.sin(a) * (radius * 0.55)
            draw.ellipse([lx-radius*0.55, ly-radius*0.55, lx+radius*0.55, ly+radius*0.55], fill=fill_color)
        draw.ellipse([cx-radius*0.35, cy-radius*0.35, cx+radius*0.35, cy+radius*0.35], fill=fill_color)
        # Stem
        sx2 = cx + math.cos(rad + math.pi/2) * (radius * 1.2)
        sy2 = cy + math.sin(rad + math.pi/2) * (radius * 1.2)
        draw.line([(cx, cy), (sx2, sy2)], fill=vein_color, width=max(2, int(radius * 0.08)))

    def draw_broad_leaf(draw, p1, p2, width, fill_color, highlight_color):
        # Oval leaf along segment p1->p2
        dx = p2[0] - p1[0]
        dy = p2[1] - p1[1]
        length = math.hypot(dx, dy)
        if length == 0: return
        angle = math.atan2(dy, dx)
        mid_x = (p1[0] + p2[0]) / 2
        mid_y = (p1[1] + p2[1]) / 2

        leaf_img = Image.new("RGBA", (int(length + width*2), int(width*2)), (0, 0, 0, 0))
        ldraw = ImageDraw.Draw(leaf_img)
        lcx, lcy = (length + width*2)/2, width
        ldraw.ellipse([lcx - length/2, lcy - width/2, lcx + length/2, lcy + width/2], fill=fill_color)
        ldraw.line([(lcx - length/2 + 10, lcy), (lcx + length/2 - 10, lcy)], fill=highlight_color, width=max(2, int(width*0.08)))

        rotated = leaf_img.rotate(-math.degrees(angle), resample=Image.BICUBIC, expand=True)
        rcx, rcy = rotated.width / 2, rotated.height / 2
        side_layer.paste(rotated, (int(mid_x - rcx), int(mid_y - rcy)), rotated)

    # Left side foliage clusters (x=0 to 340, y=250 to 1900)
    left_dark = (16, 62, 45, 255)
    left_mid = (30, 108, 68, 255)
    left_bright = (52, 160, 92, 255)
    left_high = (110, 225, 140, 255)

    # Left background bush masses
    for cy in range(350, 1850, 180):
        sdraw.ellipse([-120, cy-120, 220, cy+120], fill=left_dark)
        sdraw.ellipse([-80, cy-80, 180, cy+80], fill=left_mid)

    # Large illustrated leaves on left
    leaf_configs_left = [
        ((0, 320), (220, 420), 160),
        ((-20, 520), (240, 600), 170),
        ((0, 750), (230, 840), 150),
        ((-30, 980), (220, 1050), 160),
        ((0, 1220), (250, 1310), 170),
        ((-20, 1450), (220, 1520), 150),
        ((0, 1680), (240, 1740), 160),
    ]
    for p1, p2, wth in leaf_configs_left:
        draw_broad_leaf(sdraw, p1, p2, wth, left_bright, left_high)

    # Left clover accents
    for cl_x, cl_y, cl_r in [
        (180, 350, 45), (200, 650, 50), (190, 920, 48), (210, 1250, 52), (180, 1550, 45)
    ]:
        draw_clover_leaf(sdraw, cl_x, cl_y, cl_r, 15, left_bright, left_high)

    # Right side foliage clusters (x=830 to 1170, y=250 to 1900)
    for cy in range(350, 1850, 180):
        sdraw.ellipse([w-220, cy-120, w+120, cy+120], fill=left_dark)
        sdraw.ellipse([w-180, cy-80, w+80, cy+80], fill=left_mid)

    leaf_configs_right = [
        ((w, 350), (w-210, 440), 150),
        ((w+20, 580), (w-230, 660), 160),
        ((w, 810), (w-220, 890), 150),
        ((w+30, 1040), (w-240, 1120), 170),
        ((w, 1280), (w-220, 1360), 150),
        ((w+20, 1510), (w-230, 1580), 160),
        ((w, 1720), (w-210, 1780), 140),
    ]
    for p1, p2, wth in leaf_configs_right:
        draw_broad_leaf(sdraw, p1, p2, wth, left_bright, left_high)

    for cl_x, cl_y, cl_r in [
        (w-170, 420, 44), (w-190, 720, 48), (w-180, 1010, 50), (w-200, 1340, 46), (w-170, 1620, 45)
    ]:
        draw_clover_leaf(sdraw, cl_x, cl_y, cl_r, -20, left_bright, left_high)

    base = Image.alpha_composite(base, side_layer)

    # 5. Bottom Grassy Clearing & Rolling Hills (y=1750 to 2532)
    bottom_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(bottom_layer)

    # Back Hill (#227a44)
    back_hill_pts = [(0, 1950), (w*0.3, 1910), (w*0.7, 1940), (w, 1890), (w, 2532), (0, 2532)]
    bdraw.polygon(back_hill_pts, fill=(34, 122, 68, 255))

    # Mid Hill (#2ea055)
    mid_hill_pts = [(0, 2050), (w*0.25, 2010), (w*0.65, 2030), (w, 1980), (w, 2532), (0, 2532)]
    bdraw.polygon(mid_hill_pts, fill=(46, 160, 85, 255))

    # Foreground Rolling Clearing (#44be6b to #5fd180)
    fore_hill_pts = [(0, 2160), (w*0.2, 2120), (w*0.5, 2140), (w*0.8, 2110), (w, 2140), (w, 2532), (0, 2532)]
    bdraw.polygon(fore_hill_pts, fill=(68, 190, 107, 255))

    # Rolling Hill Highlights (#82e89d)
    bdraw.line([(0, 2160), (w*0.2, 2120), (w*0.5, 2140), (w*0.8, 2110), (w, 2140)], fill=(130, 232, 157, 255), width=8)

    # Foreground corner bushes and clover plants at bottom edges (not blocking cannon center)
    for bx, by, br in [
        (60, 2200, 110), (160, 2260, 90), (0, 2320, 140), (100, 2400, 120),
        (w-60, 2200, 110), (w-160, 2260, 90), (w, 2320, 140), (w-100, 2400, 120)
    ]:
        bdraw.ellipse([bx-br, by-br, bx+br, by+br], fill=(42, 150, 80, 255))
        bdraw.ellipse([bx-br*0.7, by-br*0.7, bx+br*0.7, by+br*0.7], fill=(68, 190, 107, 255))

    # Flower details in bottom corners
    for fx, fy, fcol in [
        (90, 2250, (255, 90, 140, 255)), (180, 2340, (255, 220, 60, 255)),
        (w-90, 2250, (255, 90, 140, 255)), (w-180, 2340, (255, 220, 60, 255))
    ]:
        for a in range(0, 360, 72):
            rad = math.radians(a)
            bdraw.ellipse([fx+math.cos(rad)*14-8, fy+math.sin(rad)*14-8, fx+math.cos(rad)*14+8, fy+math.sin(rad)*14+8], fill=fcol)
        bdraw.ellipse([fx-6, fy-6, fx+6, fy+6], fill=(255, 255, 255, 255))

    base = Image.alpha_composite(base, bottom_layer)

    return base


def create_underwater_background(w=1170, h=2532):
    print("Generating Underwater Portrait Background (1170x2532)...")
    base = Image.new("RGBA", (w, h))

    # 1. Base vertical gradient (Bright turquoise top -> Ocean cyan mid -> Deep blue seabed)
    gradient_img = Image.new("RGBA", (w, h))
    draw_g = ImageDraw.Draw(gradient_img)

    stops = [
        (0.00, (22, 192, 218)),
        (0.18, (18, 162, 195)),
        (0.40, (14, 128, 168)),
        (0.65, (10, 92, 138)),
        (0.85, (6, 58, 98)),
        (1.00, (3, 36, 68)),
    ]

    for y in range(h):
        t = y / (h - 1)
        for i in range(len(stops) - 1):
            t1, c1 = stops[i]
            t2, c2 = stops[i+1]
            if t1 <= t <= t2:
                factor = (t - t1) / (t2 - t1)
                r = int(c1[0] * (1 - factor) + c2[0] * factor)
                g = int(c1[1] * (1 - factor) + c2[1] * factor)
                b = int(c1[2] * (1 - factor) + c2[2] * factor)
                draw_g.line([(0, y), (w, y)], fill=(r, g, b, 255))
                break

    base.paste(gradient_img, (0, 0))

    # 2. Water Surface Caustics & Sunbeams (Top Region)
    top_rays = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(top_rays)

    # Vertical light rays streaming down
    for i in range(7):
        rx1 = 100 + i * 160
        rx2 = rx1 + random.randint(-40, 40)
        rw = random.randint(70, 130)
        poly = [(rx1 - rw/2, 0), (rx1 + rw/2, 0), (rx2 + rw*1.8, h*0.75), (rx2 - rw*1.8, h*0.75)]
        rdraw.polygon(poly, fill=(160, 242, 255, 30))

    # Surface water ripple curves
    for y_rip in range(10, 180, 25):
        pts = []
        for x_rip in range(0, w + 40, 40):
            sin_y = y_rip + math.sin(x_rip * 0.03 + y_rip) * 12
            pts.append((x_rip, sin_y))
        rdraw.line(pts, fill=(210, 250, 255, 90), width=6)

    top_rays = top_rays.filter(ImageFilter.GaussianBlur(15))
    base = Image.alpha_composite(base, top_rays)

    # 3. Side Underwater Rocks, Coral & Starfish
    side_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(side_layer)

    # Dark blue organic rocks on left (x=0 to 360, y=250 to 2200)
    rock_dark = (10, 52, 86, 255)
    rock_mid = (18, 76, 118, 255)
    rock_high = (30, 105, 155, 255)

    left_rock_polys = [
        [(-50, 250), (260, 320), (220, 550), (-50, 600)],
        [(-50, 550), (290, 640), (240, 950), (-50, 1000)],
        [(-50, 950), (320, 1050), (270, 1400), (-50, 1450)],
        [(-50, 1400), (300, 1500), (250, 1850), (-50, 1900)],
        [(-50, 1850), (340, 1920), (360, 2400), (-50, 2400)],
    ]
    for poly in left_rock_polys:
        sdraw.polygon(poly, fill=rock_dark)
        # Inset rock face highlight
        inset = [(p[0]+25, p[1]+20) for p in poly]
        sdraw.polygon(inset, fill=rock_mid)

    # Right side rocks (x=810 to 1170, y=250 to 2200)
    right_rock_polys = [
        [(w+50, 280), (w-250, 350), (w-210, 580), (w+50, 630)],
        [(w+50, 580), (w-280, 680), (w-230, 980), (w+50, 1030)],
        [(w+50, 980), (w-310, 1080), (w-260, 1420), (w+50, 1470)],
        [(w+50, 1420), (w-290, 1520), (w-240, 1880), (w+50, 1930)],
        [(w+50, 1880), (w-330, 1950), (w-350, 2400), (w+50, 2400)],
    ]
    for poly in right_rock_polys:
        sdraw.polygon(poly, fill=rock_dark)
        inset = [(p[0]-25, p[1]+20) for p in poly]
        sdraw.polygon(inset, fill=rock_mid)

    # Green seaweed kelp strands on left and right
    def draw_seaweed(draw, base_x, base_y, height, color):
        pts = []
        for i in range(12):
            t = i / 11.0
            sy = base_y - t * height
            sx = base_x + math.sin(t * math.pi * 2.5) * 35
            pts.append((sx, sy))
        draw.line(pts, fill=color, width=18)

    for sx, sy in [(180, 800), (220, 1200), (240, 1600), (260, 2000), (200, 2300)]:
        draw_seaweed(sdraw, sx, sy, 350, (30, 175, 110, 255))
        draw_seaweed(sdraw, sx-20, sy+40, 280, (50, 215, 135, 255))

    for sx, sy in [(w-180, 850), (w-220, 1250), (w-240, 1650), (w-260, 2050), (w-200, 2350)]:
        draw_seaweed(sdraw, sx, sy, 350, (30, 175, 110, 255))
        draw_seaweed(sdraw, sx+20, sy+40, 280, (50, 215, 135, 255))

    # Bright Yellow Starfish on Left Rock Face (x=190, y=1120)
    s_cx, s_cy, s_rad = 190, 1120, 55
    star_pts = []
    for i in range(10):
        r = s_rad if i % 2 == 0 else s_rad * 0.42
        angle = math.radians(i * 36 - 90)
        star_pts.append((s_cx + math.cos(angle) * r, s_cy + math.sin(angle) * r))
    sdraw.polygon(star_pts, fill=(255, 205, 35, 255))
    sdraw.line(star_pts + [star_pts[0]], fill=(230, 145, 15, 255), width=4)
    # Starfish texture dots
    for i in range(5):
        angle = math.radians(i * 72 - 90)
        lx = s_cx + math.cos(angle) * (s_rad * 0.65)
        ly = s_cy + math.sin(angle) * (s_rad * 0.65)
        sdraw.ellipse([lx-4, ly-4, lx+4, ly+4], fill=(255, 255, 255, 255))
    sdraw.ellipse([s_cx-7, s_cy-7, s_cx+7, s_cy+7], fill=(230, 145, 15, 255))

    # Pink & Magenta Coral Branches on Left and Right
    def draw_coral_cluster(draw, cx, cy, fill_color):
        for angle in range(-60, 70, 25):
            rad = math.radians(angle - 90)
            ex = cx + math.cos(rad) * 65
            ey = cy + math.sin(rad) * 65
            draw.line([(cx, cy), (ex, ey)], fill=fill_color, width=14)
            draw.ellipse([ex-10, ey-10, ex+10, ey+10], fill=fill_color)

    draw_coral_cluster(sdraw, 220, 1420, (232, 68, 124, 255))
    draw_coral_cluster(sdraw, 250, 1850, (245, 110, 160, 255))
    draw_coral_cluster(sdraw, w-220, 1380, (160, 60, 175, 255))
    draw_coral_cluster(sdraw, w-250, 1820, (218, 80, 185, 255))

    base = Image.alpha_composite(base, side_layer)

    # 4. Floating Water Bubbles (Middle Region)
    bubble_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(bubble_layer)

    random.seed(42)
    for _ in range(45):
        bx = random.randint(150, w - 150)
        by = random.randint(300, h - 400)
        br = random.randint(8, 28)
        # Glassy bubble outline
        bdraw.ellipse([bx-br, by-br, bx+br, by+br], fill=(255, 255, 255, 35), outline=(255, 255, 255, 180), width=2)
        # Specular highlight dot
        hl_r = max(2, int(br * 0.3))
        bdraw.ellipse([bx-br*0.4-hl_r, by-br*0.4-hl_r, bx-br*0.4+hl_r, by-br*0.4+hl_r], fill=(255, 255, 255, 230))

    base = Image.alpha_composite(base, bubble_layer)

    # 5. Bottom Seabed & Coral Reef (y=1850 to 2532)
    bottom_layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bot_draw = ImageDraw.Draw(bottom_layer)

    # Sandy Reef Base (#083556 to #0e4c76)
    reef_pts = [(0, 2180), (w*0.3, 2140), (w*0.7, 2160), (w, 2120), (w, 2532), (0, 2532)]
    bot_draw.polygon(reef_pts, fill=(14, 76, 118, 255))

    # Foreground Reef Mound (#0b4267)
    fore_reef_pts = [(0, 2260), (w*0.25, 2220), (w*0.65, 2240), (w, 2200), (w, 2532), (0, 2532)]
    bot_draw.polygon(fore_reef_pts, fill=(11, 66, 103, 255))

    # Coral mounds on bottom corners
    for cx, cy, cr, ccol in [
        (100, 2280, 100, (235, 75, 115, 255)),
        (220, 2340, 80, (255, 155, 55, 255)),
        (w-100, 2280, 100, (235, 75, 115, 255)),
        (w-220, 2340, 80, (40, 205, 225, 255)),
    ]:
        bot_draw.ellipse([cx-cr, cy-cr, cx+cr, cy+cr], fill=ccol)

    base = Image.alpha_composite(base, bottom_layer)

    return base


def main():
    # Directories
    clover_dir = "assets/game/themes/clover_forest/background"
    underwater_dir = "assets/game/themes/underwater/background"

    os.makedirs(clover_dir, exist_ok=True)
    os.makedirs(underwater_dir, exist_ok=True)

    # 1. Clover Forest
    img_clover = create_clover_forest_background(1170, 2532)
    clover_path = os.path.join(clover_dir, "forest_background_390x844.png")
    img_clover.save(clover_path)
    print(f"Saved: {clover_path}")

    # Also save to assets/themes/green_forest/background/ for fallback/theme loading
    green_forest_dir = "assets/themes/green_forest/background"
    os.makedirs(green_forest_dir, exist_ok=True)
    img_clover.save(os.path.join(green_forest_dir, "forest_background_390x844.png"))
    img_clover.save(os.path.join(green_forest_dir, "forest_base.png"))

    # 2. Underwater
    img_underwater = create_underwater_background(1170, 2532)
    underwater_path = os.path.join(underwater_dir, "underwater_background_390x844.png")
    img_underwater.save(underwater_path)
    print(f"Saved: {underwater_path}")

    # Also save to assets/themes/ocean/background/ for ocean theme fallback
    ocean_dir = "assets/themes/ocean/background"
    os.makedirs(ocean_dir, exist_ok=True)
    img_underwater.save(os.path.join(ocean_dir, "underwater_background_390x844.png"))
    img_underwater.save(os.path.join(ocean_dir, "underwater_sky.png"))

    print("Successfully generated all exact 390x844 (1170x2532) portrait background assets!")

if __name__ == "__main__":
    main()
