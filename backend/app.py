from flask import Flask, jsonify, request
from flask_cors import CORS
import pandas as pd
import joblib
import numpy as np
import logging
import os
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Global variable to store the model
model = None

def load_model():
    """Load the AI model from the models directory"""
    global model
    model_path = os.path.join('models', 'ai_model.pkl')
    
    try:
        if os.path.exists(model_path):
            model = joblib.load(model_path)
            logger.info("Model loaded successfully for prediction.")
            return True
        else:
            logger.warning(f"Model file not found at {model_path}")
            return False
    except Exception as e:
        logger.error(f"Failed to load model: {str(e)}")
        return False

# Load model on startup
load_model()

# In-memory storage for water intake data
water_data = []

@app.route('/')
def home():
    return jsonify({'message': 'Water Health Monitor API', 'status': 'running'})

@app.route('/health')
def health_check():
    model_status = "loaded" if model is not None else "not loaded"
    return jsonify({
        'status': 'healthy',
        'model_status': model_status,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/data-preview')
def data_preview():
    return jsonify({'message': 'Dataset preview endpoint', 'status': 'available'})

@app.route('/predict', methods=['POST'])
def predict():
    """Predict water quality using the trained AI model"""
    
    if model is None:
        return jsonify({
            'error': 'Model not loaded',
            'message': 'AI model is not available for predictions'
        }), 500
    
    try:
        # Get JSON data from request
        data = request.get_json()
        
        if not data:
            return jsonify({
                'error': 'No input data',
                'message': 'Please provide JSON input data'
            }), 400
        
        logger.info("Received input data for prediction.")
        
        # Required features for the model
        required_features = [
            'ph', 'hardness', 'solids', 'chloramines', 'sulfate',
            'conductivity', 'organic_carbon', 'trihalomethanes', 'turbidity'
        ]
        
        # Validate input features
        missing_features = [f for f in required_features if f not in data]
        if missing_features:
            return jsonify({
                'error': 'Missing features',
                'message': f'Missing required features: {missing_features}',
                'required_features': required_features
            }), 400
        
        # Convert to DataFrame
        input_df = pd.DataFrame([data])
        
        # Make prediction
        prediction = model.predict(input_df)[0]
        prediction_proba = model.predict_proba(input_df)[0]
        
        # Get confidence (probability of predicted class)
        confidence = max(prediction_proba)
        
        # Convert prediction to readable format
        result = "Safe" if prediction == 1 else "Unsafe"
        
        logger.info(f"Prediction result: {result} (Confidence: {confidence:.2f})")
        
        return jsonify({
            'prediction': result,
            'confidence': round(confidence, 4),
            'probabilities': {
                'unsafe': round(prediction_proba[0], 4),
                'safe': round(prediction_proba[1], 4)
            },
            'input_features': data
        })
        
    except ValueError as e:
        return jsonify({
            'error': 'Invalid input values',
            'message': str(e)
        }), 400
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return jsonify({
            'error': 'Prediction failed',
            'message': str(e)
        }), 500

# Water intake tracking endpoints
@app.route('/api/water', methods=['POST'])
def add_water_intake():
    data = request.get_json()
    entry = {
        'id': len(water_data) + 1,
        'amount': data.get('amount', 0),
        'timestamp': datetime.now().isoformat()
    }
    water_data.append(entry)
    return jsonify(entry), 201

@app.route('/api/water', methods=['GET'])
def get_water_intake():
    return jsonify(water_data)

@app.route('/api/water/today', methods=['GET'])
def get_today_intake():
    today = datetime.now().date()
    today_data = [
        entry for entry in water_data 
        if datetime.fromisoformat(entry['timestamp']).date() == today
    ]
    total = sum(entry['amount'] for entry in today_data)
    return jsonify({'total': total, 'entries': today_data})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)