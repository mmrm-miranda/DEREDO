from PIL import Image

def center_image(image_path):
    # Open image
    img = Image.open(image_path).convert("RGBA")
    
    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if not bbox:
        print("Image is completely transparent.")
        return
        
    # Crop to the exact contents
    cropped = img.crop(bbox)
    
    # Calculate new square size with more padding (adaptive icons need more padding)
    max_dim = max(cropped.width, cropped.height)
    new_size = int(max_dim * 1.4) # More padding
    
    # Create new transparent square canvas
    new_img = Image.new("RGBA", (new_size, new_size), (255, 255, 255, 0))
    
    # Calculate centered position
    paste_x = (new_size - cropped.width) // 2
    paste_y = (new_size - cropped.height) // 2
    
    # Shift upwards to fix visual bottom-heaviness
    paste_y -= int(new_size * 0.03) 
    
    # Paste exactly
    new_img.paste(cropped, (paste_x, paste_y), cropped)
    
    # Save over the old image
    new_img.save(image_path)
    print("Image successfully centered and padded!")

if __name__ == "__main__":
    center_image("assets/deredo.png")
