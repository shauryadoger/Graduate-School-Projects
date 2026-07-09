from PIL import Image


print("capturing image for confirmation.")
_time = time.strftime("%y-%m-%d_%H-%M-%S", time.localtime())

# Save to a specific location in the repo 
path = "/home/kassandrarodriguez/auto-park-car/photos/"

# Take a picture/frame 
Vilib.take_photo(str(_time), path)
image_path = f"{path}/{_time}.jpg"
print(f"The photo saved as: {image_path}")
    
image = Image.open(image_path)
image.show()
