import os
import joblib
from models import db, Prediction

def rule_predict(ph, turbidity, bacterial_count, temperature):
    """Rule-based prediction logic"""
    score = 0
    
    # pH risk (ideal: 6.5-8.5)
    if ph < 6.0 or ph > 9.0:
        score += 30
    elif ph < 6.5 or ph > 8.5:
        score += 15
    
    # Turbidity risk (ideal: <1 NTU)
    if turbidity > 5:
        score += 25
    elif turbidity > 2:
        score += 15
    elif turbidity > 1:
        score += 5
    
    # Temperature risk
    if temperature > 35:
        score += 20
    elif temperature > 30:
        score += 10
    
    # Bacterial count risk
    if bacterial_count > 1000:
        score += 25
    elif bacterial_count > 100:
        score += 15
    elif bacterial_count > 10:
        score += 5
    
    # Normalize score to 0-1 range
    normalized_score = min(score / 100.0, 1.0)
    
    # Determine risk category
    if normalized_score >= 0.7:
        risk = "High"
    elif normalized_score >= 0.4:
        risk = "Medium"
    else:
        risk = "Low"
    
    return risk, normalized_score

def ml_predict(ph, turbidity, bacterial_count, temperature):
    """ML-based prediction if model exists"""
    model_path = os.path.join(os.path.dirname(__file__), 'models', 'ai_model.pkl')
    
    if os.path.exists(model_path):
        try:
            model = joblib.load(model_path)
            features = [[ph, turbidity, bacterial_count, temperature]]
            prediction = model.predict(features)[0]
            probability = model.predict_proba(features)[0].max()
            
            return prediction, probability
        except Exception as e:
            print(f"ML prediction failed: {e}")
            return rule_predict(ph, turbidity, bacterial_count, temperature)
    else:
        return rule_predict(ph, turbidity, bacterial_count, temperature)

def save_prediction(ph, turbidity, bacterial_count, temperature, location, risk, score):
    """Save prediction to database"""
    prediction = Prediction(
        ph=ph,
        turbidity=turbidity,
        bacterial_count=bacterial_count,
        temperature=temperature,
        location=location,
        risk=risk,
        score=score
    )
    
    db.session.add(prediction)
    db.session.commit()
    
    return prediction.id