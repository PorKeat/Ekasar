from PIL import Image

# Load the original image
img = Image.open("/Users/alexkgm/.gemini/antigravity/brain/8428a6d1-c6d6-4de1-b54b-a1351946e669/ekasar_logo_1784207644260.jpg")
width, height = img.size

# The mockup icon is usually in the center. Let's crop a tight 540x540 square.
crop_size = 560
left = (width - crop_size) // 2
top = (height - crop_size) // 2
right = left + crop_size
bottom = top + crop_size

cropped = img.crop((left, top, right, bottom))
cropped = cropped.resize((1024, 1024), Image.Resampling.LANCZOS)
cropped.save("assets/icon.png")
print("Cropped and saved to assets/icon.png")
