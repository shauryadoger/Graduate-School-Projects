from picarx import Picarx
import time
from vilib import Vilib

def look_for_parking(px):
    # Drive forward at low speed to scan for parking spots
    px.backward(1)
    try:
        # Scan for an available parking spot
        while True:
            distance = px.ultrasonic.read()
            print("Scanning... Distance: ", distance, "cm")
            
            # if distance is greater than 20 then we found an available spot
            if distance > 20: 
                print("Potential spot detected.")
                px.stop()
                
                # Turn the camera to the right to check the spot
                px.set_cam_pan_angle(95)
                
                # Give camera time to adjust and stream
                time.sleep(1)  
                if Vilib.check_if_spot_is_empty():
                    print("Spot is empty. Proceed to park.")
                    px.stop()
                    break
                else:
                    print("Spot is not empty. Continue scanning.")
                    px.backward(10)
            
            time.sleep(0.5)

    finally:
        # Stop the car and reset the camera position
        px.stop()
        px.set_cam_pan_angle(0)

if __name__ == "__main__":
    try:
        px = Picarx()
        
        # Start camera stream with vilib
        Vilib.camera_start(vflip=False,hflip=False)
        Vilib.display(local=True,web=True) 

        look_for_parking(px)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if px:
            px.stop()  
            px.set_cam_pan_angle(0) 
        print("Operation completed.")
