from picarx import Picarx
import time
from vilib import Vilib



def is_parking_spot_empty(image_path):
    """Here we will include image processing logic later!"""
    return None

def confirm_parking_spot(px):
    """
    Confirm there's a parking spot by turning the camera right
    and potentially using the camera feed for confirmation.
    """
    # Angle to turn camera to the right; adjust based on your setup
    right_angle = 85
    px.set_cam_pan_angle(right_angle)
    time.sleep(1)  # Wait for a moment to stabilize the camera
    
    # Insert logic here to use the camera feed for final confirmation
    
    print("Potential empty spot detected. Capturing image for confirmation.")
    # Stop the car if a spot is detected
    px.stop()  
    _time = time.strftime("%y-%m-%d_%H-%M-%S", time.localtime())
    path = "/home/kassandrarodriguez/auto-park-car/photos/"
    Vilib.take_photo(str(_time), path)
    image_path = f"{path}/{_time}.jpg"
    print(f"The photo saved as: {image_path}")

    if is_parking_spot_empty(image_path):
        print("The parking spot is empty.")
    else:
        print("The parking spot is not empty.")
        
        return

def find_parking_spot(px, distance_threshold):
    # Move forward at a slow speed
    px.backward(speed=1)  
    try:
        while True:
            # Get the distance reading
            distance = px.ultrasonic.read() 
            print(f"Distance: {distance} cm")
            if distance > distance_threshold:
                print("Potential empty spot detected.")
                
                # Stop the car
                px.backward(0)
                confirm_parking_spot(px)
                break
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("Manual interruption. Stopping the car.")
    finally:
        px.stop()
        print("Finished scanning for parking spots.")

if __name__ == "__main__":
    try:
        px = Picarx()
        
        # Initialize the camera
        Vilib.camera_start(vflip=False, hflip=False)
        Vilib.display(local=True, web=True)
        
        # Define the threshold for detecting a parking spot
        # Anything greater than 20 means that the spot might empty
        distance_threshold = 20
        
        find_parking_spot(px, distance_threshold)
        
    finally:
        # Clean up and reset camera servos to default position
        px.set_cam_pan_angle(0)
        
        # Stop the car
        px.backward(0)
        
        # Turn off the camera when done
        Vilib.camera_close()
