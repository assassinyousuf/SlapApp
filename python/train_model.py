import os
import glob
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Constants
TIMESTEPS = 100 # 2 seconds at 50Hz
FEATURES = 6    # ax, ay, az, gx, gy, gz
CLASSES = ['slap', 'hit', 'drop', 'shake', 'idle']
MODEL_DIR = "../assets/models"

def parse_csv(file_path):
    df = pd.read_csv(file_path)
    # Expected: ax, ay, az, gx, gy, gz, label (or timestamp, label)
    # We only care about the 6 sensor features and the label
    features = df[['ax', 'ay', 'az', 'gx', 'gy', 'gz']].values
    label_str = df['label'].iloc[-1].lower() if 'label' in df.columns else 'idle'
    label_idx = CLASSES.index(label_str) if label_str in CLASSES else 4
    
    return features, label_idx

def load_data(dataset_dir):
    csv_files = glob.glob(os.path.join(dataset_dir, '*.csv'))
    
    X, y = [], []
    for file in csv_files:
        features, label = parse_csv(file)
        
        # Zero pad or truncate to TIMESTEPS
        if len(features) < TIMESTEPS:
            pad = np.zeros((TIMESTEPS - len(features), FEATURES))
            features = np.vstack([pad, features])
        elif len(features) > TIMESTEPS:
            features = features[-TIMESTEPS:]
            
        X.append(features)
        y.append(label)
        
    X = np.array(X)
    y = tf.keras.utils.to_categorical(np.array(y), num_classes=len(CLASSES))
    return X, y

def build_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(TIMESTEPS, FEATURES)),
        tf.keras.layers.Conv1D(filters=32, kernel_size=3, activation='relu'),
        tf.keras.layers.MaxPooling1D(pool_size=2),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Conv1D(filters=64, kernel_size=3, activation='relu'),
        tf.keras.layers.MaxPooling1D(pool_size=2),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(len(CLASSES), activation='softmax')
    ])
    
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

if __name__ == '__main__':
    print("Loading dataset...")
    # Assume dataset is in parent dir under /dataset
    dataset_path = os.path.join("..", "dataset")
    
    # Check if dataset exists, if not generate dummy data to show pipeline
    if not os.path.exists(dataset_path) or len(glob.glob(f"{dataset_path}/*.csv")) == 0:
        print("No CSV dataset found! Training with dummy data to generate TFLite model.")
        X = np.random.rand(50, TIMESTEPS, FEATURES).astype(np.float32)
        y = tf.keras.utils.to_categorical(np.random.randint(0, len(CLASSES), 50), num_classes=len(CLASSES))
    else:
        X, y = load_data(dataset_path)
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("Normalizing...")
    scaler = StandardScaler()
    # Flatten -> scale -> reshape
    X_train_flat = X_train.reshape(-1, FEATURES)
    X_test_flat = X_test.reshape(-1, FEATURES)
    
    X_train = scaler.fit_transform(X_train_flat).reshape(-1, TIMESTEPS, FEATURES)
    X_test = scaler.transform(X_test_flat).reshape(-1, TIMESTEPS, FEATURES)
    
    print("Building and training 1D CNN...")
    model = build_model()
    model.summary()
    
    model.fit(X_train, y_train, epochs=10, batch_size=16, validation_data=(X_test, y_test))
    
    print("Saving Keras model...")
    os.makedirs(MODEL_DIR, exist_ok=True)
    h5_path = os.path.join(MODEL_DIR, "slap_model.h5")
    model.save(h5_path)
    
    print("Converting to TensorFlow Lite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    tflite_path = os.path.join(MODEL_DIR, "slap_model.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
        
    print(f"Saved TFLite model to {tflite_path}. Done!")
