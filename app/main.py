# app/main.py (FastAPI example)

from fastapi import FastAPI, Request
import joblib
import os
import csv
import pandas as pd
import subprocess
from pydantic import BaseModel

app = FastAPI()

# Load model
model = joblib.load("models/iris_model.pkl")

class IrisFeatures(BaseModel):
    SepalLength: float
    SepalWidth: float
    PetalLength: float
    PetalWidth: float

LIVE_INPUT_FILE = "live_inputs.csv"

# Ensure the CSV file has headers if not present
if not os.path.exists(LIVE_INPUT_FILE):
    with open(LIVE_INPUT_FILE, mode="a", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["SepalLength","SepalWidth","PetalLength","PetalWidth"])  # headers

@app.post("/predict")
async def predict(request: Request, features: IrisFeatures):
    # Convert input features to list
    input_row = [
        features.SepalLength,
        features.SepalWidth,
        features.PetalLength,
        features.PetalWidth
    ]

    # Append to live_inputs.csv
    with open(LIVE_INPUT_FILE, mode="a", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(input_row)
    
    print(f"Logged input: {input_row}")  # ✅ This will show in Render logs
    
    # Trigger the shell script
    try:
        subprocess.run(["bash", "push_live_inputs.sh"], check=True)
        print("✅ push_live_inputs.sh triggered successfully")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error triggering push_live_inputs.sh: {e}")
    
    # Make prediction
    prediction = model.predict([input_row])

    return {
        "input": {
            "SepalLength": features.SepalLength,
            "SepalWidth": features.SepalWidth,
            "PetalLength": features.PetalLength,
            "PetalWidth": features.PetalWidth,
        },
        "prediction": prediction[0]
    }
