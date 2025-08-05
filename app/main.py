# app/main.py (FastAPI example)

from fastapi import FastAPI
import joblib
from pydantic import BaseModel

app = FastAPI()

# Load model
model = joblib.load("models/iris_model.pkl")

class IrisFeatures(BaseModel):
    sepal_length: float
    sepal_width: float
    petal_length: float
    petal_width: float

@app.post("/predict")
def predict(features: IrisFeatures):
    data = [[
        features.sepal_length,
        features.sepal_width,
        features.petal_length,
        features.petal_width
    ]]
    prediction = model.predict(data)
    return {"prediction": prediction[0]}