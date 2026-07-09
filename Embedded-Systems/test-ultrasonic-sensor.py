from picarx import Picarx
import time

def test_ultrasonic_sensor():
    # Initialize the Picarx
    px = Picarx()  
    try:
        while True:
            # Read the distance measurement from the ultrasonic sensor
            distance = px.ultrasonic.read() 
            print(f"Distance: {distance} cm") 
            
            #  Wait for 1 second before the next read 
            time.sleep(1) 
    except KeyboardInterrupt:
        print("Stopping ultrasonic sensor test.")
    finally:
        px.stop() 
        print("GPIO pins have been cleaned up.")

if __name__ == "__main__":
    test_ultrasonic_sensor()
