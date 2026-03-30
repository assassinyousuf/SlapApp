import os
import cv2
import numpy as np
from flask import Flask, request, send_file
import werkzeug

app = Flask(__name__)
os.makedirs('temp', exist_ok=True)

def generate_sad_face(img_path, out_path):
    img = cv2.imread(img_path)
    if img is None:
        return False
        
    h, w = img.shape[:2]
    
    # 1. Melancholic Blue/Grey Desaturation Filter
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    hsv[:,:,1] = (hsv[:,:,1] * 0.4).astype(np.uint8)  # heavily reduce saturation
    img_sad = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    # Add deep blue tint mapping
    blue_overlay = np.full(img_sad.shape, (120, 50, 20), dtype=np.uint8)
    img_sad = cv2.addWeighted(img_sad, 0.7, blue_overlay, 0.3, 0)
    
    # 2. Liquid Phase Warp (Synthetically drooping the face downwards)
    map_x = np.zeros((h, w), np.float32)
    map_y = np.zeros((h, w), np.float32)
    
    for y in range(h):
        for x in range(w):
            # Calculate distance from upper-center of the image
            dx = x - w/2
            dy = y - h/3
            dist = np.sqrt(dx**2 + dy**2)
            
            # Sag intensity is localized around the center where the face sits
            sag = np.exp(-dist / (h/1.5)) * (h * 0.15) # Max sag stretches 15% of height
            
            map_x[y, x] = x
            # Y mapping shifts upward relative to the destination pixel, stretching it downward
            map_y[y, x] = min(h - 1, max(0, y - sag))
            
    img_warped = cv2.remap(img_sad, map_x, map_y, interpolation=cv2.INTER_LINEAR)
    
    cv2.imwrite(out_path, img_warped)
    return True

@app.route('/sad', methods=['POST'])
def process_sad():
    if 'image' not in request.files:
        return 'No image provided', 400
    
    file = request.files['image']
    in_path = os.path.join('temp', 'in.jpg')
    out_path = os.path.join('temp', 'out.jpg')
    
    file.save(in_path)
    success = generate_sad_face(in_path, out_path)
    
    if not success:
        return 'Image processing failed', 500
        
    return send_file(out_path, mimetype='image/jpeg')

if __name__ == '__main__':
    print("Starting AI Facial Deformation Server on port 5000...")
    app.run(host='0.0.0.0', port=5000)
