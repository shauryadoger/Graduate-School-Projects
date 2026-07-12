'''
use laptop as a wifi server
'''
from socket import *
import numpy as np
from time import time, strftime
from numpy import frombuffer, array, savetxt, zeros
import matplotlib.pyplot as plt
from matplotlib.pyplot import subplots, text, Circle, Rectangle, plot
import matplotlib.animation as animation

import csv
from datetime import datetime

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

def locCollector(xc, yc, rect):
    for x in xc:
        for y in yc:
            rect.append(Rectangle((x, y), 0.02, 0.02, fc = 'k'))
    return rect

def locSite(xc, yc, rect):
    for x in xc:
        for y in yc:
            rect.append(Rectangle((x, y), 0.04, 0.04, fc = 'g'))
    return rect

def hline(y0, x1, x2, c = 'k', lw = 3):
    ax1.axhline(y = y0, xmin = x1, xmax = x2, color = c, linewidth = lw)

def vline(x0, y1, y2, c = 'k', lw = 3):
    ax1.axvline(x = x0, ymin = y1, ymax = y2, color = c, linewidth = lw)
    
    
# Create a UDP socket
sock = socket(AF_INET, SOCK_DGRAM)
port = 9990
# Assign IP address and port number to socket
sock.bind(('192.168.0.69', port))
# s.bind(('192.168.1.4', port))
sock.setblocking(False)
print('server bind at ', sock)
BUFFER_SIZE = 1024  
ys = [[-110] * 100]
xs = np.arange(100)

# --- Color Settings ---
SITE_COLOR = '#1f77b4'      # blue
COLLECTOR_COLOR = '#ff7f0e' # orange
ZONE_COLOR = '#2ca02c'      # green
SITE_LABEL_COLOR = '#d62728' # red
RSSI_LABEL_COLOR = '#0173b2' # bright blue
BORDER_COLOR = 'black'
LINE_COLOR = '#8c564b'      # brownish

# Add subplot for the sensor
fig, [ax1, ax2, ax3] = plt.subplots(3, 1, figsize=(24, 36))
sensor_vals = [0]*100
sensor_line = ax3.plot(xs, sensor_vals, color='blue')[0]
ax3.set_xlabel("Sample Index")
ax3.set_ylabel('Obstacle Sensor State\n(0=obstacle, 1=clear)', fontsize=10, color=LINE_COLOR, fontweight='bold', labelpad=18)
ax3.set_ylim(-0.05, 1.05)

fig.patch.set_facecolor('#fafafa') # light background

line1 = ax2.plot(xs, ys[0], color='red', linewidth=2)[0]

# RSSI label left of the box
label1 = ax1.text(0.05, 0.4, str(-200), fontsize=16, color=RSSI_LABEL_COLOR, fontweight='bold', ha='right', va='center')

# --- Draw the map with new colors ---
hline(0.7, 0.1, 0.7, c=BORDER_COLOR, lw=5)
hline(0.1, 0.1, 0.7, c=BORDER_COLOR, lw=5)
hline(0.4, 0.1, 0.7, c=ZONE_COLOR, lw=4)
vline(0.7, 0.1, 0.7, c=BORDER_COLOR, lw=5)
vline(0.1, 0.1, 0.7, c=BORDER_COLOR, lw=5)
vline(0.3, 0.1, 0.7, c=ZONE_COLOR, lw=4)
vline(0.5, 0.1, 0.7, c=ZONE_COLOR, lw=4)

coll = locCollector([0.2, 0.6], [0.1, 0.7], [])
coll = locCollector([0.09, 0.69], [0.39], coll)
for c in coll:
    ax1.add_patch(c)

# Add the data zones
zones = locSite([0.25], [0.6], [])
for z in zones:
    ax1.add_patch(z)

# --- Only Site 1 Label ---
ax1.text(0.25, 0.74, "site 1", fontsize=22, color=SITE_LABEL_COLOR, fontweight='bold', ha='center') # y=0.74 above box

ax1.axis('off')

# --- Axis labels for RSSI plot ---
ax2.set_xlabel('Sample Index', fontsize=18, color=LINE_COLOR, fontweight='bold', labelpad=16)
ax2.set_ylabel('RSSI (dBm)', fontsize=12, color=LINE_COLOR, fontweight='bold', labelpad=16)
ax2.tick_params(axis='x', labelsize=10)
ax2.tick_params(axis='y', labelsize=10)
ax2.set_facecolor('#f5faff') # background for easy contrast

# Create file for RSSI and all other sensor data recordings
csvfile = open('rssi_data.csv', 'w', newline='')
csvwriter = csv.writer(csvfile)
# Write the header row
csvwriter.writerow(['timestamp', 'sample_idx', 'site_id', 'rssi', 'sensor_state', 'behavior'])

def animate(i):
    global ys, xs, sensor_vals

    try:
        data, addr = sock.recvfrom(BUFFER_SIZE)
    except BlockingIOError:
        return label1, line1

    if data:
        buff = np.frombuffer(data, dtype=np.uint8)

        if len(buff) == 4:
            rssi = -int(buff[0])
            site_id = buff[1]*100 + buff[2]
            sensor_val = buff[3]

            # Update label and plots below...

            # --- CSV Logging ---
            #current_behavior = "standing"

            # --- Automatic behavior annotation based on sensor_val ---
            if sensor_val == 0:
                current_behavior = 'obstacle'
            else:
                current_behavior = 'clear'

            #continue putting data from sensors into csv file
            csvwriter.writerow([datetime.now().isoformat(), i, site_id, rssi, sensor_val, current_behavior])
            csvfile.flush()

            label1.set_text(f"{rssi} dBm | site {site_id}")

            # Fill buffer if still initial values
            if ys[0].count(-110) == 100:
                ys[0] = [rssi]*100
                sensor_vals = [sensor_val]*100
            else:
                ys[0] = ys[0][1:] + [rssi]
                sensor_vals = sensor_vals[1:] + [sensor_val]

            line1.set_data(xs, ys[0])
            sensor_line.set_data(xs, sensor_vals)
            ax2.set_ylim(-100, 0)
            ax3.set_ylim(-0.05, 1.05)
            ax2.relim(); ax2.autoscale_view()
            ax3.relim(); ax3.autoscale_view()
        else:
            print("Unexpected packet length:", buff)
            return label1, line1, sensor_line


ani = animation.FuncAnimation(fig, animate, interval = 100, 
                              blit = False, save_count = 50)
ax1.axis('off')  
plt.show()


# ---- Machine Learning analysis (after visualization window gets closed) ----
df = pd.read_csv('rssi_data.csv')

# Feature selection
X = df[['rssi', 'sensor_state', 'site_id']]
y = df['behavior']

y = y.astype('category').cat.codes

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)
clf = RandomForestClassifier()
clf.fit(X_train, y_train)

print('Test accuracy:', clf.score(X_test, y_test))