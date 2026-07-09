import time
from picarx import Picarx


def move_camera_servos(px):
    # Sweep the pan servo 
    for angle in range(-90, 91, 5):
        px.set_cam_pan_angle(angle)
        time.sleep(0.1)
    
    # Return to starting position
    for angle in range(90, -91, -5):  
        px.set_cam_pan_angle(angle)
        time.sleep(0.1)

    # Reset pan position
    px.set_cam_pan_angle(0)

    # Sweep the tilt servo
    for angle in range(-35, 66, 5): 
        px.set_cam_tilt_angle(angle)
        time.sleep(0.1)
    
    # Return to starting position
    for angle in range(65, -36, -5):  
        px.set_cam_tilt_angle(angle)
        time.sleep(0.1)

    # Reset tilt position
    px.set_cam_tilt_angle(0)

if __name__ == "__main__":
    px = None 
    try:
        # Initialize the Picarx
        px = Picarx() 
        
        # Move the camera servos
        move_camera_servos(px)  
    except Exception as e:
        print("An error occurred:", e)
    finally:
        if px:  
            px.stop()  
        print("Operation completed.")
