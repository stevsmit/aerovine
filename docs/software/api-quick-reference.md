# Acme.ai API Quick Reference Guide

**Base URL:** `https://api.acme.ai/v2`
**Auth:** Bearer Token in `Authorization` header

---

## Quick Start

```bash
# 1. Get Access Token
curl -X POST https://api.acme.ai/v2/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "your_client_id",
    "client_secret": "your_client_secret",
    "grant_type": "client_credentials"
  }'

# 2. Use Token in Requests
curl -X GET https://api.acme.ai/v2/fleet/drones \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Common Endpoints Cheat Sheet

### Fleet Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/fleet/drones` | List all drones |
| `GET` | `/fleet/drones/{id}` | Get drone details |
| `PATCH` | `/fleet/drones/{id}` | Update drone config |
| `GET` | `/fleet/drones/{id}/health` | Component health |

### Flight Control

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/missions` | Create mission |
| `POST` | `/missions/{id}/start` | Start mission |
| `GET` | `/missions/{id}` | Get mission status |
| `POST` | `/missions/{id}/pause` | Pause mission |
| `POST` | `/missions/{id}/resume` | Resume mission |
| `POST` | `/missions/{id}/abort` | Abort mission |
| `POST` | `/fleet/drones/{id}/emergency_land` | Emergency landing |
| `POST` | `/fleet/drones/{id}/return_to_base` | Return to base |

### Telemetry

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/telemetry/drones/{id}/live` | Real-time telemetry |
| `GET` | `/telemetry/drones/{id}/history` | Historical data |
| `WSS` | `/telemetry/stream` | WebSocket stream |

### Agricultural Operations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/agriculture/spray-missions` | Create spray mission |
| `GET` | `/agriculture/fields/{id}/health` | Crop health analysis |
| `GET` | `/agriculture/fields/{id}/ndvi-map` | Get NDVI imagery |
| `POST` | `/agriculture/spray-logs` | Log spray application |

### Maintenance

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/fleet/drones/{id}/maintenance/schedule` | Get schedule |
| `POST` | `/fleet/drones/{id}/maintenance/log` | Log maintenance |
| `POST` | `/fleet/drones/{id}/diagnostics/run` | Run diagnostics |

### Analytics

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/analytics/fleet` | Fleet analytics |
| `GET` | `/analytics/agriculture` | Crop analytics |
| `POST` | `/analytics/reports/export` | Export report |

### Weather

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/weather/forecast` | Weather forecast |
| `GET` | `/weather/spray-recommendations` | Spray timing AI |

---

## Mission Types

- `crop_survey` - Crop health monitoring
- `precision_spray` - Targeted chemical application
- `soil_analysis` - Soil condition assessment
- `irrigation_check` - Irrigation system monitoring
- `pest_scouting` - Pest detection
- `livestock_count` - Animal counting
- `planting_guide` - Planting path guidance
- `harvest_planning` - Pre-harvest assessment

---

## Drone Status Values

- `operational` - Ready for missions
- `in_flight` - Currently flying
- `charging` - Battery charging
- `maintenance` - Under maintenance
- `emergency` - Emergency state
- `offline` - Not connected

---

## AI Analysis Modules

```json
"ai_analysis": {
  "modules": [
    "crop_health_ndvi",      // Vegetation health
    "pest_detection",         // Pest identification
    "weed_mapping",          // Weed locations
    "disease_identification", // Disease detection
    "nutrient_deficiency",   // Nutrient analysis
    "stress_prediction",     // Stress forecasting
    "yield_estimation"       // Harvest prediction
  ]
}
```

---

## Weather Constraints

```json
"weather_constraints": {
  "max_wind_speed_kph": 15,
  "min_visibility_meters": 1000,
  "no_precipitation": true,
  "min_temperature_celsius": 10,
  "max_temperature_celsius": 30,
  "no_rain_forecast_hours": 4
}
```

---

## Common Query Parameters

### Pagination
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 50, max: 100)

### Filtering
- `status` - Filter by status
- `farm_id` - Filter by farm
- `field_id` - Filter by field
- `crop_type` - Filter by crop
- `start_date` - Start date (ISO 8601)
- `end_date` - End date (ISO 8601)

---

## Response Codes

| Code | Meaning |
|------|---------|
| `200` | Success |
| `201` | Created |
| `202` | Accepted (async processing) |
| `400` | Bad request |
| `401` | Unauthorized |
| `403` | Forbidden |
| `404` | Not found |
| `409` | Conflict |
| `422` | Validation error |
| `429` | Rate limit exceeded |
| `500` | Server error |

---

## Rate Limits

- **Standard:** 1,000 requests/hour
- **Professional:** 10,000 requests/hour
- **Enterprise:** Custom

**Headers:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1701446400
```

---

## Webhook Events

Subscribe to real-time events:

```json
{
  "events": [
    "mission.started",
    "mission.completed",
    "mission.failed",
    "drone.battery_low",
    "drone.maintenance_due",
    "ai.issue_detected",
    "weather.spray_window_opening",
    "compliance.spray_logged"
  ]
}
```

---

## Example: Complete Mission Workflow

```bash
# 1. Create Mission
curl -X POST https://api.acme.ai/v2/missions \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "mission_type": "crop_survey",
    "drone_id": "A-23",
    "field_ids": ["field_b23"],
    "ai_analysis": {"enabled": true}
  }'

# Response: {"mission_id": "m_42", "status": "scheduled"}

# 2. Start Mission
curl -X POST https://api.acme.ai/v2/missions/m_42/start \
  -H "Authorization: Bearer TOKEN"

# 3. Monitor Progress
curl -X GET https://api.acme.ai/v2/missions/m_42 \
  -H "Authorization: Bearer TOKEN"

# 4. Get Results
curl -X GET https://api.acme.ai/v2/agriculture/fields/field_b23/health \
  -H "Authorization: Bearer TOKEN"
```

---

## Example: Precision Spray Operation

```bash
curl -X POST https://api.acme.ai/v2/agriculture/spray-missions \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "drone_id": "B-12",
    "field_id": "field_c47",
    "chemical": {
      "name": "Azoxystrobin",
      "type": "fungicide",
      "target_rate_lha": 0.5
    },
    "spray_zones": [{
      "area_hectares": 12.4,
      "reason": "Disease outbreak detected by AI"
    }],
    "ai_optimization": {
      "variable_rate_application": true
    }
  }'
```

---

## Example: Real-time Telemetry

```bash
# HTTP Polling
curl -X GET https://api.acme.ai/v2/telemetry/drones/A-23/live \
  -H "Authorization: Bearer TOKEN"

# WebSocket Stream
wscat -c wss://api.acme.ai/v2/telemetry/stream \
  -H "Authorization: Bearer TOKEN"

# Send subscription:
{
  "action": "subscribe",
  "drone_ids": ["A-23"],
  "data_rate_hz": 10
}
```

---

## Agricultural Metrics

### Vegetation Indices
- **NDVI** (0.0-1.0): Overall vegetation health
  - 0.0-0.2: Bare soil, stressed
  - 0.2-0.5: Unhealthy vegetation
  - 0.5-0.8: Healthy vegetation
  - 0.8-1.0: Very dense, healthy vegetation

### Crop Health Zones
- **Healthy:** 🟢 >75%
- **Stressed:** 🟡 50-75%
- **Disease:** 🟠 25-50%
- **Critical:** 🔴 <25%

---

## Key Agricultural Terms

| Term | Definition |
|------|------------|
| **AGL** | Above Ground Level (altitude) |
| **NDVI** | Normalized Difference Vegetation Index |
| **NDRE** | Normalized Difference Red Edge (chlorophyll) |
| **Hectare (ha)** | 10,000 m² or 2.47 acres |
| **L/ha** | Liters per hectare (spray rate) |
| **t/ha** | Tonnes per hectare (yield) |
| **GDD** | Growing Degree Days |
| **REI** | Re-Entry Interval (hours after spray) |
| **PHI** | Pre-Harvest Interval (days) |
| **VRA** | Variable Rate Application |

---

## Error Handling

```json
{
  "error": {
    "code": "DRONE_NOT_FOUND",
    "message": "Drone with ID 'A-99' does not exist",
    "details": {
      "drone_id": "A-99"
    },
    "request_id": "req_8472",
    "timestamp": "2024-12-01T14:30:00Z"
  }
}
```

**Common Error Codes:**
- `INVALID_TOKEN` - Auth token invalid/expired
- `DRONE_NOT_FOUND` - Drone doesn't exist
- `DRONE_UNAVAILABLE` - Drone busy/offline
- `WEATHER_UNSUITABLE` - Bad weather for operation
- `BATTERY_TOO_LOW` - Insufficient battery
- `GEOFENCE_VIOLATION` - Route outside boundaries
- `MAINTENANCE_REQUIRED` - Drone needs service

---

## Testing with cURL

```bash
# Store token
export TOKEN="your_access_token_here"

# List drones
curl -H "Authorization: Bearer $TOKEN" \
  https://api.acme.ai/v2/fleet/drones

# Get telemetry
curl -H "Authorization: Bearer $TOKEN" \
  https://api.acme.ai/v2/telemetry/drones/A-23/live

# Emergency land
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Test"}' \
  https://api.acme.ai/v2/fleet/drones/A-23/emergency_land
```

---

## SDK Support (Planned)

- Python SDK: `pip install acme-ai-sdk`
- JavaScript SDK: `npm install @acme-ai/sdk`
- Go SDK: `go get github.com/acme-ai/go-sdk`

---

## Resources

- **Full Documentation:** https://docs.acme.ai
- **API Status:** https://status.acme.ai
- **Support:** api-support@acme.ai
- **Developer Portal:** https://developers.acme.ai
- **Changelog:** https://docs.acme.ai/changelog

---

**Last Updated:** December 2024
**API Version:** v2.1.0
