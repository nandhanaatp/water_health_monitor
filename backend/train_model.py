import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report
import joblib
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_sample_data():
    """Create sample water quality dataset if no dataset exists"""
    np.random.seed(42)
    n_samples = 1000
    
    # Generate synthetic water quality data
    data = {
        'ph': np.random.normal(7.0, 1.5, n_samples),
        'hardness': np.random.normal(150, 50, n_samples),
        'solids': np.random.normal(25000, 10000, n_samples),
        'chloramines': np.random.normal(4.0, 2.0, n_samples),
        'sulfate': np.random.normal(300, 100, n_samples),
        'conductivity': np.random.normal(400, 150, n_samples),
        'organic_carbon': np.random.normal(12, 5, n_samples),
        'trihalomethanes': np.random.normal(70, 30, n_samples),
        'turbidity': np.random.normal(4.0, 2.0, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # Create target based on water quality rules
    df['potability'] = ((df['ph'] >= 6.5) & (df['ph'] <= 8.5) & 
                       (df['hardness'] <= 300) & 
                       (df['solids'] <= 40000) & 
                       (df['chloramines'] <= 8) & 
                       (df['turbidity'] <= 5)).astype(int)
    
    return df

def train_model():
    """Train water quality prediction model"""
    
    # Create datasets directory if it doesn't exist
    os.makedirs('datasets', exist_ok=True)
    os.makedirs('models', exist_ok=True)
    
    # Try to load existing dataset or create sample data
    dataset_path = 'datasets/water_quality.csv'
    
    if os.path.exists(dataset_path):
        logger.info(f"Loading dataset from {dataset_path}")
        df = pd.read_csv(dataset_path)
    else:
        logger.info("Creating sample dataset")
        df = create_sample_data()
        df.to_csv(dataset_path, index=False)
        logger.info(f"Sample dataset saved to {dataset_path}")
    
    # Prepare features and target
    feature_columns = ['ph', 'hardness', 'solids', 'chloramines', 'sulfate',
                      'conductivity', 'organic_carbon', 'trihalomethanes', 'turbidity']
    
    X = df[feature_columns]
    y = df['potability']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    logger.info("Training Random Forest model...")
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train_scaled, y_train)
    
    # Evaluate model
    y_pred = model.predict(X_test_scaled)
    accuracy = accuracy_score(y_test, y_pred)
    
    logger.info(f"Model accuracy: {accuracy:.4f}")
    logger.info("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    
    # Create pipeline with scaler and model
    from sklearn.pipeline import Pipeline
    pipeline = Pipeline([
        ('scaler', scaler),
        ('classifier', model)
    ])
    
    # Save model
    model_path = 'models/ai_model.pkl'
    joblib.dump(pipeline, model_path)
    logger.info(f"Model saved to {model_path}")
    
    return pipeline, accuracy

if __name__ == '__main__':
    model, accuracy = train_model()
    print(f"\nTraining completed! Model accuracy: {accuracy:.4f}")
    print("Model saved as 'models/ai_model.pkl'")