from models import db
from datetime import datetime

class Notification(db.Model):
    __tablename__ = 'notifications'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.String(20), nullable=False)  # 'water', 'disease', 'system'
    user_id = db.Column(db.Integer, nullable=True)  # None for broadcast
    read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'message': self.message,
            'type': self.type,
            'read': self.read,
            'timestamp': self.created_at.isoformat()
        }

def create_notification(title, message, notification_type, user_id=None):
    """Create a new notification"""
    notification = Notification(
        title=title,
        message=message,
        type=notification_type,
        user_id=user_id
    )
    db.session.add(notification)
    db.session.commit()
    return notification

def check_water_quality_alerts(water_sample):
    """Check water sample and create alerts if needed"""
    alerts = []
    
    # pH alerts
    if water_sample.ph < 6.0 or water_sample.ph > 8.5:
        alert = create_notification(
            title="Critical pH Level",
            message=f"pH level {water_sample.ph:.1f} detected at {water_sample.location}",
            notification_type="water"
        )
        alerts.append(alert)
    
    # Turbidity alerts
    if water_sample.turbidity > 5.0:
        alert = create_notification(
            title="High Turbidity Alert",
            message=f"Turbidity {water_sample.turbidity:.1f} NTU at {water_sample.location}",
            notification_type="water"
        )
        alerts.append(alert)
    
    # Contamination alerts
    if water_sample.contamination_level == 'High Risk':
        alert = create_notification(
            title="Contamination Alert",
            message=f"High risk contamination detected at {water_sample.location}",
            notification_type="water"
        )
        alerts.append(alert)
    
    return alerts

def check_disease_alerts(disease_alert):
    """Check disease alert and create notifications if needed"""
    alerts = []
    
    if disease_alert.risk_level in ['High', 'Critical']:
        alert = create_notification(
            title=f"{disease_alert.disease} Outbreak Alert",
            message=f"{disease_alert.cases} cases reported in {disease_alert.district}",
            notification_type="disease"
        )
        alerts.append(alert)
    
    return alerts