from picarx import Picarx
import time
from vilib import Vilib
import cv2
import numpy as np
import matplotlib.pyplot as plt


def is_parking_spot_empty(image_path):
    """
        Here we check if the parking spot is empty. We convert the still frame into a HSV format
        so that we can better identify blue spots in the image
    """
    import os
    import cv2
    import numpy as np
    import matplotlib.pyplot as plt

    image = cv2.imread(image_path)
    if image is None:
        print("Error: Image not found or cannot be loaded.")
        return False

    hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    
    # Define the blue color range for masking
    lower_blue = np.array([100, 150, 50])  
    upper_blue = np.array([140, 255, 255])
    mask = cv2.inRange(hsv, lower_blue, upper_blue)

    # Create a kernel for morphological operations
    kernel = np.ones((5, 5), np.uint8)
    
    # Remove small white noise from the mask
    mask_cleaned = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    # Calculate the proportion of the mask that is blue
    coverage_ratio = np.sum(mask_cleaned > 0) / mask_cleaned.size

    # Set up the plot
    plt.figure(figsize=(10, 5))
    plt.subplot(1, 3, 1)
    plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    plt.title('Original Image')
    plt.axis('off')

    plt.subplot(1, 3, 2)
    plt.imshow(mask, cmap='gray')
    plt.title('HSV Mask')
    plt.axis('off')

    plt.subplot(1, 3, 3)
    plt.imshow(mask_cleaned, cmap='gray')
    plt.title('Cleaned Mask')
    plt.axis('off')

    # Save the plot to the same location as the images
    plot_path = os.path.join(os.path.dirname(image_path), 'analysis_plot.png')
    plt.savefig(plot_path)
    plt.close() 

    print(f"Analysis plot saved to {plot_path}")

    return coverage_ratio > 0.05


def confirm_parking_spot(px):
    """
        Here we confirm if the parking spot is available
    """
    right_angle = 90
    down_angle = -20 
    px.set_cam_pan_angle(right_angle)
    px.set_cam_tilt_angle(down_angle)
    
    # Wait for the camera to stabilize
    time.sleep(1)

    # Here we take a frame and save it 
    print("Camera adjusted, capturing image for confirmation.")
    _time = time.strftime("%y-%m-%d_%H-%M-%S", time.localtime())
    path = "/home/kassandrarodriguez/auto-park-car/photos/"
    Vilib.take_photo(str(_time), path)
    image_path = f"{path}/{_time}.jpg"
    print(f"The photo saved as: {image_path}")

    if is_parking_spot_empty(image_path):
        print("The parking spot is empty.")
        
        # Drive into the parking spot
        px.forward(speed=2)
        time.sleep(0.4)
        
        # Steer right
        px.set_dir_servo_angle(25)
        time.sleep(0.5)
        px.backward(speed=2)
        
        # Allows us time to drive into the parking spot
        time.sleep(4)
        px.stop()
        
        # Reset steering angle
        px.set_dir_servo_angle(0) 
    else:
        print("The parking spot is not empty.")

def find_parking_spot(px, distance_threshold):
    """ Here we use the ultrasonic sensor to continuously search for a threshold greater that 20
        Drive forward = px.backward
        Drive backward = px.forward
    """
    
    # We move backward because for some reason backward is actually forward
    px.backward(speed=1)
    try:
        while True:
            distance = px.ultrasonic.read()
            if distance > distance_threshold:
                print("Potential empty spot detected.")
                
                # Stop the car
                px.backward(0)  
                confirm_parking_spot(px)
                break
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("Manual interruption.")
    finally:
        px.stop()
        print("Finished scanning for parking spots.")

if __name__ == "__main__":
    px = Picarx()
    Vilib.camera_start(vflip=False, hflip=False)
    Vilib.display(local=True, web=True)
    
    # Adding a terminal-based GUI interaction
    print("Press ENTER to start the parking detection or 'Q' to quit.")
    
    # Get user input
    user_input = input("Input: ").strip().upper()
    
    if user_input == 'Q':
        print("Exiting program.")
        Vilib.camera_close()
        exit(0)
    
    print("Starting parking detection...")
    try:
        distance_threshold = 20
        find_parking_spot(px, distance_threshold)
    finally:
        px.set_cam_pan_angle(0)
        px.set_cam_tilt_angle(0)
        px.stop()
        Vilib.camera_close()
        print("Program has ended.")

