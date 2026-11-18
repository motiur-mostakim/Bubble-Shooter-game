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

# Utility function to render a glossy jewel bubble with embossed symbol
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
        # Shift center slightly up for 3D sphere look
        icx = cx - (1.0 - t) * 12
        icy = cy - (1.0 - t) * 14
        cr = int(255 * (1 - t) * 0.45 + mr * t)
        cg = int(255 * (1 - t) * 0.45 + mg * t)
        cb = int(255 * (1 - t) * 0.45 + mb * t)
        c.draw_circle(icx, icy, r, (min(255, cr), min(255, cg), min(255, cb), 255))

    # 3. Inner Embossed Decorative Symbol
    if symbol_type == 'clover':
        # 4-leaf clover symbol
        scx, scy = cx, cy + 2
        leaf_r = 14
        for angle in [0, 90, 180, 270]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 12
            ly = scy + math.sin(rad) * 12
            c.draw_circle(lx, ly, leaf_r, (255, 255, 255, 110))
            c.draw_circle(lx, ly, leaf_r - 3, (255, 255, 255, 70))
        # Stem
        c.draw_line(scx, scy + 8, scx, scy + 24, (255, 255, 255, 130), thickness=4)
        c.draw_circle(scx, scy, 7, (255, 255, 255, 150))

    elif symbol_type == 'floral':
        # 4-petal flower
        scx, scy = cx, cy + 2
        for angle in [45, 135, 225, 315]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_ellipse(lx, ly, 14, 9, (255, 255, 255, 110))
        c.draw_circle(scx, scy, 8, (255, 255, 255, 160))

    elif symbol_type == 'leaf':
        # 3-leaf trefoil symbol
        scx, scy = cx, cy + 2
        for angle in [-90, 30, 150]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_ellipse(lx, ly, 13, 10, (255, 255, 255, 115))
        c.draw_circle(scx, scy, 6, (255, 255, 255, 160))

    elif symbol_type == 'star':
        # Starburst blossom symbol
        scx, scy = cx, cy + 2
        for angle in range(0, 360, 45):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 16
            ly = scy + math.sin(rad) * 16
            c.draw_circle(lx, ly, 5, (255, 255, 255, 120))
        c.draw_circle(scx, scy, 10, (255, 255, 255, 150))

    elif symbol_type == 'sunflower':
        # Sunburst / clover ring
        scx, scy = cx, cy + 2
        for angle in range(0, 360, 60):
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_circle(lx, ly, 7, (255, 255, 255, 110))
        c.draw_circle(scx, scy, 9, (255, 255, 255, 170))

    elif symbol_type == 'blossom':
        # Petal ring
        scx, scy = cx, cy + 2
        for angle in [0, 72, 144, 216, 288]:
            rad = math.radians(angle)
            lx = scx + math.cos(rad) * 14
            ly = scy + math.sin(rad) * 14
            c.draw_circle(lx, ly, 8, (255, 255, 255, 115))
        c.draw_circle(scx, scy, 7, (255, 255, 255, 160))

    # 4. Glossy Reflections & Highlights
    # Top-Left primary crescent highlight dome
    c.draw_ellipse(cx - 18, cy - 22, 22, 12, (255, 255, 255, 200))
    c.draw_ellipse(cx - 20, cy - 24, 12, 6, (255, 255, 255, 240))

    # Bottom-Right subtle rim reflection
    c.draw_ellipse(cx + 18, cy + 22, 16, 6, (255, 255, 255, 100))

    # Outer thin glossy rim ring
    c.draw_ring(cx, cy, radius - 4, radius - 2, (255, 255, 255, 60))

    return c

def generate_bubbles():
    print("Generating Glossy Jewel Bubbles & Metallic Special Bubble...")
    # Red: Blossom
    make_jewel_bubble((235, 45, 45), (120, 10, 10), (255, 120, 120), 'blossom').save("assets/game/bubbles/bubble_red.png")

    # Blue: Clover / Floral
    make_jewel_bubble((30, 130, 245), (10, 50, 130), (120, 190, 255), 'clover').save("assets/game/bubbles/bubble_blue.png")

    # Green: Leaf / Trefoil
    make_jewel_bubble((45, 195, 75), (15, 90, 30), (130, 240, 150), 'leaf').save("assets/game/bubbles/bubble_green.png")

    # Purple: Star Blossom
    make_jewel_bubble((165, 65, 215), (75, 20, 110), (220, 150, 255), 'star').save("assets/game/bubbles/bubble_purple.png")

    # Yellow: Sunburst
    make_jewel_bubble((250, 195, 25), (140, 95, 0), (255, 235, 120), 'sunflower').save("assets/game/bubbles/bubble_yellow.png")

    # Orange: Floral
    make_jewel_bubble((245, 115, 25), (135, 45, 0), (255, 175, 100), 'floral').save("assets/game/bubbles/bubble_orange.png")

    # Metallic Special Bubble
    c = Canvas(128, 128)
    cx, cy, r = 64, 64, 58
    c.draw_circle(cx, cy, r, (20, 20, 25, 240))
    c.draw_circle(cx, cy, r - 3, (80, 85, 95, 255))

    # Metallic radial shading
    for i in range(int(r - 6), 0, -1):
        t = i / (r - 6)
        icx = cx - (1.0 - t) * 10
        icy = cy - (1.0 - t) * 12
        v = int(40 + t * 90)
        c.draw_circle(icx, icy, i, (v, v + 5, v + 12, 255))

    # Metallic inner ring & mechanical details
    c.draw_ring(cx, cy, 32, 36, (30, 32, 38, 255))
    c.draw_ring(cx, cy, 33, 35, (160, 170, 185, 220))
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 44
        by = cy + math.sin(rad) * 44
        c.draw_circle(bx, by, 3, (200, 210, 225, 255))
        c.draw_circle(bx, by, 1.5, (40, 45, 55, 255))

    # Sharp metallic specular reflection top
    c.draw_ellipse(cx - 16, cy - 20, 22, 10, (240, 245, 255, 220))
    c.draw_ellipse(cx - 18, cy - 22, 12, 5, (255, 255, 255, 255))
    c.save("assets/game/bubbles/bubble_metallic.png")

def generate_shooter():
    print("Generating Shooter Assets...")
    # 1. Shooter Base (Launcher ring platform)
    c = Canvas(256, 256)
    cx, cy = 128, 128
    # Outer gold/emerald ring
    c.draw_circle(cx, cy, 110, (15, 60, 25, 230))
    c.draw_ring(cx, cy, 96, 108, (215, 175, 45, 255))
    c.draw_ring(cx, cy, 98, 106, (255, 225, 100, 255))

    # Inner dark green launcher chamber
    c.draw_circle(cx, cy, 96, (20, 80, 35, 255))
    for r in range(92, 0, -1):
        t = r / 92.0
        v_g = int(35 + t * 65)
        v_b = int(15 + t * 30)
        c.draw_circle(cx, cy, r, (15, v_g, v_b, 255))

    # Gold studs / rivets around base
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        bx = cx + math.cos(rad) * 102
        by = cy + math.sin(rad) * 102
        c.draw_circle(bx, by, 5, (255, 220, 80, 255))
        c.draw_circle(bx - 1, by - 1, 2, (255, 255, 200, 255))

    c.draw_ring(cx, cy, 65, 70, (255, 215, 0, 180))
    c.save("assets/game/shooter/shooter_base.png")

    # 2. Shooter Clover Bubble
    c = Canvas(128, 128)
    # Glossy green bubble with golden clover
    b = make_jewel_bubble((35, 185, 65), (10, 80, 25), (120, 240, 140), 'clover')
    # Add gold clover accent to shooter bubble center
    scx, scy = 64, 66
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        lx = scx + math.cos(rad) * 12
        ly = scy + math.sin(rad) * 12
        b.draw_circle(lx, ly, 13, (255, 215, 0, 220))
        b.draw_circle(lx - 2, ly - 2, 7, (255, 245, 160, 240))
    b.draw_circle(scx, scy, 7, (255, 225, 50, 255))
    b.draw_line(scx, scy + 8, scx, scy + 22, (255, 215, 0, 255), thickness=4)
    b.draw_ellipse(64 - 18, 64 - 22, 20, 10, (255, 255, 255, 210))
    b.save("assets/game/shooter/shooter_clover.png")

def generate_background_and_decorations():
    print("Generating Background & Decoration Assets...")
    # 1. Forest Background (512 x 1024)
    c = Canvas(512, 1024)
    # Deep vertical gradient
    c.fill_v_gradient([
        (10, 32, 12, 255),
        (18, 55, 22, 255),
        (30, 85, 38, 255),
        (22, 65, 28, 255),
        (12, 40, 15, 255)
    ])

    # Layered dark green trees in background
    for i in range(14):
        tx = i * 42 - 20
        c.draw_ellipse(tx, 450, 55, 260, (12, 45, 16, 190))
        c.draw_ellipse(tx + 25, 400, 45, 220, (18, 60, 24, 210))

    # Canopy arches top left and top right
    c.draw_ellipse(80, 60, 220, 140, (14, 50, 20, 230))
    c.draw_ellipse(432, 60, 220, 140, (14, 50, 20, 230))

    # Soft golden sunbeams from top
    for i in range(6):
        c.draw_line(60 + i * 75, 0, 140 + i * 85, 1024, (240, 250, 160, 30), thickness=40)

    c.save("assets/game/backgrounds/forest_background.png")

    # 2. Forest Leaves (256 x 512)
    c = Canvas(256, 512)
    # Large vine branches & leaves hanging down
    c.draw_line(0, 0, 140, 320, (38, 26, 12, 255), thickness=12)
    c.draw_line(120, 100, 220, 260, (38, 26, 12, 255), thickness=8)
    for i in range(10):
        lx = 25 + i * 16
        ly = 25 + i * 30
        c.draw_ellipse(lx + 30, ly, 38, 20, (35, 110, 42, 240))
        c.draw_ellipse(lx + 24, ly - 4, 30, 14, (65, 165, 72, 250))
        c.draw_line(lx, ly, lx + 45, ly, (15, 55, 18, 220), thickness=2)
    c.save("assets/game/decorations/forest_leaves.png")

    # 3. Forest Grass (512 x 256)
    c = Canvas(512, 256)
    for i in range(24):
        c.draw_ellipse(i * 24 - 10, 190, 28, 85, (20, 80, 26, 240))
    for i in range(35):
        gx = i * 16 - 5
        c.draw_line(gx, 256, gx + (i % 3 - 1) * 10, 110 + (i % 5) * 12, (68, 175, 75, 255), thickness=5)

    # Wild flowers
    for fx, fy in [(50, 155), (140, 175), (260, 145), (370, 170), (470, 150)]:
        c.draw_circle(fx, fy, 11, (240, 40, 100, 255))
        c.draw_circle(fx, fy, 4, (255, 235, 50, 255))
    c.save("assets/game/decorations/forest_grass.png")

    # 4. Forest Bushes (512 x 256)
    c = Canvas(512, 256)
    for i in range(8):
        bx = i * 70 - 10
        c.draw_circle(bx, 180, 55, (25, 95, 32, 230))
        c.draw_circle(bx + 20, 160, 42, (45, 135, 52, 240))
        c.draw_circle(bx + 40, 185, 48, (30, 105, 38, 230))
    c.save("assets/game/decorations/forest_bushes.png")

def generate_effects():
    print("Generating Effect Assets...")
    # 1. Aim Dot (64 x 64) - Bright neon green circular dot
    c = Canvas(64, 64)
    cx, cy = 32, 32
    c.draw_circle(cx, cy, 18, (120, 255, 20, 90))
    c.draw_circle(cx, cy, 12, (160, 255, 40, 180))
    c.draw_circle(cx, cy, 7, (230, 255, 180, 255))
    c.save("assets/game/effects/aim_dot.png")

    # 2. Bubble Pop (128 x 128) - Particle pop burst ring
    c = Canvas(128, 128)
    cx, cy = 64, 64
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        px = cx + math.cos(rad) * 36
        py = cy + math.sin(rad) * 36
        c.draw_circle(px, py, 7, (255, 255, 255, 220))
        c.draw_circle(px, py, 4, (120, 255, 150, 255))
    c.draw_ring(cx, cy, 20, 26, (255, 255, 255, 180))
    c.save("assets/game/effects/bubble_pop.png")

    # 3. Sparkle (64 x 64) - 4 point star sparkle
    c = Canvas(64, 64)
    cx, cy = 32, 32
    c.draw_line(cx - 24, cy, cx + 24, cy, (255, 255, 255, 255), thickness=4)
    c.draw_line(cx, cy - 24, cx, cy + 24, (255, 255, 255, 255), thickness=4)
    c.draw_circle(cx, cy, 8, (255, 235, 120, 240))
    c.save("assets/game/effects/sparkle.png")

    # 4. Explosion (128 x 128)
    c = Canvas(128, 128)
    cx, cy = 64, 64
    for i in range(12):
        angle = i * 30
        rad = math.radians(angle)
        ex = cx + math.cos(rad) * 45
        ey = cy + math.sin(rad) * 45
        c.draw_line(cx, cy, ex, ey, (255, 200, 50, 220), thickness=6)
        c.draw_circle(ex, ey, 9, (255, 100, 30, 240))
    c.draw_circle(cx, cy, 22, (255, 245, 180, 255))
    c.save("assets/game/effects/explosion.png")

if __name__ == '__main__':
    generate_bubbles()
    generate_shooter()
    generate_background_and_decorations()
    generate_effects()
    print("ALL 17 GAME ASSETS GENERATED SUCCESSFULLY!")
