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
        # colors: list of (r,g,b,a)
        n = len(colors)
        for y in range(self.h):
            pos = y / (self.h - 1) * (n - 1)
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
        min_x = max(0, int(cx - radius - 1))
        max_x = min(self.w, int(cx + radius + 2))
        min_y = max(0, int(cy - radius - 1))
        max_y = min(self.h, int(cy + radius + 2))
        r2 = radius * radius
        for y in range(min_y, max_y):
            dy = y - cy
            for x in range(min_x, max_x):
                dx = x - cx
                d2 = dx*dx + dy*dy
                if d2 <= r2:
                    if d2 > (radius - 1) * (radius - 1):
                        edge_a = int(a * max(0.0, (radius - math.sqrt(d2))))
                        self.blend_pixel(x, y, r, g, b, edge_a)
                    else:
                        self.blend_pixel(x, y, r, g, b, a)

    def draw_ellipse(self, cx, cy, rx, ry, color):
        r, g, b, a = color
        min_x = max(0, int(cx - rx - 1))
        max_x = min(self.w, int(cx + rx + 2))
        min_y = max(0, int(cy - ry - 1))
        max_y = min(self.h, int(cy + ry + 2))
        for y in range(min_y, max_y):
            dy = (y - cy) / max(1, ry)
            for x in range(min_x, max_x):
                dx = (x - cx) / max(1, rx)
                d2 = dx*dx + dy*dy
                if d2 <= 1.0:
                    self.blend_pixel(x, y, r, g, b, a)

    def draw_rect(self, x1, y1, w, h, color):
        r, g, b, a = color
        for y in range(int(y1), int(y1 + h)):
            for x in range(int(x1), int(x1 + w)):
                self.blend_pixel(x, y, r, g, b, a)

    def draw_line(self, x1, y1, x2, y2, color, thickness=1):
        dist = math.hypot(x2 - x1, y2 - y1)
        steps = max(1, int(dist * 2))
        r, g, b, a = color
        for i in range(steps + 1):
            t = i / steps
            cx = x1 + (x2 - x1) * t
            cy = y1 + (y2 - y1) * t
            self.draw_circle(cx, cy, thickness / 2.0, color)

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


def build_forest():
    print("Building Forest assets...")
    # 1. Sky
    c = Canvas(512, 1024)
    c.fill_v_gradient([(12, 40, 15, 255), (25, 75, 30, 255), (45, 120, 50, 255)])
    c.save("assets/themes/forest/background/sky.png")

    # 2. Distant Forest
    c = Canvas(512, 1024)
    # Layer 1 distant tree silhouettes
    for i in range(12):
        cx = i * 45 - 20
        c.draw_ellipse(cx, 600, 50, 250, (15, 50, 20, 180))
        c.draw_ellipse(cx + 20, 550, 40, 200, (20, 65, 25, 200))
    # Layer 2 closer distant tree tops
    for i in range(15):
        cx = i * 38 - 10
        c.draw_circle(cx, 750, 60, (25, 80, 32, 220))
    c.save("assets/themes/forest/background/distant_forest.png")

    # 3. Midground (Sunbeams & canopy arch)
    c = Canvas(512, 1024)
    # Sunbeams
    for i in range(5):
        c.draw_line(100 + i * 70, 0, 180 + i * 80, 1024, (240, 250, 180, 35), thickness=35)
    # Arch canopy top
    c.draw_ellipse(100, 50, 220, 120, (20, 70, 25, 230))
    c.draw_ellipse(412, 50, 220, 120, (20, 70, 25, 230))
    c.save("assets/themes/forest/background/forest_midground.png")

    # 4. Left Leaves
    c = Canvas(256, 512)
    c.draw_line(0, 0, 120, 300, (45, 30, 15, 255), thickness=10)
    for i in range(8):
        lx = 20 + i * 14
        ly = 30 + i * 32
        c.draw_ellipse(lx + 25, ly, 35, 18, (46, 125, 50, 240))
        c.draw_ellipse(lx + 20, ly - 5, 28, 12, (76, 175, 80, 250))
        c.draw_line(lx, ly, lx + 45, ly, (20, 60, 20, 200), thickness=2)
    c.save("assets/themes/forest/decorations/left_leaves.png")

    # 5. Right Leaves
    c = Canvas(256, 512)
    c.draw_line(256, 0, 136, 300, (45, 30, 15, 255), thickness=10)
    for i in range(8):
        lx = 236 - (20 + i * 14)
        ly = 30 + i * 32
        c.draw_ellipse(lx - 25, ly, 35, 18, (46, 125, 50, 240))
        c.draw_ellipse(lx - 20, ly - 5, 28, 12, (76, 175, 80, 250))
        c.draw_line(lx, ly, lx - 45, ly, (20, 60, 20, 200), thickness=2)
    c.save("assets/themes/forest/decorations/right_leaves.png")

    # 6. Bottom Grass & Flowers
    c = Canvas(512, 256)
    # Grass ground
    for i in range(20):
        c.draw_ellipse(i * 28 - 10, 200, 30, 80, (27, 94, 32, 240))
    for i in range(30):
        gx = i * 18 - 5
        c.draw_line(gx, 256, gx + (i % 3 - 1) * 8, 120 + (i % 5) * 10, (76, 175, 80, 255), thickness=4)
    # Flowers
    for fx, fy in [(60, 160), (160, 180), (280, 150), (380, 175), (460, 155)]:
        c.draw_circle(fx, fy, 12, (233, 30, 99, 255))
        c.draw_circle(fx, fy, 5, (255, 235, 59, 255))
    c.save("assets/themes/forest/decorations/bottom_grass.png")


def build_ocean():
    print("Building Ocean assets...")
    # 1. Sky / Water Deep Gradient
    c = Canvas(512, 1024)
    c.fill_v_gradient([(0, 47, 108, 255), (1, 87, 155, 255), (2, 136, 209, 255), (3, 169, 244, 255)])
    c.save("assets/themes/ocean/background/underwater_sky.png")

    # 2. Distant Rocks
    c = Canvas(512, 1024)
    for i in range(6):
        rx = i * 100 - 20
        c.draw_ellipse(rx, 750, 70, 300, (1, 45, 85, 200))
    c.save("assets/themes/ocean/background/distant_rocks.png")

    # 3. Midground Light Rays & Bubbles
    c = Canvas(512, 1024)
    for i in range(6):
        c.draw_line(80 + i * 65, 0, 140 + i * 75, 1024, (128, 222, 234, 40), thickness=30)
    for bx, by, br in [(100, 300, 10), (220, 500, 14), (380, 250, 8), (420, 600, 12), (180, 800, 15)]:
        c.draw_circle(bx, by, br, (255, 255, 255, 100))
        c.draw_circle(bx - br*0.3, by - br*0.3, br*0.3, (255, 255, 255, 200))
    c.save("assets/themes/ocean/background/underwater_midground.png")

    # 4. Left Rocks
    c = Canvas(256, 512)
    c.draw_ellipse(30, 256, 70, 280, (2, 60, 110, 240))
    # Seaweed & coral on rock
    c.draw_ellipse(60, 380, 25, 45, (156, 39, 176, 230))
    for i in range(5):
        c.draw_line(70 + i*6, 500, 80 + i*8, 350 - i*15, (0, 200, 150, 220), thickness=5)
    c.save("assets/themes/ocean/decorations/rocks_left.png")

    # 5. Right Rocks
    c = Canvas(256, 512)
    c.draw_ellipse(226, 256, 70, 280, (2, 60, 110, 240))
    c.draw_ellipse(196, 350, 30, 50, (233, 30, 99, 230))
    for i in range(5):
        c.draw_line(186 - i*6, 500, 176 - i*8, 360 - i*12, (0, 200, 150, 220), thickness=5)
    c.save("assets/themes/ocean/decorations/rocks_right.png")

    # 6. Seabed
    c = Canvas(512, 256)
    # Sand
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (224, 180, 110, 240), (195, 145, 80, 255)])
    # Corals & Starfish
    for cx, cy, cr, col in [(80, 180, 25, (244, 67, 54, 255)), (180, 190, 20, (255, 152, 0, 255)), (340, 175, 30, (233, 30, 99, 255)), (440, 185, 22, (156, 39, 176, 255))]:
        c.draw_circle(cx, cy, cr, col)
    # Starfish
    c.draw_circle(250, 210, 14, (255, 87, 34, 255))
    c.save("assets/themes/ocean/decorations/seabed.png")


def build_candy():
    print("Building Candy assets...")
    # 1. Sky
    c = Canvas(512, 1024)
    c.fill_v_gradient([(74, 0, 40, 255), (136, 14, 79, 255), (194, 24, 91, 255), (244, 143, 177, 255)])
    c.save("assets/themes/candy/background/candy_sky.png")

    # 2. Chocolate Hills
    c = Canvas(512, 1024)
    for i in range(5):
        c.draw_ellipse(i * 120 - 10, 750, 90, 200, (93, 64, 55, 220))
        c.draw_ellipse(i * 120 + 40, 720, 70, 160, (141, 110, 99, 200))
    c.save("assets/themes/candy/background/chocolate_hills.png")

    # 3. Midground Candy Castle
    c = Canvas(512, 1024)
    # Castle silhouette in center
    c.draw_rect(206, 500, 100, 150, (255, 128, 171, 220))
    c.draw_circle(256, 470, 30, (255, 64, 129, 250))
    c.draw_circle(210, 520, 20, (244, 143, 177, 240))
    c.draw_circle(302, 520, 20, (244, 143, 177, 240))
    c.save("assets/themes/candy/background/candy_midground.png")

    # 4. Left Lollipops
    c = Canvas(256, 512)
    # Stick
    c.draw_line(60, 150, 60, 450, (255, 255, 255, 255), thickness=12)
    # Swirl head
    c.draw_circle(60, 150, 45, (233, 30, 99, 255))
    c.draw_circle(60, 150, 35, (255, 255, 255, 255))
    c.draw_circle(60, 150, 25, (255, 193, 7, 255))
    c.draw_circle(60, 150, 12, (233, 30, 99, 255))
    c.save("assets/themes/candy/decorations/left_lollipops.png")

    # 5. Right Lollipops
    c = Canvas(256, 512)
    c.draw_line(196, 150, 196, 450, (255, 255, 255, 255), thickness=12)
    c.draw_circle(196, 150, 45, (156, 39, 176, 255))
    c.draw_circle(196, 150, 35, (255, 255, 255, 255))
    c.draw_circle(196, 150, 25, (3, 169, 244, 255))
    c.draw_circle(196, 150, 12, (156, 39, 176, 255))
    c.save("assets/themes/candy/decorations/right_lollipops.png")

    # 6. Bottom Candy
    c = Canvas(512, 256)
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (248, 187, 208, 230), (240, 98, 146, 255)])
    for i in range(12):
        c.draw_ellipse(i*45, 170, 15, 8, (255, 255, 255, 255))
    c.save("assets/themes/candy/decorations/bottom_candy.png")


def build_galaxy():
    print("Building Galaxy assets...")
    # 1. Sky Space
    c = Canvas(512, 1024)
    c.fill_v_gradient([(18, 0, 94, 255), (49, 27, 146, 255), (81, 45, 168, 255), (103, 58, 183, 255)])
    c.save("assets/themes/galaxy/background/space_sky.png")

    # 2. Distant Stars
    c = Canvas(512, 1024)
    import random
    rng = random.Random(42)
    for _ in range(80):
        sx = rng.randint(0, 511)
        sy = rng.randint(0, 1023)
        sr = rng.randint(1, 3)
        sa = rng.randint(150, 255)
        c.draw_circle(sx, sy, sr, (255, 255, 255, sa))
    c.save("assets/themes/galaxy/background/distant_stars.png")

    # 3. Midground Nebula & Ringed Planet
    c = Canvas(512, 1024)
    # Nebula glow
    c.draw_ellipse(256, 300, 200, 100, (0, 229, 255, 60))
    c.draw_ellipse(256, 300, 140, 70, (224, 64, 251, 80))
    # Planet
    c.draw_circle(380, 220, 45, (103, 58, 183, 240))
    c.draw_ellipse(380, 220, 70, 12, (0, 229, 255, 200))
    c.save("assets/themes/galaxy/background/galaxy_midground.png")

    # 4. Left Asteroid
    c = Canvas(256, 512)
    c.draw_ellipse(40, 256, 50, 180, (48, 63, 159, 240))
    c.draw_circle(50, 200, 15, (0, 229, 255, 220))
    c.draw_circle(45, 300, 18, (179, 136, 255, 220))
    c.save("assets/themes/galaxy/decorations/left_asteroid.png")

    # 5. Right Asteroid
    c = Canvas(256, 512)
    c.draw_ellipse(216, 256, 50, 180, (48, 63, 159, 240))
    c.draw_circle(206, 220, 18, (0, 229, 255, 220))
    c.draw_circle(210, 320, 15, (179, 136, 255, 220))
    c.save("assets/themes/galaxy/decorations/right_asteroid.png")

    # 6. Bottom Cosmic Ground
    c = Canvas(512, 256)
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (49, 27, 146, 220), (18, 0, 94, 255)])
    for x in range(0, 512, 32):
        c.draw_line(x, 180, x, 256, (0, 229, 255, 120), thickness=2)
    c.draw_line(0, 180, 512, 180, (0, 229, 255, 200), thickness=3)
    c.save("assets/themes/galaxy/decorations/bottom_cosmic.png")


def build_fairy():
    print("Building Fairy assets...")
    # 1. Sky
    c = Canvas(512, 1024)
    c.fill_v_gradient([(38, 0, 77, 255), (74, 20, 140, 255), (123, 31, 162, 255), (171, 71, 188, 255)])
    c.save("assets/themes/fairy/background/fairy_sky.png")

    # 2. Distant Castle
    c = Canvas(512, 1024)
    c.draw_rect(216, 600, 80, 140, (74, 20, 140, 220))
    c.draw_circle(256, 570, 25, (225, 190, 231, 240))
    c.save("assets/themes/fairy/background/distant_castle.png")

    # 3. Midground Glowing Mushrooms
    c = Canvas(512, 1024)
    # Glowing particles
    for mx, my in [(100, 400), (400, 350), (250, 500)]:
        c.draw_circle(mx, my, 20, (255, 215, 0, 100))
        c.draw_circle(mx, my, 8, (255, 255, 255, 200))
    c.save("assets/themes/fairy/background/fairy_midground.png")

    # 4. Left Tree
    c = Canvas(256, 512)
    c.draw_line(0, 50, 80, 350, (74, 20, 140, 240), thickness=14)
    c.draw_circle(80, 350, 35, (225, 190, 231, 220))
    c.draw_circle(60, 250, 25, (234, 128, 252, 220))
    c.save("assets/themes/fairy/decorations/left_magical_tree.png")

    # 5. Right Tree
    c = Canvas(256, 512)
    c.draw_line(256, 50, 176, 350, (74, 20, 140, 240), thickness=14)
    c.draw_circle(176, 350, 35, (225, 190, 231, 220))
    c.draw_circle(196, 250, 25, (234, 128, 252, 220))
    c.save("assets/themes/fairy/decorations/right_magical_tree.png")

    # 6. Bottom Flowers
    c = Canvas(512, 256)
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (123, 31, 162, 220), (74, 20, 140, 255)])
    for fx, fy in [(70, 180), (170, 195), (270, 175), (370, 190), (450, 180)]:
        c.draw_circle(fx, fy, 15, (255, 215, 0, 240))
        c.draw_circle(fx, fy, 6, (255, 255, 255, 255))
    c.save("assets/themes/fairy/decorations/bottom_glowing_flowers.png")


def build_winter():
    print("Building Winter assets...")
    # 1. Sky
    c = Canvas(512, 1024)
    c.fill_v_gradient([(0, 54, 58, 255), (0, 96, 100, 255), (0, 151, 167, 255), (128, 222, 234, 255)])
    c.save("assets/themes/winter/background/winter_sky.png")

    # 2. Ice Mountains
    c = Canvas(512, 1024)
    for i in range(4):
        mx = i * 140 - 20
        c.draw_ellipse(mx, 700, 80, 220, (178, 235, 242, 200))
        c.draw_ellipse(mx + 40, 680, 60, 180, (255, 255, 255, 220))
    c.save("assets/themes/winter/background/ice_mountains.png")

    # 3. Midground Pines
    c = Canvas(512, 1024)
    for i in range(7):
        px = i * 80 - 10
        c.draw_ellipse(px, 780, 35, 120, (0, 96, 100, 230))
        c.draw_circle(px, 720, 25, (224, 247, 250, 240))
    c.save("assets/themes/winter/background/winter_midground.png")

    # 4. Left Pines
    c = Canvas(256, 512)
    c.draw_line(0, 0, 70, 300, (60, 90, 100, 255), thickness=12)
    c.draw_ellipse(70, 250, 45, 25, (224, 247, 250, 250))
    c.draw_ellipse(50, 180, 40, 20, (255, 255, 255, 250))
    c.save("assets/themes/winter/decorations/left_ice_pines.png")

    # 5. Right Pines
    c = Canvas(256, 512)
    c.draw_line(256, 0, 186, 300, (60, 90, 100, 255), thickness=12)
    c.draw_ellipse(186, 250, 45, 25, (224, 247, 250, 250))
    c.draw_ellipse(206, 180, 40, 20, (255, 255, 255, 250))
    c.save("assets/themes/winter/decorations/right_ice_pines.png")

    # 6. Bottom Snow
    c = Canvas(512, 256)
    c.fill_v_gradient([(0,0,0,0), (0,0,0,0), (224, 247, 250, 230), (255, 255, 255, 255)])
    for i in range(15):
        c.draw_ellipse(i * 36, 175, 22, 10, (255, 255, 255, 255))
    c.save("assets/themes/winter/decorations/bottom_snow.png")


if __name__ == '__main__':
    build_forest()
    build_ocean()
    build_candy()
    build_galaxy()
    build_fairy()
    build_winter()
    try:
        import generate_reference_portrait_backgrounds
        generate_reference_portrait_backgrounds.main()
    except Exception as e:
        print(f"Warning: Could not run generate_reference_portrait_backgrounds: {e}")
    print("ALL 36 THEME ASSETS GENERATED SUCCESSFULLY!")
