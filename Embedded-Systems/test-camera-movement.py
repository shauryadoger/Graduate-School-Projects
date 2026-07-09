from picarx import Picarx
import time
from vilib import Vilib

if __name__ == "__main__":
    try:
        px = Picarx()
        
        # Initialize Vilib camera
        Vilib.camera_start(vflip=False,hflip=False)

        Vilib.display(local=True,web=True) 
        
        px.backward(30)
        time.sleep(0.5)
        
        # Scan by turning the camera to the right
        for angle in range(0, 35):
            px.set_camera_servo1_angle(angle)
            time.sleep(0.01)
        
        for angle in range(35, -35, -1):
            px.set_camera_servo1_angle(angle)
            time.sleep(0.01)
        
        for angle in range(-35, 0):
            px.set_camera_servo1_angle(angle)
            time.sleep(0.01)
        
        # Stop the car before tilting the camera
        px.forward(0)
        time.sleep(1)
        
        # Tilt the camera up and down to check the spots
        for angle in range(0, 35):
            px.set_camera_servo2_angle(angle)
            time.sleep(0.01)
        
        for angle in range(35, -35, -1):
            px.set_camera_servo2_angle(angle)
            time.sleep(0.01)
        
        for angle in range(-35, 0):
            px.set_camera_servo2_angle(angle)
            time.sleep(0.01)

    finally:
        # Clean up and reset camera servos to default position
        px.set_camera_servo1_angle(0)
        px.set_camera_servo2_angle(0)
        px.forward(0)
