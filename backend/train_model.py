import pandas as pd
import numpy as np
import os
import logging
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from joblib import dump

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_datasets():
    base = "datasets"
    paths = {
        "indian": os.path.join(base, "indian_water.csv"),
        "pollution": os.path.join(base, "water_pollution.csv")
    }
    datasets = {}
    for name, path in paths.items():
        if os.path.exists(path):
            df = pd.read_csv(path)
            df.columns = [c.lower().strip() for c in df.columns]
            datasets[name] = df
            logger.info(f"Loaded {name}: {df.shape[0]} rows, {df.shape[1]} columns")
        else:
            logger.warning(f"{path} not found.")
    return datasets

def extract_features(df):
    df.columns = [c.lower().strip() for c in df.columns]

    if "pH level".lower() in df.columns:
        df["ph"] = pd.to_numeric(df["pH level".lower()], errors="coerce")
    elif "pH - min".lower() in df.columns and "pH - max".lower() in df.columns:
        df["ph"] = (
            pd.to_numeric(df["pH - min".lower()], errors="coerce") +
            pd.to_numeric(df["pH - max".lower()], errors="coerce")
        ) / 2
    else:
        df["ph"] = 7

    if "dissolved oxygen (mg/l)".lower() in df.columns:
        df["dissolved_oxygen"] = pd.to_numeric(df["dissolved oxygen (mg/l)".lower()], errors="coerce")
    elif "dissolved - min" in df.columns and "dissolved - max" in df.columns:
        df["dissolved_oxygen"] = (
            pd.to_numeric(df["dissolved - min"], errors="coerce") +
            pd.to_numeric(df["dissolved - max"], errors="coerce")
        ) / 2
    else:
        df["dissolved_oxygen"] = 7

    if "turbidity (ntu)" in df.columns:
        df["turbidity"] = pd.to_numeric(df["turbidity (ntu)"], errors="coerce")
    else:
        df["turbidity"] = np.nan

    return df[["ph", "dissolved_oxygen", "turbidity"]]

def create_target(df):
    df["Water_Quality"] = (
        df["ph"].between(6.5, 8.5) &
        (df["dissolved_oxygen"] >= 5) &
        (df["turbidity"].fillna(2) < 5)
    ).map({True: "Safe", False: "Unsafe"})
    logger.info(
        f"Target distribution → Safe: {sum(df['Water_Quality']=='Safe')}, "
        f"Unsafe: {sum(df['Water_Quality']=='Unsafe')}"
    )
    return df

def train_model():
    logger.info("=== TRAINING STARTED ===")

    data = load_datasets()
    if not data:
        logger.error("No datasets found. Cannot train.")
        return

    df = pd.concat(data.values(), ignore_index=True)
    logger.info(f"Combined dataset size: {df.shape}")

    df = extract_features(df)
    df = create_target(df)

    X = df[["ph", "dissolved_oxygen", "turbidity"]].fillna(2)
    y = df["Water_Quality"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = RandomForestClassifier(n_estimators=200, random_state=42)
    model.fit(X_train, y_train)

    preds = model.predict(X_test)
    acc = accuracy_score(y_test, preds)
    logger.info(f"Model accuracy: {acc:.4f}")
    logger.info("\n" + classification_report(y_test, preds))

    os.makedirs("models", exist_ok=True)
    dump(model, "models/ai_model.pkl")
    logger.info("Model saved → models/ai_model.pkl")

    logger.info("=== TRAINING COMPLETE ===")
    return model, acc

if __name__ == "__main__":
    train_model()
