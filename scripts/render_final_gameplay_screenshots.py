import os
import math
from PIL import Image, ImageDraw, ImageFont

def render_gameplay_screenshot(bg_path, output_filename, theme_type='forest'):
    print(f"Rendering 390x844 gameplay screenshot: {output_filename}...")

    # 1. Load background and resize to exact target 390x844 logical canvas
    if not os.path.exists(bg_path):
        raise FileNotFoundError(f"Background asset not found: {bg_path}")

    bg_img = Image.open(bg_path).convert("RGBA")
    screen = bg_img.resize((390, 844), Image.BICUBIC)

    overlay = Image.new("RGBA", (390, 844), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    # 2. Bubble Grid Layer (Hex grid near top)
    rows = 7
    cols = 8
    bubble_dia = 38
    start_x = (390 - (cols * bubble_dia)) / 2.0  # ~43px offset
    start_y = 100.0

    # Colors for bubbles
    if theme_type == 'forest':
        colors = [
            (235, 45, 45), (30, 130, 245), (45, 195, 75),
            (165, 65, 215), (250, 195, 25)
        ]
    else:
        colors = [
            (30, 160, 240), (240, 70, 120), (50, 210, 150),
            (250, 180, 40), (180, 80, 220)
        ]

    for r in range(rows):
        is_odd = (r % 2 == 1)
        row_cols = cols - 1 if is_odd else cols
        row_start_x = start_x + (bubble_dia / 2.0 if is_odd else 0)
        row_y = start_y + r * (bubble_dia * 0.866)

        for c in range(row_cols):
            cx = row_start_x + c * bubble_dia + bubble_dia / 2.0
            cy = row_y + bubble_dia / 2.0
            rad = bubble_dia / 2.0 - 1

            col_idx = (r * 3 + c * 2) % len(colors)
            bcol = colors[col_idx]

            # 3D spherical bubble
            draw.ellipse([cx-rad, cy-rad, cx+rad, cy+rad], fill=(bcol[0], bcol[1], bcol[2], 255), outline=(255, 255, 255, 180), width=2)
            # Specular highlight
            draw.ellipse([cx-rad*0.5, cy-rad*0.5, cx-rad*0.1, cy-rad*0.1], fill=(255, 255, 255, 220))

    # 3. Cannon Launcher & Active Ready Bubble (Bottom region)
    cannon_cx = 195.0
    cannon_cy = 730.0
    cannon_r = 45.0

    # Cannon Base Ring
    cannon_base_col = (30, 120, 60) if theme_type == 'forest' else (240, 140, 40)
    draw.ellipse([cannon_cx-cannon_r, cannon_cy-cannon_r, cannon_cx+cannon_r, cannon_cy+cannon_r], fill=(cannon_base_col[0], cannon_base_col[1], cannon_base_col[2], 240), outline=(255, 215, 0, 255), width=4)
    draw.ellipse([cannon_cx-cannon_r*0.7, cannon_cy-cannon_r*0.7, cannon_cx+cannon_r*0.7, cannon_cy+cannon_r*0.7], fill=(20, 30, 40, 255))

    # Ready Shooting Bubble in cannon center
    r_col = colors[0]
    draw.ellipse([cannon_cx-16, cannon_cy-16, cannon_cx+16, cannon_cy+16], fill=(r_col[0], r_col[1], r_col[2], 255), outline=(255, 255, 255, 220), width=2)
    draw.ellipse([cannon_cx-10, cannon_cy-10, cannon_cx-4, cannon_cy-4], fill=(255, 255, 255, 240))

    # Aiming trajectory dots
    aim_angle = -math.pi / 2  # Straight up
    for i in range(1, 10):
        dot_x = cannon_cx + math.cos(aim_angle) * (i * 35)
        dot_y = cannon_cy + math.sin(aim_angle) * (i * 35)
        if dot_y > start_y + rows * bubble_dia:
            dot_col = (118, 255, 3, 200) if theme_type == 'forest' else (0, 229, 255, 200)
            draw.ellipse([dot_x-5, dot_y-5, dot_x+5, dot_y+5], fill=dot_col)

    # 4. Top HUD Bar (Level 1, Score 0, Moves 30)
    hud_bg = (15, 35, 25, 220) if theme_type == 'forest' else (10, 45, 80, 220)
    draw.rectangle([10, 40, 380, 85], fill=hud_bg, outline=(255, 215, 0, 200), width=2)

    # Text in HUD
    try:
        font = ImageFont.load_default()
    except:
        font = None

    draw.text((25, 52), "LEVEL 1", fill=(255, 255, 255, 255), font=font)
    draw.text((160, 52), "SCORE: 0", fill=(255, 215, 0, 255), font=font)
    draw.text((290, 52), "MOVES: 30", fill=(100, 255, 150, 255), font=font)

    # 5. Bottom Power-ups Bar (Swap, Bomb, Rainbow, Fire)
    draw.rectangle([10, 785, 380, 835], fill=(10, 20, 30, 220), outline=(255, 255, 255, 100), width=1)
    for p_idx, p_name in enumerate(["SWAP", "BOMB", "RAINBOW", "FIRE"]):
        px = 45 + p_idx * 90
        py = 810
        draw.ellipse([px-18, py-18, px+18, py+18], fill=(40, 60, 80, 255), outline=(255, 215, 0, 200), width=2)
        draw.text((px-12, py-5), p_name[:4], fill=(255, 255, 255, 255), font=font)

    screen = Image.alpha_composite(screen, overlay)
    screen.save(output_filename)
    print(f"Successfully saved {output_filename} at 390x844!")

def main():
    clover_bg = "assets/game/themes/clover_forest/background/forest_background_390x844.png"
    underwater_bg = "assets/game/themes/underwater/background/underwater_background_390x844.png"

    render_gameplay_screenshot(clover_bg, "clover_forest_final.png", theme_type='forest')
    render_gameplay_screenshot(underwater_bg, "underwater_final.png", theme_type='underwater')

if __name__ == '__main__':
    main()
