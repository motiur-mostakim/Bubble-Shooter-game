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
        rx_sq = rx * rx
        ry_sq = ry * ry
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

    # 1. Dark outer drop shadow & glow rim
    c.draw_circle(cx, cy, radius, (dr, dg, db, 220))
    c.draw_circle(cx, cy, radius - 2, (rr, rg, rb, 255))
    c.draw_circle(cx, cy, radius - 4, (mr, mg, mb, 255))

    # 2. Inner Radial Shading (bright center top, darker bottom)
    for r in range(int(radius - 5), 0, -1):
        t = r / (radius - 5)
        icx = cx - (1.0 - t) * 12
        icy = cy - (1.0 - t) * 14
        cr = int(255 * (1 - t) * 0.45 + mr * t)
        cg = int(255 * (1 - t) * 0.45 + mg * t)
        cb = int(255 * (1 - t) * 0.45 + mb * t)
        c.draw_circle(icx, icy, r, (min(255, cr), min(255, cg), min(255, cb), 255))

    # 3. Inner Embossed Decorative Symbol
    if symbol_type == 'clover':
        scx, scy = cx, cy + 2
        leaf_r = 14
        for angle in [0, 90, 180, 270]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 12
            ly = scy + math.sin(rad) * 12
            c.draw_circle(lx, ly, leaf_r, (255, 255, 255, 120))
            c.draw_circle(lx, ly, leaf_r - 3, (255, 255, 255, 80))
        c.draw_line(scx, scy + 8, scx, scy + 24, (255, 255, 255, 140), thickness=4)
        c.draw_circle(scx, scy, 7, (255, 255, 255, 160))

    elif symbol_type == 'crystal':
        # Hexagonal crystal facet symbol
        scx, scy = cx, cy
        for angle in range(0, 360, 60):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 18
            ly = scy + math.sin(rad) * 18
            c.draw_line(scx, scy, lx, ly, (255, 255, 255, 150), thickness=2)
        c.draw_circle(scx, scy, 10, (255, 255, 255, 180))

    elif symbol_type == 'rainbow':
        # Multi-color concentric rings symbol
        scx, scy = cx, cy
        rainbow_cols = [(255, 80, 80), (255, 180, 50), (255, 235, 60), (80, 220, 100), (60, 180, 255), (180, 90, 255)]
        for idx, r_col in enumerate(rainbow_cols):
            r_size = 28 - idx * 4
            if r_size > 4:
                c.draw_circle(scx, scy, r_size, (r_col[0], r_col[1], r_col[2], 230))
        c.draw_circle(scx, scy, 6, (255, 255, 255, 255))

    elif symbol_type == 'floral':
        scx, scy = cx, cy + 2
        for angle in [45, 135, 225, 315]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_ellipse(lx, ly, 14, 9, (255, 255, 255, 120))
        c.draw_circle(scx, scy, 8, (255, 255, 255, 170))

    elif symbol_type == 'leaf':
        scx, scy = cx, cy + 2
        for angle in [-90, 30, 150]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_ellipse(lx, ly, 13, 10, (255, 255, 255, 125))
        c.draw_circle(scx, scy, 6, (255, 255, 255, 170))

    elif symbol_type == 'star':
        scx, scy = cx, cy + 2
        for angle in range(0, 360, 45):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 16
            ly = scy + math.sin(rad) * 16
            c.draw_circle(lx, ly, 5, (255, 255, 255, 130))
        c.draw_circle(scx, scy, 10, (255, 255, 255, 160))

    # 4. Glossy Reflections & Highlights
    c.draw_ellipse(cx - 18, cy - 22, 22, 12, (255, 255, 255, 210))
    c.draw_ellipse(cx - 20, cy - 24, 12, 6, (255, 255, 255, 250))
    c.draw_ellipse(cx + 18, cy + 22, 16, 6, (255, 255, 255, 110))
    c.draw_ring(cx, cy, radius - 4, radius - 2, (255, 255, 255, 70))

    return c


def build_fantasy_temple():
    print("Building Fantasy Temple Theme Assets...")
    # 1. Sky (Bright blue sky)
    c = Canvas(512, 1024)
    c.fill_v_gradient([
        (13, 71, 161, 255),  # Deep azure
        (30, 136, 229, 255), # Sky blue
        (79, 195, 247, 255), # Cyan blue
        (224, 247, 250, 255) # Soft golden horizon glow
    ])
    c.save("assets/themes/fantasy_temple/background/sky.png")

    # 2. Clouds (Beautiful white clouds)
    c = Canvas(512, 1024)
    # Top fluffy clouds
    cloud_centers = [(80, 120, 60, 40), (160, 100, 75, 45), (280, 140, 90, 50), (420, 110, 70, 40),
                     (60, 280, 70, 40), (220, 260, 85, 48), (380, 290, 75, 42)]
    for cx, cy, rx, ry in cloud_centers:
        c.draw_ellipse(cx, cy, rx, ry, (255, 255, 255, 230))
        c.draw_ellipse(cx - 10, cy - 8, int(rx*0.7), int(ry*0.7), (255, 255, 255, 255))
        c.draw_ellipse(cx + 15, cy + 10, int(rx*0.6), int(ry*0.5), (220, 240, 255, 180))
    c.save("assets/themes/fantasy_temple/background/clouds.png")

    # 3. Mountains & Lake (Distant green mountains & large blue lake)
    c = Canvas(512, 1024)
    # Distant green mountain silhouettes
    for i in range(5):
        mx = i * 110 - 20
        c.draw_ellipse(mx, 600, 85, 240, (34, 112, 58, 220))
        c.draw_ellipse(mx + 45, 570, 70, 200, (46, 139, 87, 230))
    # Midground hills & lake
    c.draw_ellipse(256, 720, 300, 110, (3, 169, 244, 220)) # Shimmering blue lake
    c.draw_ellipse(256, 715, 280, 80, (129, 212, 250, 180)) # Lake highlight
    c.save("assets/themes/fantasy_temple/background/mountains.png")

    # 4. Temple Left (Ancient stone temple pillars on left)
    c = Canvas(256, 512)
    # Ancient stone pillar structure
    c.draw_rect(10, 0, 70, 512, (100, 105, 115, 240))
    c.draw_rect(15, 0, 20, 512, (140, 145, 155, 250))
    # Capital & Base
    c.draw_rect(0, 40, 90, 30, (80, 85, 95, 250))
    c.draw_rect(0, 420, 90, 40, (80, 85, 95, 250))
    # Decorative vines & plants hanging
    for i in range(8):
        vy = i * 45 + 30
        c.draw_ellipse(75, vy, 25, 14, (56, 142, 60, 240))
        c.draw_ellipse(80, vy - 4, 18, 9, (102, 187, 106, 250))
    c.save("assets/themes/fantasy_temple/decorations/temple_left.png")

    # 5. Temple Right (Ancient stone temple pillars on right)
    c = Canvas(256, 512)
    c.draw_rect(176, 0, 70, 512, (100, 105, 115, 240))
    c.draw_rect(221, 0, 20, 512, (140, 145, 155, 250))
    c.draw_rect(166, 40, 90, 30, (80, 85, 95, 250))
    c.draw_rect(166, 420, 90, 40, (80, 85, 95, 250))
    for i in range(8):
        vy = i * 45 + 30
        c.draw_ellipse(181, vy, 25, 14, (56, 142, 60, 240))
        c.draw_ellipse(176, vy - 4, 18, 9, (102, 187, 106, 250))
    c.save("assets/themes/fantasy_temple/decorations/temple_right.png")

    # 6. Bottom Platform (Ancient stone platform & plants)
    c = Canvas(512, 256)
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (90, 95, 105, 240), (60, 65, 75, 255)])
    # Stone carvings / tiles
    for x in range(0, 512, 64):
        c.draw_line(x, 150, x, 256, (120, 125, 135, 200), thickness=3)
    c.draw_line(0, 150, 512, 150, (255, 215, 0, 220), thickness=4) # Golden temple trim
    # Decorative foliage at bottom
    for i in range(16):
        gx = i * 34 - 10
        c.draw_ellipse(gx, 150, 22, 12, (76, 175, 80, 240))
    c.save("assets/themes/fantasy_temple/decorations/platform.png")

    # 7. Bubbles (Glossy jewel-style circular bubbles)
    make_jewel_bubble((235, 45, 45), (120, 10, 10), (255, 140, 140), 'floral').save("assets/themes/fantasy_temple/bubbles/red.png")
    make_jewel_bubble((30, 130, 245), (10, 50, 130), (140, 200, 255), 'crystal').save("assets/themes/fantasy_temple/bubbles/blue.png")
    make_jewel_bubble((45, 195, 75), (15, 90, 30), (150, 240, 160), 'leaf').save("assets/themes/fantasy_temple/bubbles/green.png")
    make_jewel_bubble((165, 65, 215), (75, 20, 110), (230, 160, 255), 'star').save("assets/themes/fantasy_temple/bubbles/purple.png")
    make_jewel_bubble((250, 195, 25), (140, 95, 0), (255, 240, 140), 'clover').save("assets/themes/fantasy_temple/bubbles/yellow.png")
    make_jewel_bubble((200, 230, 255), (80, 120, 160), (255, 255, 255), 'crystal').save("assets/themes/fantasy_temple/bubbles/crystal.png")
    make_jewel_bubble((240, 120, 240), (100, 30, 120), (255, 255, 255), 'rainbow').save("assets/themes/fantasy_temple/bubbles/rainbow.png")

    # 8. Cannon (Purple & Golden Fantasy Cannon)
    c = Canvas(256, 256)
    cx, cy = 128, 128
    # Outer gold & purple ring platform
    c.draw_circle(cx, cy, 110, (74, 20, 140, 240))
    c.draw_ring(cx, cy, 96, 108, (255, 215, 0, 255))
    c.draw_ring(cx, cy, 98, 106, (255, 245, 150, 255))
    c.draw_circle(cx, cy, 94, (106, 27, 154, 255))
    # Golden rivets around ring
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 102
        by = cy + math.sin(rad) * 102
        c.draw_circle(bx, by, 5, (255, 215, 0, 255))
        c.draw_circle(bx - 1, by - 1, 2, (255, 255, 220, 255))
    c.draw_ring(cx, cy, 65, 70, (255, 215, 0, 200))
    c.save("assets/themes/fantasy_temple/shooter/cannon_base.png")

    # 9. Aim Dot (Glowing sparkle dot)
    c = Canvas(64, 64)
    cx, cy = 32, 32
    c.draw_circle(cx, cy, 18, (255, 215, 0, 100))
    c.draw_circle(cx, cy, 12, (255, 235, 100, 180))
    c.draw_circle(cx, cy, 7, (255, 255, 255, 255))
    c.save("assets/themes/fantasy_temple/effects/aim_dot.png")


def build_green_forest():
    print("Building Green Forest Theme Assets...")
    # 1. Sky / Forest Base (Deep teal and green forest)
    c = Canvas(512, 1024)
    c.fill_v_gradient([
        (5, 26, 21, 255),   # Deep teal
        (15, 56, 44, 255),  # Dark forest green
        (27, 94, 60, 255),  # Emerald forest green
        (18, 65, 42, 255),  # Forest mid
        (8, 35, 22, 255)    # Dark forest floor
    ])
    c.save("assets/themes/green_forest/background/forest_base.png")

    # 2. Distant Trees (Layered dark forest silhouettes)
    c = Canvas(512, 1024)
    for i in range(15):
        cx = i * 38 - 15
        c.draw_ellipse(cx, 550, 50, 260, (10, 40, 28, 190))
        c.draw_ellipse(cx + 20, 500, 40, 220, (16, 58, 38, 210))
    for i in range(12):
        cx = i * 46 - 10
        c.draw_circle(cx, 700, 65, (22, 75, 48, 220))
    c.save("assets/themes/green_forest/background/distant_trees.png")

    # 3. Middle Trees (Foliage canopy & golden sunbeams)
    c = Canvas(512, 1024)
    # Golden sunbeams streaming through trees
    for i in range(6):
        c.draw_line(70 + i * 75, 0, 150 + i * 85, 1024, (240, 255, 160, 35), thickness=38)
    # Top canopy arches
    c.draw_ellipse(90, 50, 230, 130, (14, 52, 32, 240))
    c.draw_ellipse(422, 50, 230, 130, (14, 52, 32, 240))
    c.save("assets/themes/green_forest/background/middle_trees.png")

    # 4. Leaves Left (Large decorative leaves on left)
    c = Canvas(256, 512)
    c.draw_line(0, 0, 130, 310, (40, 28, 12, 255), thickness=11)
    for i in range(9):
        lx = 20 + i * 15
        ly = 25 + i * 32
        c.draw_ellipse(lx + 30, ly, 36, 19, (38, 125, 48, 240))
        c.draw_ellipse(lx + 24, ly - 4, 28, 13, (76, 175, 80, 250))
        c.draw_line(lx, ly, lx + 45, ly, (16, 60, 22, 210), thickness=2)
    c.save("assets/themes/green_forest/decorations/leaves_left.png")

    # 5. Leaves Right (Large decorative leaves on right)
    c = Canvas(256, 512)
    c.draw_line(256, 0, 126, 310, (40, 28, 12, 255), thickness=11)
    for i in range(9):
        lx = 236 - (20 + i * 15)
        ly = 25 + i * 32
        c.draw_ellipse(lx - 30, ly, 36, 19, (38, 125, 48, 240))
        c.draw_ellipse(lx - 24, ly - 4, 28, 13, (76, 175, 80, 250))
        c.draw_line(lx, ly, lx - 45, ly, (16, 60, 22, 210), thickness=2)
    c.save("assets/themes/green_forest/decorations/leaves_right.png")

    # 6. Bottom Grass (Bright green grass & vegetation)
    c = Canvas(512, 256)
    for i in range(22):
        c.draw_ellipse(i * 26 - 10, 190, 28, 85, (22, 85, 30, 240))
    for i in range(32):
        gx = i * 17 - 5
        c.draw_line(gx, 256, gx + (i % 3 - 1) * 9, 115 + (i % 5) * 11, (76, 175, 80, 255), thickness=5)
    # Small flowers
    for fx, fy in [(55, 160), (150, 180), (270, 150), (375, 175), (465, 155)]:
        c.draw_circle(fx, fy, 11, (233, 30, 99, 255))
        c.draw_circle(fx, fy, 4, (255, 235, 59, 255))
    c.save("assets/themes/green_forest/decorations/grass.png")

    # 7. Bubbles (Glossy jewel-style bubbles with clover symbols)
    make_jewel_bubble((235, 45, 45), (120, 10, 10), (255, 140, 140), 'clover').save("assets/themes/green_forest/bubbles/red_clover.png")
    make_jewel_bubble((30, 130, 245), (10, 50, 130), (140, 200, 255), 'clover').save("assets/themes/green_forest/bubbles/blue_clover.png")
    make_jewel_bubble((45, 195, 75), (15, 90, 30), (150, 240, 160), 'clover').save("assets/themes/green_forest/bubbles/green_clover.png")
    make_jewel_bubble((165, 65, 215), (75, 20, 110), (230, 160, 255), 'clover').save("assets/themes/green_forest/bubbles/purple_clover.png")
    make_jewel_bubble((250, 195, 25), (140, 95, 0), (255, 240, 140), 'clover').save("assets/themes/green_forest/bubbles/yellow_clover.png")

    # Metallic Special Bubble
    c = Canvas(128, 128)
    cx, cy, r = 64, 64, 58
    c.draw_circle(cx, cy, r, (20, 20, 25, 240))
    c.draw_circle(cx, cy, r - 3, (80, 85, 95, 255))
    for i in range(int(r - 6), 0, -1):
        t = i / (r - 6)
        icx = cx - (1.0 - t) * 10
        icy = cy - (1.0 - t) * 12
        v = int(40 + t * 90)
        c.draw_circle(icx, icy, i, (v, v + 5, v + 12, 255))
    c.draw_ring(cx, cy, 32, 36, (30, 32, 38, 255))
    c.draw_ring(cx, cy, 33, 35, (160, 170, 185, 220))
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 44
        by = cy + math.sin(rad) * 44
        c.draw_circle(bx, by, 3, (200, 210, 225, 255))
        c.draw_circle(bx, by, 1.5, (40, 45, 55, 255))
    c.draw_ellipse(cx - 16, cy - 20, 22, 10, (240, 245, 255, 220))
    c.draw_ellipse(cx - 18, cy - 22, 12, 5, (255, 255, 255, 255))
    c.save("assets/themes/green_forest/bubbles/metallic_special_bubble.png")

    # 8. Shooter (Forest cannon base & Clover bubble)
    c = Canvas(256, 256)
    cx, cy = 128, 128
    c.draw_circle(cx, cy, 110, (20, 75, 32, 240))
    c.draw_ring(cx, cy, 96, 108, (76, 175, 80, 255))
    c.draw_ring(cx, cy, 98, 106, (139, 195, 74, 255))
    c.draw_circle(cx, cy, 94, (15, 60, 25, 255))
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 102
        by = cy + math.sin(rad) * 102
        c.draw_circle(bx, by, 5, (255, 215, 0, 255))
        c.draw_circle(bx - 1, by - 1, 2, (255, 255, 200, 255))
    c.draw_ring(cx, cy, 65, 70, (118, 255, 3, 200))
    c.save("assets/themes/green_forest/shooter/forest_cannon.png")

    b = make_jewel_bubble((35, 185, 65), (10, 80, 25), (120, 240, 140), 'clover')
    scx, scy = 64, 66
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        lx = scx + math.cos(rad) * 12
        ly = scy + math.sin(rad) * 12
        b.draw_circle(lx, ly, 13, (255, 215, 0, 230))
        b.draw_circle(lx - 2, ly - 2, 7, (255, 245, 160, 250))
    b.draw_circle(scx, scy, 7, (255, 225, 50, 255))
    b.draw_line(scx, scy + 8, scx, scy + 22, (255, 215, 0, 255), thickness=4)
    b.draw_ellipse(64 - 18, 64 - 22, 20, 10, (255, 255, 255, 210))
    b.save("assets/themes/green_forest/shooter/clover_bubble.png")

    # 9. Neon Aim Dot (Green dotted neon trajectory)
    c = Canvas(64, 64)
    cx, cy = 32, 32
    c.draw_circle(cx, cy, 18, (118, 255, 3, 90))
    c.draw_circle(cx, cy, 12, (160, 255, 40, 180))
    c.draw_circle(cx, cy, 7, (230, 255, 180, 255))
    c.save("assets/themes/green_forest/effects/neon_aim_dot.png")


if __name__ == '__main__':
    build_fantasy_temple()
    build_green_forest()
    print("FINISHED GENERATING ALL FANTASY TEMPLE AND GREEN FOREST ASSETS!")
