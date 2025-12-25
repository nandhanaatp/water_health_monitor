# 🧪 Testing Notifications & Alerts Guide

## Quick Test Examples

### 1. **Start Your Servers**
```bash
# Backend (in backend folder)
python app.py

# Frontend (in main folder)
flutter run -d chrome
```

### 2. **Login Credentials**
- **Admin**: `admin` / `admin123` (can access Test Alerts)
- **Officer**: `officer` / `officer123`
- **Worker**: `worker` / `worker123`

### 3. **Test Data Already Created**
✅ The backend now has test data that triggered these alerts:
- Critical pH alert (pH 5.2)
- High turbidity alert (6.8 NTU)
- Contamination alert (High Risk)
- Disease outbreak alert (25 cases)
- System notification

### 4. **Manual Testing in Flutter App**

#### **Option A: Use Test Alerts Page (Admin Only)**
1. Login as `admin`
2. Click **"Test Alerts"** card
3. Try these buttons:
   - **Critical pH Water Sample** → Triggers pH alert
   - **High Turbidity Sample** → Triggers turbidity alert
   - **High Risk Contamination** → Triggers contamination alert
   - **Disease Outbreak Alert** → Triggers disease alert
   - **Generate Test Notifications** → Adds 4 sample notifications

#### **Option B: Manual Water Sample Entry**
1. Go to **Water Quality** page
2. Click **"Add Sample"** (Officer/Admin only)
3. Enter these values to trigger alerts:

**Critical pH Test:**
```
Location: Test Location A
State: Any state
District: Any district
pH: 5.5 (triggers alert if < 6.0 or > 8.5)
Turbidity: 2.0
Bacterial Count: 100
Temperature: 25
```

**High Turbidity Test:**
```
Location: Test Location B
pH: 7.2
Turbidity: 6.0 (triggers alert if > 5.0)
Bacterial Count: 150
Temperature: 26
```

**Contamination Test:**
```
Location: Test Location C
pH: 7.0
Turbidity: 3.0
Bacterial Count: 300
Temperature: 28
Contamination Level: High Risk (triggers alert)
```

#### **Option C: Manual Disease Alert Entry**
1. Go to **Disease Alerts** page
2. Click **"Report Alert"** (Officer/Admin only)
3. Enter:
```
Disease: Test Disease
Cases: 20
Risk Level: Critical (triggers alert if High/Critical)
Location: Test Area
State: Any state
District: Any district
```

### 5. **Check Notifications**
1. Look for red badge on 🔔 icon in app bar
2. Click notifications icon to see all alerts
3. Notifications show:
   - **Type icons**: 💧 Water, 🏥 Disease, ⚙️ System
   - **Timestamps**: "Just now", "5m ago", etc.
   - **Read status**: Blue dot for unread

### 6. **Search & Filter Testing**

#### **Water Quality Search:**
- Search by location: "Test"
- Filter by state/district
- Filter by date range
- Filter by contamination level

#### **Disease Alerts Search:**
- Search by disease name: "Cholera"
- Filter by risk level: "Critical"
- Filter by district

#### **Notifications Search:**
- All notifications are sorted by newest first
- Click to mark as read
- "Mark All Read" button available

### 7. **Expected Alert Triggers**

| Condition | Trigger Value | Alert Type |
|-----------|---------------|------------|
| pH too low | < 6.0 | Water Quality |
| pH too high | > 8.5 | Water Quality |
| High turbidity | > 5.0 NTU | Water Quality |
| Contamination | "High Risk" | Water Quality |
| Disease risk | "High" or "Critical" | Disease Outbreak |

### 8. **Troubleshooting**

**No notifications appearing?**
- Check if backend is running on correct IP
- Verify network_config.dart has correct IP address
- Check browser console for API errors

**Test alerts not working?**
- Make sure you're logged in as admin to see "Test Alerts"
- Check if API endpoints are responding
- Verify database has notification table

**Search not working?**
- Check if data exists in database
- Verify API endpoints return data
- Check network connectivity

### 9. **API Testing (Optional)**

Test API directly with curl:
```bash
# Get notifications
curl http://10.13.8.135:5000/api/notifications

# Add water sample (triggers alerts)
curl -X POST http://10.13.8.135:5000/api/water \
  -H "Content-Type: application/json" \
  -d '{"location":"API Test","state":"Test","district":"Test","ph":5.0,"turbidity":2.0,"bacterial_count":100,"temperature":25,"contamination_level":"Safe"}'
```

### 10. **Demo Scenario**
1. Login as admin
2. Go to "Test Alerts" → Click "Generate Test Notifications"
3. Check notification badge (should show 4)
4. Click notifications → See 4 new alerts
5. Go to "Water Quality" → Add critical pH sample
6. Check notifications again → Should have new pH alert
7. Mark some as read → Badge count decreases

This gives you a complete testing environment for the notification system!