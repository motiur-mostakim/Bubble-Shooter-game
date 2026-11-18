import os
import math
import zlib
import struct

class Canvas:
    def __init__(self, w, h, bg=(0, 0, 0, 0)):
        self.w = w
        self.h = h
        self.pixels = bytearray([bg[0], bg[1], bg[2], bg[3]] * (w * h))

    def blend_pixel(self, x, y, r, g, b, a):
        if 0 <= x < self.w and 0 <= y < self.h:
            if a <= 0: return
            idx = (y * self.w + x) * 4
            if a >= 255:
                self.pixels[idx] = r
                self.pixels[idx+1] = g
                self.pixels[idx+2] = b
                self.pixels[idx+3] = 255
            else:
                dst_a = self.pixels[idx+3]
                if dst_a == 0:
                    self.pixels[idx] = r
                    self.pixels[idx+1] = g
                    self.pixels[idx+2] = b
                    self.pixels[idx+3] = a
                else:
                    fa = a / 255.0
                    inv_a = 1.0 - fa
                    self.pixels[idx] = int(r * fa + self.pixels[idx] * inv_a)
                    self.pixels[idx+1] = int(g * fa + self.pixels[idx+1] * inv_a)
                    self.pixels[idx+2] = int(b * fa + self.pixels[idx+2] * inv_a)
                    self.pixels[idx+3] = min(255, int(a + dst_a * inv_a))

    def fill_v_gradient(self, colors):
        n = len(colors)
        for y in range(self.h):
            pos = y / max(1, self.h - 1) * (n - 1)
            idx1 = int(pos)
            idx2 = min(n - 1, idx1 + 1)
            t = pos - idx1
            c1, c2 = colors[idx1], colors[idx2]
            r = int(c1[0] * (1-t) + c2[0] * t)
            g = int(c1[1] * (1-t) + c2[1] * t)
            b = int(c1[2] * (1-t) + c2[2] * t)
            a = int(c1[3] * (1-t) + c2[3] * t)
            for x in range(self.w):
                pi = (y * self.w + x) * 4
                self.pixels[pi] = r
                self.pixels[pi+1] = g
                self.pixels[pi+2] = b
                self.pixels[pi+3] = a

    def draw_circle(self, cx, cy, radius, color):
        r, g, b, a = color
        min_x = max(0, int(cx - radius - 2))
        max_x = min(self.w, int(cx + radius + 3))
        min_y = max(0, int(cy - radius - 2))
        max_y = min(self.h, int(cy + radius + 3))
        r2 = radius * radius
        for y in range(min_y, max_y):
            dy = y - cy
            for x in range(min_x, max_x):
                dx = x - cx
                d2 = dx*dx + dy*dy
                if d2 <= r2:
                    dist = math.sqrt(d2)
                    if dist > radius - 1.0:
                        alpha_factor = max(0.0, radius - dist)
                        self.blend_pixel(x, y, r, g, b, int(a * alpha_factor))
                    else:
                        self.blend_pixel(x, y, r, g, b, a)

    def draw_ellipse(self, cx, cy, rx, ry, color):
        r, g, b, a = color
        min_x = max(0, int(cx - rx - 2))
        max_x = min(self.w, int(cx + rx + 3))
        min_y = max(0, int(cy - ry - 2))
        max_y = min(self.h, int(cy + ry + 3))
        rx_sq = max(1, rx * rx)
        ry_sq = max(1, ry * ry)
        for y in range(min_y, max_y):
            dy = y - cy
            dy_sq = dy * dy
            for x in range(min_x, max_x):
                dx = x - cx
                d2 = (dx*dx)/rx_sq + (dy_sq)/ry_sq
                if d2 <= 1.0:
                    dist = math.sqrt(d2)
                    if dist > 0.85:
                        edge_a = int(a * (1.0 - dist) / 0.15)
                        self.blend_pixel(x, y, r, g, b, max(0, edge_a))
                    else:
                        self.blend_pixel(x, y, r, g, b, a)

    def draw_rect(self, x1, y1, w, h, color):
        r, g, b, a = color
        for y in range(max(0, int(y1)), min(self.h, int(y1 + h))):
            for x in range(max(0, int(x1)), min(self.w, int(x1 + w))):
                self.blend_pixel(x, y, r, g, b, a)

    def draw_line(self, x1, y1, x2, y2, color, thickness=1):
        dist = math.hypot(x2 - x1, y2 - y1)
        steps = max(1, int(dist * 2))
        for i in range(steps + 1):
            t = i / steps
            cx = x1 + (x2 - x1) * t
            cy = y1 + (y2 - y1) * t
            self.draw_circle(cx, cy, thickness / 2.0, color)

    def draw_ring(self, cx, cy, r_inner, r_outer, color):
        r, g, b, a = color
        min_x = max(0, int(cx - r_outer - 2))
        max_x = min(self.w, int(cx + r_outer + 3))
        min_y = max(0, int(cy - r_outer - 2))
        max_y = min(self.h, int(cy + r_outer + 3))
        ro_sq = r_outer * r_outer
        ri_sq = r_inner * r_inner
        for y in range(min_y, max_y):
            dy = y - cy
            for x in range(min_x, max_x):
                dx = x - cx
                d2 = dx*dx + dy*dy
                if ri_sq <= d2 <= ro_sq:
                    self.blend_pixel(x, y, r, g, b, a)

    def save(self, filename):
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        raw = bytearray()
        for y in range(self.h):
            raw.append(0)
            idx = y * self.w * 4
            raw.extend(self.pixels[idx:idx + self.w * 4])
        compressed = zlib.compress(bytes(raw), 6)
        def chunk(two, data):
            return struct.pack('>I', len(data)) + two + data + struct.pack('>I', zlib.crc32(two + data) & 0xffffffff)
        header = b'\x89PNG\r\n\x1a\n'
        ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', self.w, self.h, 8, 6, 0, 0, 0))
        idat = chunk(b'IDAT', compressed)
        iend = chunk(b'IEND', b'')
        with open(filename, 'wb') as f:
            f.write(header + ihdr + idat + iend)


def make_jewel_bubble(main_color, dark_color, rim_color, symbol_type):
    c = Canvas(128, 128)
    cx, cy, radius = 64, 64, 58
    mr, mg, mb = main_color
    dr, dg, db = dark_color
    rr, rg, rb = rim_color

    # Drop shadow & outer rim
    c.draw_circle(cx, cy, radius, (dr, dg, db, 220))
    c.draw_circle(cx, cy, radius - 2, (rr, rg, rb, 255))
    c.draw_circle(cx, cy, radius - 4, (mr, mg, mb, 255))

    # Inner 3D spherical gradient
    for r in range(int(radius - 5), 0, -1):
        t = r / (radius - 5)
        icx = cx - (1.0 - t) * 12
        icy = cy - (1.0 - t) * 14
        cr = int(255 * (1 - t) * 0.45 + mr * t)
        cg = int(255 * (1 - t) * 0.45 + mg * t)
        cb = int(255 * (1 - t) * 0.45 + mb * t)
        c.draw_circle(icx, icy, r, (min(255, cr), min(255, cg), min(255, cb), 255))

    # Inner Embossed Symbol
    if symbol_type == 'clover':
        scx, scy = cx, cy + 2
        for angle in [0, 90, 180, 270]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 12
            ly = scy + math.sin(rad) * 12
            c.draw_circle(lx, ly, 14, (255, 255, 255, 120))
            c.draw_circle(lx, ly, 11, (255, 255, 255, 75))
        c.draw_line(scx, scy + 8, scx, scy + 24, (255, 255, 255, 140), thickness=4)
        c.draw_circle(scx, scy, 7, (255, 255, 255, 160))

    elif symbol_type == 'star':
        scx, scy = cx, cy + 2
        for angle in range(0, 360, 45):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 15
            ly = scy + math.sin(rad) * 15
            c.draw_circle(lx, ly, 5, (255, 255, 255, 130))
        c.draw_circle(scx, scy, 9, (255, 255, 255, 170))

    elif symbol_type == 'leaf':
        scx, scy = cx, cy + 2
        for angle in [-90, 30, 150]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_ellipse(lx, ly, 14, 10, (255, 255, 255, 125))
        c.draw_circle(scx, scy, 6, (255, 255, 255, 170))

    elif symbol_type == 'rune':
        scx, scy = cx, cy + 2
        c.draw_ring(scx, scy, 14, 18, (255, 255, 255, 130))
        c.draw_line(scx - 12, scy, scx + 12, scx, (255, 255, 255, 140), thickness=3)
        c.draw_line(scx, scy - 12, scx, scy + 12, (255, 255, 255, 140), thickness=3)

    elif symbol_type == 'sun':
        scx, scy = cx, cy + 2
        for angle in range(0, 360, 60):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 15
            ly = scy + math.sin(rad) * 15
            c.draw_circle(lx, ly, 7, (255, 255, 255, 120))
        c.draw_circle(scx, scy, 10, (255, 255, 255, 180))

    # Specular reflections
    c.draw_ellipse(cx - 18, cy - 22, 22, 12, (255, 255, 255, 210))
    c.draw_ellipse(cx - 20, cy - 24, 12, 6, (255, 255, 255, 250))
    c.draw_ellipse(cx + 18, cy + 22, 16, 6, (255, 255, 255, 110))
    c.draw_ring(cx, cy, radius - 4, radius - 2, (255, 255, 255, 70))
    return c


def build_fantasy_temple():
    print("Building Fantasy Temple Theme Assets...")
    out_dir = "assets/themes/fantasy_temple"

    # 1. Sky (Bright blue sky with white light gradient)
    c = Canvas(512, 1024)
    c.fill_v_gradient([
        (40, 110, 220, 255),
        (85, 160, 240, 255),
        (140, 200, 250, 255),
        (190, 225, 255, 255),
    ])
    c.save(f"{out_dir}/background/sky.png")

    # 2. Clouds (Soft fluffy white cloud layers)
    c = Canvas(512, 1024)
    for cx, cy, rx, ry in [
        (100, 120, 140, 50), (220, 90, 160, 60), (380, 130, 150, 55),
        (80, 240, 160, 65), (320, 260, 180, 70), (460, 220, 120, 50),
        (180, 420, 200, 80), (400, 400, 170, 70),
    ]:
        c.draw_ellipse(cx, cy, rx, ry, (255, 255, 255, 180))
        c.draw_ellipse(cx + 15, cy - 10, int(rx * 0.7), int(ry * 0.7), (255, 255, 255, 230))
    c.save(f"{out_dir}/background/clouds.png")

    # 3. Mountains & Lake (Distant green mountains & lake)
    c = Canvas(512, 1024)
    # Distant green mountain peaks
    for i in range(5):
        mx = i * 120 - 30
        c.draw_ellipse(mx, 620, 110, 250, (40, 120, 70, 220))
        c.draw_ellipse(mx + 60, 590, 90, 210, (60, 150, 90, 230))

    # Lake (Crystal blue water body)
    c.draw_rect(0, 680, 512, 180, (0, 145, 210, 220))
    # Lake water reflections
    for i in range(12):
        ly = 700 + i * 12
        c.draw_line(20 + i*10, ly, 490 - i*10, ly, (200, 240, 255, 120), thickness=2)
    c.save(f"{out_dir}/background/mountains.png")

    # 4. Temple Left Pillar & Roof
    c = Canvas(256, 512)
    # Ancient stone pillar body
    c.draw_rect(20, 80, 65, 380, (140, 135, 130, 240))
    c.draw_rect(10, 60, 85, 30, (180, 170, 155, 250)) # Capital
    c.draw_rect(10, 450, 85, 40, (180, 170, 155, 250)) # Base
    # Golden roof trim
    c.draw_rect(5, 35, 95, 25, (230, 180, 40, 255))
    c.draw_circle(50, 25, 20, (255, 215, 0, 255))
    # Vines and plants on pillar
    for i in range(8):
        vy = 100 + i * 40
        c.draw_ellipse(50 + (i % 2) * 15, vy, 18, 10, (45, 140, 60, 230))
    c.save(f"{out_dir}/decorations/temple_left.png")

    # 5. Temple Right Pillar & Roof
    c = Canvas(256, 512)
    c.draw_rect(171, 80, 65, 380, (140, 135, 130, 240))
    c.draw_rect(161, 60, 85, 30, (180, 170, 155, 250))
    c.draw_rect(161, 450, 85, 40, (180, 170, 155, 250))
    c.draw_rect(156, 35, 95, 25, (230, 180, 40, 255))
    c.draw_circle(206, 25, 20, (255, 215, 0, 255))
    for i in range(8):
        vy = 100 + i * 40
        c.draw_ellipse(190 - (i % 2) * 15, vy, 18, 10, (45, 140, 60, 230))
    c.save(f"{out_dir}/decorations/temple_right.png")

    # 6. Bottom Temple Platform
    c = Canvas(512, 256)
    # Stone platform base
    c.draw_rect(0, 160, 512, 96, (120, 115, 110, 255))
    c.draw_rect(0, 140, 512, 25, (170, 160, 145, 255))
    # Golden carved line trim
    c.draw_line(0, 145, 512, 145, (255, 215, 0, 255), thickness=4)
    # Decorative plants on platform
    for px in [40, 120, 200, 310, 390, 470]:
        c.draw_circle(px, 140, 22, (40, 150, 65, 240))
        c.draw_circle(px, 135, 15, (80, 190, 95, 250))
    c.save(f"{out_dir}/decorations/platform.png")

    # 7. Bubbles for Fantasy Temple
    make_jewel_bubble((235, 45, 45), (120, 10, 10), (255, 120, 120), 'sun').save(f"{out_dir}/bubbles/red.png")
    make_jewel_bubble((30, 130, 245), (10, 50, 130), (120, 190, 255), 'rune').save(f"{out_dir}/bubbles/blue.png")
    make_jewel_bubble((45, 195, 75), (15, 90, 30), (130, 240, 150), 'leaf').save(f"{out_dir}/bubbles/green.png")
    make_jewel_bubble((165, 65, 215), (75, 20, 110), (220, 150, 255), 'star').save(f"{out_dir}/bubbles/purple.png")
    make_jewel_bubble((250, 195, 25), (140, 95, 0), (255, 235, 120), 'sun').save(f"{out_dir}/bubbles/yellow.png")

    # Special Crystal Bubble
    cb = Canvas(128, 128)
    cx, cy, r = 64, 64, 58
    cb.draw_circle(cx, cy, r, (0, 180, 240, 220))
    cb.draw_circle(cx, cy, r - 3, (120, 230, 255, 255))
    # Diamond facets
    points = [(cx, cy - 45), (cx + 40, cy), (cx, cy + 45), (cx - 40, cy)]
    for i in range(4):
        p1 = points[i]
        p2 = points[(i + 1) % 4]
        cb.draw_line(p1[0], p1[1], p2[0], p2[1], (255, 255, 255, 255), thickness=4)
        cb.draw_line(cx, cy, p1[0], p1[1], (255, 255, 255, 200), thickness=3)
    cb.draw_circle(cx, cy, 14, (255, 255, 255, 240))
    cb.draw_ellipse(cx - 15, cy - 18, 18, 9, (255, 255, 255, 240))
    cb.save(f"{out_dir}/bubbles/crystal.png")

    # Special Rainbow Bubble
    rb = Canvas(128, 128)
    rb.draw_circle(cx, cy, r, (255, 255, 255, 240))
    rb.draw_circle(cx, cy, r - 3, (240, 240, 250, 255))
    rainbow_cols = [
        (255, 50, 50), (255, 150, 30), (255, 220, 40),
        (50, 200, 80), (40, 150, 250), (160, 60, 220)
    ]
    for idx, col in enumerate(rainbow_cols):
        rb.draw_ring(cx, cy, 12 + idx * 7, 18 + idx * 7, (col[0], col[1], col[2], 220))
    rb.draw_circle(cx, cy, 10, (255, 255, 255, 255))
    rb.draw_ellipse(cx - 16, cy - 20, 20, 10, (255, 255, 255, 230))
    rb.save(f"{out_dir}/bubbles/rainbow.png")

    # 8. Purple & Golden Fantasy Cannon
    cn = Canvas(256, 256)
    cx, cy = 128, 128
    # Outer golden ring platform
    cn.draw_circle(cx, cy, 110, (120, 30, 140, 230))
    cn.draw_ring(cx, cy, 96, 108, (255, 215, 0, 255))
    cn.draw_ring(cx, cy, 98, 106, (255, 240, 140, 255))

    # Inner deep purple launcher chamber
    cn.draw_circle(cx, cy, 96, (75, 20, 100, 255))
    for i in range(92, 0, -1):
        t = i / 92.0
        v = int(60 + t * 90)
        cn.draw_circle(cx, cy, i, (int(v * 0.7), int(v * 0.2), v, 255))

    # Gold studs
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 102
        by = cy + math.sin(rad) * 102
        cn.draw_circle(bx, by, 5, (255, 215, 0, 255))
    cn.save(f"{out_dir}/shooter/cannon_base.png")

    # 9. Aim Dot
    ad = Canvas(64, 64)
    ad.draw_circle(32, 32, 18, (255, 215, 0, 100))
    ad.draw_circle(32, 32, 12, (255, 235, 100, 200))
    ad.draw_circle(32, 32, 6, (255, 255, 255, 255))
    ad.save(f"{out_dir}/effects/aim_dot.png")

    print("Fantasy Temple theme assets built successfully!")


def build_green_forest():
    print("Building Green Forest Theme Assets...")
    out_dir = "assets/themes/green_forest"

    # 1. Base Forest Environment Gradient
    c = Canvas(512, 1024)
    c.fill_v_gradient([
        (10, 46, 32, 255),
        (22, 78, 54, 255),
        (36, 120, 80, 255),
        (26, 90, 60, 255),
        (14, 52, 36, 255)
    ])
    c.save(f"{out_dir}/background/forest_base.png")

    # 2. Distant Forest Silhouettes
    c = Canvas(512, 1024)
    for i in range(14):
        cx = i * 42 - 20
        c.draw_ellipse(cx, 550, 55, 270, (12, 50, 32, 190))
        c.draw_ellipse(cx + 25, 500, 45, 230, (18, 68, 44, 210))
    c.save(f"{out_dir}/background/distant_trees.png")

    # 3. Middle Trees & Sunbeams
    c = Canvas(512, 1024)
    for i in range(6):
        c.draw_line(60 + i * 75, 0, 140 + i * 85, 1024, (200, 255, 180, 35), thickness=40)
    c.draw_ellipse(80, 60, 220, 140, (14, 60, 35, 230))
    c.draw_ellipse(432, 60, 220, 140, (14, 60, 35, 230))
    c.save(f"{out_dir}/background/middle_trees.png")

    # 4. Decorative Left Leaves
    c = Canvas(256, 512)
    c.draw_line(0, 0, 140, 320, (38, 26, 12, 255), thickness=12)
    c.draw_line(120, 100, 220, 260, (38, 26, 12, 255), thickness=8)
    for i in range(10):
        lx = 25 + i * 16
        ly = 25 + i * 30
        c.draw_ellipse(lx + 30, ly, 38, 20, (35, 130, 52, 240))
        c.draw_ellipse(lx + 24, ly - 4, 30, 14, (65, 185, 82, 250))
        c.draw_line(lx, ly, lx + 45, ly, (15, 65, 28, 220), thickness=2)
    c.save(f"{out_dir}/decorations/leaves_left.png")

    # 5. Decorative Right Leaves
    c = Canvas(256, 512)
    c.draw_line(256, 0, 116, 320, (38, 26, 12, 255), thickness=12)
    c.draw_line(136, 100, 36, 260, (38, 26, 12, 255), thickness=8)
    for i in range(10):
        lx = 231 - (25 + i * 16)
        ly = 25 + i * 30
        c.draw_ellipse(lx - 30, ly, 38, 20, (35, 130, 52, 240))
        c.draw_ellipse(lx - 24, ly - 4, 30, 14, (65, 185, 82, 250))
        c.draw_line(lx, ly, lx - 45, ly, (15, 65, 28, 220), thickness=2)
    c.save(f"{out_dir}/decorations/leaves_right.png")

    # 6. Bottom Grass & Bushes
    c = Canvas(512, 256)
    for i in range(24):
        c.draw_ellipse(i * 24 - 10, 190, 28, 85, (20, 95, 36, 240))
    for i in range(35):
        gx = i * 16 - 5
        c.draw_line(gx, 256, gx + (i % 3 - 1) * 10, 110 + (i % 5) * 12, (68, 195, 85, 255), thickness=5)
    for fx, fy in [(50, 155), (140, 175), (260, 145), (370, 170), (470, 150)]:
        c.draw_circle(fx, fy, 11, (240, 40, 100, 255))
        c.draw_circle(fx, fy, 4, (255, 235, 50, 255))
    c.save(f"{out_dir}/decorations/grass.png")

    # 7. Green Forest Bubbles (Clover Jewel Bubbles)
    make_jewel_bubble((235, 45, 45), (120, 10, 10), (255, 120, 120), 'clover').save(f"{out_dir}/bubbles/red_clover.png")
    make_jewel_bubble((30, 130, 245), (10, 50, 130), (120, 190, 255), 'clover').save(f"{out_dir}/bubbles/blue_clover.png")
    make_jewel_bubble((45, 195, 75), (15, 90, 30), (130, 240, 150), 'clover').save(f"{out_dir}/bubbles/green_clover.png")
    make_jewel_bubble((165, 65, 215), (75, 20, 110), (220, 150, 255), 'clover').save(f"{out_dir}/bubbles/purple_clover.png")
    make_jewel_bubble((250, 195, 25), (140, 95, 0), (255, 235, 120), 'clover').save(f"{out_dir}/bubbles/yellow_clover.png")

    # Metallic Dark Special Bubble
    mb = Canvas(128, 128)
    cx, cy, r = 64, 64, 58
    mb.draw_circle(cx, cy, r, (20, 25, 30, 240))
    mb.draw_circle(cx, cy, r - 3, (80, 90, 100, 255))
    for i in range(int(r - 6), 0, -1):
        t = i / (r - 6)
        icx = cx - (1.0 - t) * 10
        icy = cy - (1.0 - t) * 12
        v = int(40 + t * 90)
        mb.draw_circle(icx, icy, i, (v, v + 8, v + 15, 255))
    mb.draw_ring(cx, cy, 32, 36, (30, 35, 40, 255))
    mb.draw_ring(cx, cy, 33, 35, (180, 190, 205, 220))
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 44
        by = cy + math.sin(rad) * 44
        mb.draw_circle(bx, by, 3, (210, 220, 235, 255))
    mb.draw_ellipse(cx - 16, cy - 20, 22, 10, (240, 245, 255, 220))
    mb.save(f"{out_dir}/bubbles/metallic_special_bubble.png")

    # 8. Forest Cannon
    fc = Canvas(256, 256)
    cx, cy = 128, 128
    fc.draw_circle(cx, cy, 110, (15, 75, 30, 230))
    fc.draw_ring(cx, cy, 96, 108, (215, 175, 45, 255))
    fc.draw_ring(cx, cy, 98, 106, (255, 225, 100, 255))
    fc.draw_circle(cx, cy, 96, (20, 90, 40, 255))
    for i in range(92, 0, -1):
        t = i / 92.0
        v_g = int(40 + t * 75)
        v_b = int(20 + t * 35)
        fc.draw_circle(cx, cy, i, (15, v_g, v_b, 255))
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 102
        by = cy + math.sin(rad) * 102
        fc.draw_circle(bx, by, 5, (255, 220, 80, 255))
    fc.save(f"{out_dir}/shooter/forest_cannon.png")

    # 9. Clover Bubble inside Launcher
    clb = make_jewel_bubble((35, 185, 65), (10, 80, 25), (120, 240, 140), 'clover')
    clb.save(f"{out_dir}/shooter/clover_bubble.png")

    # 10. Neon Aim Dot
    nd = Canvas(64, 64)
    nd.draw_circle(32, 32, 18, (118, 255, 3, 90))
    nd.draw_circle(32, 32, 12, (162, 255, 42, 190))
    nd.draw_circle(32, 32, 6, (235, 255, 200, 255))
    nd.save(f"{out_dir}/effects/neon_aim_dot.png")

    print("Green Forest theme assets built successfully!")

if __name__ == '__main__':
    build_fantasy_temple()
    build_green_forest()
