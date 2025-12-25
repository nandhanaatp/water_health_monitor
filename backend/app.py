from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from datetime import datetime
import os
import pandas as pd

from models import db, WaterSample, DiseaseAlert, Prediction, User
from database import init_db, get_db_stats
from prediction import ml_predict, save_prediction
from notifications import Notification, check_water_quality_alerts, check_disease_alerts

def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///health_monitor.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    CORS(app)
    init_db(app)
    
    return app

app = create_app()

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    stats = get_db_stats()
    return jsonify({
        'status': 'healthy',
        'database': stats,
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/water', methods=['GET'])
def get_water_samples():
    """Get water samples with optional filters"""
    query = WaterSample.query
    
    # Apply filters
    if request.args.get('state'):
        query = query.filter(WaterSample.state == request.args.get('state'))
    
    if request.args.get('district'):
        query = query.filter(WaterSample.district == request.args.get('district'))
    
    if request.args.get('start_date'):
        start_date = datetime.fromisoformat(request.args.get('start_date'))
        query = query.filter(WaterSample.sample_date >= start_date)
    
    if request.args.get('end_date'):
        end_date = datetime.fromisoformat(request.args.get('end_date'))
        query = query.filter(WaterSample.sample_date <= end_date)
    
    samples = query.order_by(WaterSample.sample_date.desc()).all()
    return jsonify([sample.to_dict() for sample in samples])

@app.route('/api/water', methods=['POST'])
def add_water_sample():
    """Add new water sample"""
    data = request.get_json()
    
    try:
        sample = WaterSample(
            location=data['location'],
            state=data['state'],
            district=data['district'],
            ph=float(data['ph']),
            turbidity=float(data['turbidity']),
            bacterial_count=float(data['bacterial_count']),
            temperature=float(data['temperature']),
            contamination_level=data['contamination_level']
        )
        
        db.session.add(sample)
        db.session.commit()
        
        # Check for alerts
        check_water_quality_alerts(sample)
        
        return jsonify(sample.to_dict()), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/api/alerts', methods=['GET'])
def get_disease_alerts():
    """Get disease alerts with optional filters"""
    query = DiseaseAlert.query
    
    if request.args.get('disease'):
        query = query.filter(DiseaseAlert.disease == request.args.get('disease'))
    
    if request.args.get('district'):
        query = query.filter(DiseaseAlert.district == request.args.get('district'))
    
    alerts = query.order_by(DiseaseAlert.reported_at.desc()).all()
    return jsonify([alert.to_dict() for alert in alerts])

@app.route('/api/alerts', methods=['POST'])
def add_disease_alert():
    """Add new disease alert"""
    data = request.get_json()
    
    try:
        alert = DiseaseAlert(
            disease=data['disease'],
            cases=int(data['cases']),
            risk_level=data['risk_level'],
            location=data['location'],
            state=data['state'],
            district=data['district']
        )
        
        db.session.add(alert)
        db.session.commit()
        
        # Check for alerts
        check_disease_alerts(alert)
        
        return jsonify(alert.to_dict()), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/api/predict', methods=['POST'])
def predict_risk():
    """Predict disease risk based on water quality parameters"""
    data = request.get_json()
    
    try:
        ph = float(data['ph'])
        turbidity = float(data['turbidity'])
        bacterial_count = float(data['bacterial_count'])
        temperature = float(data['temperature'])
        location = data['location']
        
        # Get prediction
        risk, score = ml_predict(ph, turbidity, bacterial_count, temperature)
        
        # Save prediction to database
        prediction_id = save_prediction(ph, turbidity, bacterial_count, temperature, location, risk, score)
        
        return jsonify({
            'risk': risk,
            'score': round(score, 2),
            'id': prediction_id
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/api/summary', methods=['GET'])
def get_summary():
    """Get summary statistics"""
    try:
        # Get water quality statistics
        samples = WaterSample.query.all()
        
        if not samples:
            return jsonify({
                'avg_ph': 0,
                'avg_turbidity': 0,
                'contamination_index': 0,
                'sample_count': 0
            })
        
        df = pd.DataFrame([{
            'ph': s.ph,
            'turbidity': s.turbidity,
            'contamination_level': s.contamination_level
        } for s in samples])
        
        avg_ph = df['ph'].mean()
        avg_turbidity = df['turbidity'].mean()
        contamination_count = len(df[df['contamination_level'].isin(['High Risk', 'Moderate'])])
        contamination_index = (contamination_count / len(df)) * 100
        
        return jsonify({
            'avg_ph': round(avg_ph, 2),
            'avg_turbidity': round(avg_turbidity, 2),
            'contamination_index': round(contamination_index, 1),
            'sample_count': len(samples)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/api/login', methods=['POST'])
def login():
    """User login endpoint"""
    data = request.get_json()
    
    try:
        username = data['username']
        password = data['password']
        
        # Find user in database
        user = User.query.filter_by(username=username, password=password).first()
        
        if user:
            return jsonify({
                'status': 'success',
                'message': 'Login successful',
                'role': user.role,
                'user_id': user.id
            })
        else:
            return jsonify({
                'status': 'error',
                'message': 'Invalid username or password'
            }), 401
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 400

@app.route('/api/notifications', methods=['GET'])
def get_notifications():
    """Get notifications for current user"""
    try:
        notifications = Notification.query.order_by(Notification.created_at.desc()).limit(50).all()
        return jsonify({
            'notifications': [notification.to_dict() for notification in notifications]
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    """Serve uploaded files"""
    uploads_dir = os.path.join(app.root_path, 'uploads')
    return send_from_directory(uploads_dir, filename)

if __name__ == '__main__':
    with app.app_context():
        # Seed database on first run
        if WaterSample.query.count() == 0:
            from seed_data import seed_database
            seed_database()
    
    print("Smart Community Health Monitoring Backend")
    print("API Endpoints:")
    print("   GET  /api/health")
    print("   POST /api/login")
    print("   GET  /api/water")
    print("   POST /api/water")
    print("   GET  /api/alerts")
    print("   POST /api/alerts")
    print("   POST /api/predict")
    print("   GET  /api/summary")
    print("   GET  /api/notifications")
    print("   GET  /uploads/<file>")
    print("\nServer running on http://0.0.0.0:5000")
    
    app.run(debug=True, host='0.0.0.0', port=5000)