# app/main.py (FastAPI example)

from fastapi import FastAPI, Request
import joblib
import os
import csv
import pandas as pd
from pydantic import BaseModel

app = FastAPI()

# Load model
model = joblib.load("models/iris_model.pkl")

class IrisFeatures(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float

LIVE_INPUT_FILE = "live_inputs.csv"

# Ensure the CSV file has headers if not present
if not os.path.exists(LIVE_INPUT_FILE):
    with open(LIVE_INPUT_FILE, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["sepal_length", "sepal_width", "petal_length", "petal_width"])  # headers


@app.post("/predict")
async def predict(request: Request, features: IrisFeatures):
    # Convert input features to list
    input_row = [
        features.sepal_length,
        features.sepal_width,
        features.petal_length,
        features.petal_width
    ]

    # Append to live_inputs.csv
    with open(LIVE_INPUT_FILE, mode="a", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(input_row)

    # Make prediction
    prediction = model.predict([input_row])

    return {
        "input": {
            "sepal_length": features.sepal_length,
            "sepal_width": features.sepal_width,
            "petal_length": features.petal_length,
            "petal_width": features.petal_width,
        },
        "prediction": prediction[0]
    }
