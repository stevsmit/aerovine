# Acme.ai Agricultural Drone Fleet API Documentation

**Version:** 2.1.0
**Base URL:** `https://api.acme.ai/v2`
**Protocol:** REST (JSON)
**Authentication:** Bearer Token (OAuth 2.0)

---

## Table of Contents

1. [Authentication](#authentication)
2. [Fleet Management](#fleet-management)
3. [Flight Planning & Control](#flight-planning--control)
4. [Telemetry & Real-time Data](#telemetry--real-time-data)
5. [Agricultural Operations](#agricultural-operations)
6. [Maintenance & Diagnostics](#maintenance--diagnostics)
7. [Analytics & Reporting](#analytics--reporting)
8. [Weather Integration](#weather-integration)
9. [Webhooks & Events](#webhooks--events)
10. [Error Codes](#error-codes)

---

## Authentication

All API requests require authentication using OAuth 2.0 Bearer tokens.

### Obtain Access Token

```http
POST /auth/token
Content-Type: application/json

{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "grant_type": "client_credentials",
  "scope": "fleet.read fleet.write telemetry.read operations.write"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "fleet.read fleet.write telemetry.read operations.write"
}
```

**Usage:**
```http
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Fleet Management

### List All Drones

Retrieve all drones in your fleet with current status.

```http
GET /fleet/drones
Authorization: Bearer {token}
```

**Query Parameters:**
- `status` (optional): Filter by status (`operational`, `charging`, `maintenance`, `in_flight`)
- `farm_id` (optional): Filter by assigned farm
- `page` (optional): Page number (default: 1)
- `limit` (optional): Results per page (default: 50, max: 100)

**Response (200 OK):**
```json
{
  "data": [
    {
      "drone_id": "A-23",
      "model": "ACME-X7-AG",
      "serial_number": "A-00023",
      "status": "in_flight",
      "battery_percent": 87,
      "battery_remaining_minutes": 23,
      "current_mission_id": "m_42",
      "location": {
        "latitude": 41.9876,
        "longitude": -93.6201,
        "altitude_agl_meters": 45,
        "heading_degrees": 273
      },
      "assigned_farm_id": "farm_miller_iowa",
      "firmware_version": "2.4.1",
      "last_maintenance_date": "2024-11-15T08:30:00Z",
      "total_flight_hours": 342.5,
      "capabilities": [
        "multispectral_imaging",
        "thermal_camera",
        "precision_spray",
        "lidar",
        "hyperspectral"
      ],
      "health_score": 98,
      "created_at": "2024-01-12T10:00:00Z",
      "updated_at": "2024-12-01T14:23:45Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 47,
    "total_pages": 1
  }
}
```

---

### Get Drone Details

Retrieve detailed information about a specific drone.

```http
GET /fleet/drones/{drone_id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "model": "ACME-X7-AG",
  "serial_number": "A-00023",
  "status": "in_flight",
  "battery": {
    "percent": 87,
    "voltage": 24.8,
    "current_draw_amps": 12.3,
    "remaining_minutes": 23,
    "charge_cycles": 147,
    "health_percent": 94
  },
  "location": {
    "latitude": 41.9876,
    "longitude": -93.6201,
    "altitude_agl_meters": 45,
    "altitude_msl_meters": 320,
    "heading_degrees": 273,
    "speed_mps": 12.5,
    "ground_speed_mps": 11.8
  },
  "sensors": {
    "rgb_camera": {
      "resolution_mp": 42,
      "status": "active",
      "gimbal_angle": -90
    },
    "multispectral": {
      "bands": ["red", "green", "blue", "nir", "red_edge"],
      "status": "active"
    },
    "thermal": {
      "resolution": "640x512",
      "temperature_range": [-20, 150],
      "status": "active"
    },
    "lidar": {
      "range_meters": 100,
      "status": "active"
    },
    "gps": {
      "fix_type": "rtk",
      "satellites": 18,
      "hdop": 0.7
    }
  },
  "spray_system": {
    "installed": true,
    "tank_capacity_liters": 20,
    "tank_level_liters": 15.6,
    "tank_percent": 78,
    "nozzles": 4,
    "nozzle_status": "ready",
    "flow_rate_lpm": 0.8,
    "last_calibration": "2024-11-28T10:00:00Z"
  },
  "current_mission_id": "m_42",
  "assigned_farm_id": "farm_miller_iowa",
  "firmware_version": "2.4.1",
  "last_maintenance_date": "2024-11-15T08:30:00Z",
  "next_maintenance_due_hours": 57.5,
  "total_flight_hours": 342.5,
  "health_score": 98,
  "diagnostics": {
    "motors": [98, 97, 98, 96],
    "esc_temperature_c": [42, 43, 41, 44],
    "imu_status": "healthy",
    "compass_interference": "none",
    "vibration_level": "normal"
  }
}
```

---

### Update Drone Configuration

Update drone settings and configuration.

```http
PATCH /fleet/drones/{drone_id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "assigned_farm_id": "farm_miller_iowa",
  "max_altitude_agl_meters": 120,
  "max_speed_mps": 15,
  "return_to_base_battery_percent": 25,
  "geofence_enabled": true
}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "message": "Configuration updated successfully",
  "updated_fields": ["assigned_farm_id", "max_altitude_agl_meters"]
}
```

---

## Flight Planning & Control

### Create Flight Mission

Plan and create a new agricultural operation mission.

```http
POST /missions
Authorization: Bearer {token}
Content-Type: application/json

{
  "mission_type": "crop_survey",
  "name": "Wheat Health Survey - Field B-23",
  "description": "Weekly health monitoring for spring wheat",
  "drone_id": "A-23",
  "farm_id": "farm_miller_iowa",
  "field_ids": ["field_b23"],
  "priority": "normal",
  "schedule": {
    "start_time": "2024-12-01T15:00:00Z",
    "auto_start": true,
    "weather_constraints": {
      "max_wind_speed_kph": 15,
      "min_visibility_meters": 1000,
      "no_precipitation": true
    }
  },
  "flight_parameters": {
    "altitude_agl_meters": 45,
    "speed_mps": 12,
    "overlap_percent": 70,
    "pattern": "grid",
    "gimbal_angle_degrees": -90
  },
  "waypoints": [
    {
      "sequence": 1,
      "latitude": 41.9876,
      "longitude": -93.6201,
      "altitude_agl_meters": 45,
      "action": "start_imaging"
    },
    {
      "sequence": 2,
      "latitude": 41.9880,
      "longitude": -93.6190,
      "altitude_agl_meters": 45,
      "action": "continue_imaging"
    },
    {
      "sequence": 3,
      "latitude": 41.9870,
      "longitude": -93.6180,
      "altitude_agl_meters": 45,
      "action": "stop_imaging"
    }
  ],
  "ai_analysis": {
    "enabled": true,
    "modules": [
      "crop_health_ndvi",
      "pest_detection",
      "weed_mapping",
      "disease_identification",
      "nutrient_deficiency",
      "stress_prediction",
      "yield_estimation"
    ],
    "realtime_processing": true
  },
  "data_collection": {
    "rgb_imaging": true,
    "multispectral": true,
    "thermal": true,
    "lidar": false,
    "resolution": "high"
  }
}
```

**Response (201 Created):**
```json
{
  "mission_id": "m_42",
  "status": "scheduled",
  "estimated_duration_minutes": 18,
  "estimated_area_hectares": 245,
  "estimated_battery_usage_percent": 45,
  "waypoint_count": 3,
  "created_at": "2024-12-01T14:25:00Z",
  "scheduled_start": "2024-12-01T15:00:00Z",
  "message": "Mission created and scheduled successfully"
}
```

---

### Start Mission

Initiate a scheduled mission immediately.

```http
POST /missions/{mission_id}/start
Authorization: Bearer {token}
Content-Type: application/json

{
  "pre_flight_checks_confirmed": true,
  "override_weather_delay": false
}
```

**Response (200 OK):**
```json
{
  "mission_id": "m_42",
  "status": "in_progress",
  "drone_id": "A-23",
  "started_at": "2024-12-01T14:23:00Z",
  "estimated_completion": "2024-12-01T14:41:00Z",
  "message": "Mission started successfully"
}
```

---

### Get Mission Status

Retrieve real-time status of an active or completed mission.

```http
GET /missions/{mission_id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "mission_id": "m_42",
  "status": "in_progress",
  "mission_type": "crop_survey",
  "name": "Wheat Health Survey - Field B-23",
  "drone_id": "A-23",
  "farm_id": "farm_miller_iowa",
  "field_ids": ["field_b23"],
  "progress": {
    "percent_complete": 67,
    "area_covered_hectares": 163.5,
    "area_total_hectares": 245,
    "waypoints_completed": 2,
    "waypoints_total": 3,
    "images_captured": 2847,
    "estimated_time_remaining_minutes": 8
  },
  "started_at": "2024-12-01T14:23:00Z",
  "estimated_completion": "2024-12-01T14:41:00Z",
  "current_position": {
    "latitude": 41.9876,
    "longitude": -93.6201,
    "altitude_agl_meters": 45
  },
  "ai_detections": {
    "crop_health_average_percent": 82,
    "issues_detected": [
      {
        "type": "nutrient_deficiency",
        "severity": "moderate",
        "affected_area_hectares": 12.4,
        "location": {
          "latitude": 41.9878,
          "longitude": -93.6195
        },
        "details": "Nitrogen deficiency detected in NW corner"
      },
      {
        "type": "irrigation_stress",
        "severity": "low",
        "affected_area_hectares": 3.2,
        "location": {
          "latitude": 41.9872,
          "longitude": -93.6185
        },
        "details": "Dry patches identified, irrigation system check recommended"
      }
    ]
  }
}
```

---

### Pause Mission

Temporarily pause an in-progress mission.

```http
POST /missions/{mission_id}/pause
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "mission_id": "m_42",
  "status": "paused",
  "message": "Mission paused. Drone entering hover mode.",
  "paused_at": "2024-12-01T14:30:00Z"
}
```

---

### Resume Mission

Resume a paused mission.

```http
POST /missions/{mission_id}/resume
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "mission_id": "m_42",
  "status": "in_progress",
  "message": "Mission resumed",
  "resumed_at": "2024-12-01T14:32:00Z"
}
```

---

### Abort Mission

Cancel an in-progress mission and return drone to base.

```http
POST /missions/{mission_id}/abort
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Weather conditions deteriorating",
  "return_to_base": true,
  "save_partial_data": true
}
```

**Response (200 OK):**
```json
{
  "mission_id": "m_42",
  "status": "aborted",
  "message": "Mission aborted. Drone returning to base.",
  "aborted_at": "2024-12-01T14:35:00Z",
  "data_saved": true,
  "partial_completion_percent": 67
}
```

---

### Emergency Landing

Trigger immediate emergency landing.

```http
POST /fleet/drones/{drone_id}/emergency_land
Authorization: Bearer {token}
Content-Type: application/json

{
  "reason": "Low battery critical alert"
}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "status": "emergency_landing",
  "message": "Emergency landing initiated",
  "estimated_landing_time_seconds": 45,
  "landing_location": {
    "latitude": 41.9876,
    "longitude": -93.6201
  }
}
```

---

### Return to Base

Command drone to return to base station.

```http
POST /fleet/drones/{drone_id}/return_to_base
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "status": "returning_to_base",
  "message": "Returning to base",
  "base_location": {
    "latitude": 41.9850,
    "longitude": -93.6210
  },
  "estimated_arrival_minutes": 5,
  "current_mission_id": "m_42",
  "mission_action": "aborted"
}
```

---

## Telemetry & Real-time Data

### Get Real-time Telemetry

Retrieve live telemetry data from a specific drone.

```http
GET /telemetry/drones/{drone_id}/live
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "timestamp": "2024-12-01T14:23:45.123Z",
  "position": {
    "latitude": 41.9876,
    "longitude": -93.6201,
    "altitude_agl_meters": 45.2,
    "altitude_msl_meters": 320.5,
    "heading_degrees": 273,
    "pitch_degrees": -2.1,
    "roll_degrees": 1.3,
    "yaw_degrees": 273
  },
  "velocity": {
    "speed_mps": 12.5,
    "ground_speed_mps": 11.8,
    "vertical_speed_mps": 0.2,
    "velocity_north_mps": 2.3,
    "velocity_east_mps": -12.1,
    "velocity_down_mps": -0.2
  },
  "battery": {
    "percent": 87,
    "voltage": 24.8,
    "current_amps": 12.3,
    "remaining_minutes": 23,
    "temperature_celsius": 38
  },
  "environmental": {
    "air_temperature_celsius": 22,
    "pressure_hpa": 1013.25,
    "humidity_percent": 65,
    "wind_speed_kph": 6,
    "wind_direction_degrees": 315
  },
  "sensors": {
    "gps": {
      "fix_type": "rtk",
      "satellites": 18,
      "hdop": 0.7,
      "accuracy_meters": 0.02
    },
    "imu": {
      "acceleration_x": 0.12,
      "acceleration_y": -0.05,
      "acceleration_z": -9.81,
      "gyro_x": 0.01,
      "gyro_y": -0.02,
      "gyro_z": 0.15
    },
    "compass": {
      "heading_degrees": 273,
      "magnetic_field_strength": 485,
      "interference": "none"
    }
  },
  "motors": [
    {
      "id": 1,
      "rpm": 6800,
      "temperature_celsius": 42,
      "current_amps": 8.2,
      "health_percent": 98
    },
    {
      "id": 2,
      "rpm": 6750,
      "temperature_celsius": 43,
      "current_amps": 8.1,
      "health_percent": 97
    },
    {
      "id": 3,
      "rpm": 6820,
      "temperature_celsius": 41,
      "current_amps": 8.3,
      "health_percent": 98
    },
    {
      "id": 4,
      "rpm": 6790,
      "temperature_celsius": 44,
      "current_amps": 8.0,
      "health_percent": 96
    }
  ],
  "status": {
    "flight_mode": "auto",
    "armed": true,
    "autopilot_enabled": true,
    "obstacle_avoidance_active": true,
    "mission_id": "m_42",
    "errors": [],
    "warnings": []
  }
}
```

---

### Get Telemetry History

Retrieve historical telemetry data for analysis.

```http
GET /telemetry/drones/{drone_id}/history
Authorization: Bearer {token}
```

**Query Parameters:**
- `start_time` (required): ISO 8601 timestamp
- `end_time` (required): ISO 8601 timestamp
- `interval` (optional): Data interval (`1s`, `5s`, `30s`, `1m`, `5m`)
- `fields` (optional): Comma-separated fields to retrieve

**Example:**
```http
GET /telemetry/drones/A-23/history?start_time=2024-12-01T14:00:00Z&end_time=2024-12-01T15:00:00Z&interval=30s&fields=battery.percent,position.altitude_agl_meters
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "start_time": "2024-12-01T14:00:00Z",
  "end_time": "2024-12-01T15:00:00Z",
  "interval": "30s",
  "data_points": 120,
  "data": [
    {
      "timestamp": "2024-12-01T14:00:00Z",
      "battery_percent": 94,
      "altitude_agl_meters": 0
    },
    {
      "timestamp": "2024-12-01T14:00:30Z",
      "battery_percent": 94,
      "altitude_agl_meters": 12
    },
    {
      "timestamp": "2024-12-01T14:01:00Z",
      "battery_percent": 93,
      "altitude_agl_meters": 45
    }
  ]
}
```

---

### Stream Telemetry (WebSocket)

Establish WebSocket connection for real-time telemetry streaming.

```
wss://api.acme.ai/v2/telemetry/stream
Authorization: Bearer {token}
```

**Subscribe Message:**
```json
{
  "action": "subscribe",
  "drone_ids": ["A-23", "B-12"],
  "data_rate_hz": 10,
  "fields": ["position", "battery", "velocity"]
}
```

**Streaming Data:**
```json
{
  "drone_id": "A-23",
  "timestamp": "2024-12-01T14:23:45.123Z",
  "position": {
    "latitude": 41.9876,
    "longitude": -93.6201,
    "altitude_agl_meters": 45.2
  },
  "battery": {
    "percent": 87,
    "voltage": 24.8
  },
  "velocity": {
    "speed_mps": 12.5
  }
}
```

---

## Agricultural Operations

### Create Precision Spray Mission

Plan a precision spray operation with AI-optimized zones.

```http
POST /agriculture/spray-missions
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Fungicide Treatment - Field C-47",
  "drone_id": "B-12",
  "field_id": "field_c47",
  "chemical": {
    "name": "Azoxystrobin",
    "type": "fungicide",
    "concentration_percent": 25,
    "target_rate_lha": 0.5,
    "tank_mix_liters": 18
  },
  "spray_zones": [
    {
      "zone_id": "zone_1",
      "polygon": [
        {"lat": 41.9876, "lon": -93.6201},
        {"lat": 41.9880, "lon": -93.6190},
        {"lat": 41.9870, "lon": -93.6180}
      ],
      "area_hectares": 12.4,
      "reason": "Disease outbreak detected by AI",
      "severity": "high"
    }
  ],
  "flight_parameters": {
    "altitude_agl_meters": 3.5,
    "speed_mps": 5,
    "swath_width_meters": 6,
    "nozzle_pressure_psi": 40
  },
  "ai_optimization": {
    "enabled": true,
    "variable_rate_application": true,
    "wind_drift_compensation": true,
    "target_precision_meters": 0.5
  },
  "schedule": {
    "start_time": "2024-12-01T06:00:00Z",
    "weather_constraints": {
      "max_wind_speed_kph": 12,
      "min_temperature_celsius": 10,
      "max_temperature_celsius": 30,
      "no_precipitation": true,
      "no_rain_forecast_hours": 4
    }
  }
}
```

**Response (201 Created):**
```json
{
  "mission_id": "spray_47",
  "status": "scheduled",
  "estimated_duration_minutes": 32,
  "total_area_hectares": 12.4,
  "estimated_chemical_usage_liters": 6.2,
  "chemical_savings_vs_broadcast_percent": 65,
  "cost_savings_usd": 847,
  "created_at": "2024-12-01T05:30:00Z",
  "scheduled_start": "2024-12-01T06:00:00Z",
  "compliance": {
    "regulatory_approval_required": true,
    "buffer_zones_applied": true,
    "spray_log_id": "log_2847"
  }
}
```

---

### Get Crop Health Analysis

Retrieve AI-powered crop health analysis for a field.

```http
GET /agriculture/fields/{field_id}/health
Authorization: Bearer {token}
```

**Query Parameters:**
- `survey_id` (optional): Specific survey to analyze
- `include_historical` (optional): Include historical trends (true/false)

**Response (200 OK):**
```json
{
  "field_id": "field_b23",
  "field_name": "Field B-23",
  "crop_type": "spring_wheat",
  "area_hectares": 245,
  "survey_date": "2024-12-01T14:23:00Z",
  "survey_id": "survey_8472",
  "overall_health": {
    "score_percent": 82,
    "rating": "good",
    "trend": "stable",
    "comparison_to_regional_average": "+5%"
  },
  "vegetation_indices": {
    "ndvi": {
      "average": 0.72,
      "min": 0.45,
      "max": 0.87,
      "standard_deviation": 0.08
    },
    "ndre": {
      "average": 0.31,
      "description": "Normalized Difference Red Edge - chlorophyll content"
    },
    "gndvi": {
      "average": 0.68,
      "description": "Green NDVI - nitrogen status"
    }
  },
  "health_zones": {
    "healthy": {
      "area_hectares": 191.1,
      "percent": 78
    },
    "stressed": {
      "area_hectares": 36.8,
      "percent": 15
    },
    "disease": {
      "area_hectares": 12.3,
      "percent": 5
    },
    "critical": {
      "area_hectares": 4.9,
      "percent": 2
    }
  },
  "ai_detections": [
    {
      "issue_type": "nutrient_deficiency",
      "nutrient": "nitrogen",
      "severity": "moderate",
      "affected_area_hectares": 12.4,
      "location": {
        "latitude": 41.9878,
        "longitude": -93.6195,
        "polygon": [
          {"lat": 41.9876, "lon": -93.6201},
          {"lat": 41.9880, "lon": -93.6190}
        ]
      },
      "confidence_percent": 94,
      "recommendation": {
        "action": "precision_fertilizer_application",
        "product": "Urea (46-0-0)",
        "rate_kg_ha": 50,
        "timing": "within 7 days",
        "expected_yield_impact_percent": -8
      }
    },
    {
      "issue_type": "irrigation_stress",
      "severity": "low",
      "affected_area_hectares": 3.2,
      "dry_spot_count": 5,
      "location": {
        "latitude": 41.9872,
        "longitude": -93.6185
      },
      "confidence_percent": 87,
      "recommendation": {
        "action": "irrigation_system_inspection",
        "details": "Possible sprinkler malfunction or clogged nozzles",
        "priority": "medium"
      }
    }
  ],
  "growth_stage": {
    "current_stage": "flowering",
    "days_to_next_stage": 12,
    "percent_complete": 67
  },
  "yield_prediction": {
    "estimated_yield_tonnes_per_hectare": 4.2,
    "confidence_range": [3.9, 4.5],
    "confidence_percent": 89,
    "comparison_to_5year_average": "+7%",
    "factors": {
      "weather_impact": "positive",
      "soil_moisture": "adequate",
      "pest_pressure": "low",
      "disease_pressure": "moderate"
    }
  },
  "imagery_available": {
    "rgb": true,
    "ndvi": true,
    "ndre": true,
    "thermal": true,
    "elevation": true
  }
}
```

---

### Get Field NDVI Map

Retrieve NDVI (crop health) raster imagery for a field.

```http
GET /agriculture/fields/{field_id}/ndvi-map
Authorization: Bearer {token}
```

**Query Parameters:**
- `survey_id` (optional): Specific survey
- `format` (optional): `geotiff`, `png`, `jpg` (default: geotiff)
- `resolution_meters` (optional): Pixel resolution (default: 0.1)

**Response (200 OK):**
```json
{
  "field_id": "field_b23",
  "survey_id": "survey_8472",
  "survey_date": "2024-12-01T14:23:00Z",
  "format": "geotiff",
  "resolution_meters": 0.1,
  "download_url": "https://storage.acme.ai/ndvi/field_b23_20241201.tif",
  "expires_at": "2024-12-01T16:23:00Z",
  "metadata": {
    "epsg_code": 4326,
    "bounds": {
      "north": 41.9880,
      "south": 41.9870,
      "east": -93.6180,
      "west": -93.6201
    },
    "statistics": {
      "min": 0.45,
      "max": 0.87,
      "mean": 0.72,
      "std_dev": 0.08
    }
  }
}
```

---

### Log Spray Application

Record completed spray operation for regulatory compliance.

```http
POST /agriculture/spray-logs
Authorization: Bearer {token}
Content-Type: application/json

{
  "mission_id": "spray_47",
  "drone_id": "B-12",
  "field_id": "field_c47",
  "operator_id": "operator_123",
  "application_date": "2024-12-01T06:15:00Z",
  "chemical": {
    "product_name": "Azoxystrobin 25% SC",
    "epa_registration_number": "100-123",
    "active_ingredient": "Azoxystrobin",
    "concentration_percent": 25,
    "type": "fungicide"
  },
  "application_details": {
    "area_treated_hectares": 12.4,
    "total_volume_applied_liters": 6.2,
    "application_rate_lha": 0.5,
    "target_pest_disease": "Fusarium head blight",
    "growth_stage": "flowering",
    "method": "precision_aerial_variable_rate"
  },
  "weather_conditions": {
    "temperature_celsius": 18,
    "wind_speed_kph": 8,
    "wind_direction_degrees": 270,
    "humidity_percent": 60,
    "precipitation": false
  },
  "gps_track": {
    "geojson_url": "https://storage.acme.ai/tracks/spray_47.geojson"
  },
  "regulatory_compliance": {
    "rei_hours": 12,
    "phi_days": 14,
    "buffer_zones_respected": true,
    "applicator_license": "AG-12345-IA"
  }
}
```

**Response (201 Created):**
```json
{
  "spray_log_id": "log_2847",
  "status": "recorded",
  "compliance_status": "compliant",
  "auto_reported_to": ["USDA", "EPA", "Iowa_Dept_Agriculture"],
  "created_at": "2024-12-01T06:45:00Z",
  "message": "Spray application logged and reported successfully"
}
```

---

## Maintenance & Diagnostics

### Get Maintenance Schedule

Retrieve upcoming maintenance requirements for a drone.

```http
GET /fleet/drones/{drone_id}/maintenance/schedule
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "current_flight_hours": 342.5,
  "health_score": 98,
  "upcoming_maintenance": [
    {
      "maintenance_type": "routine_inspection",
      "description": "100-hour routine inspection",
      "due_in_flight_hours": 57.5,
      "due_date_estimated": "2024-12-18",
      "priority": "normal",
      "estimated_downtime_hours": 2
    },
    {
      "maintenance_type": "battery_replacement",
      "description": "Battery end of life - 200 charge cycles",
      "due_in_charge_cycles": 53,
      "due_date_estimated": "2025-01-15",
      "priority": "normal",
      "estimated_cost_usd": 450
    }
  ],
  "overdue_maintenance": [],
  "predictive_alerts": [
    {
      "component": "motor_3",
      "issue": "Elevated vibration detected",
      "severity": "low",
      "confidence_percent": 72,
      "recommendation": "Monitor for next 10 flight hours. Consider early inspection if vibration increases.",
      "detected_at": "2024-11-28T10:30:00Z"
    }
  ],
  "last_maintenance": {
    "date": "2024-11-15T08:30:00Z",
    "type": "routine_inspection",
    "performed_by": "tech_456",
    "notes": "All systems nominal. Cleaned sensors. Calibrated gimbal."
  }
}
```

---

### Log Maintenance Activity

Record completed maintenance work.

```http
POST /fleet/drones/{drone_id}/maintenance/log
Authorization: Bearer {token}
Content-Type: application/json

{
  "maintenance_type": "routine_inspection",
  "performed_by": "tech_456",
  "performed_at": "2024-11-15T08:30:00Z",
  "duration_hours": 2,
  "checklist_completed": true,
  "components_inspected": [
    "motors",
    "propellers",
    "battery",
    "sensors",
    "spray_system",
    "gimbal"
  ],
  "parts_replaced": [
    {
      "part_name": "Propeller",
      "part_number": "PROP-X7-01",
      "quantity": 1,
      "reason": "Minor crack detected",
      "cost_usd": 45
    }
  ],
  "issues_found": [
    {
      "component": "motor_3",
      "issue": "Slight vibration",
      "severity": "low",
      "action_taken": "Recalibrated and monitored",
      "resolved": true
    }
  ],
  "notes": "All systems nominal. Cleaned multispectral sensors. Calibrated gimbal. Recommend monitoring motor 3 vibration.",
  "next_maintenance_due_hours": 100,
  "cleared_for_flight": true
}
```

**Response (201 Created):**
```json
{
  "maintenance_log_id": "maint_8472",
  "drone_id": "A-23",
  "status": "recorded",
  "drone_status_updated": "operational",
  "next_maintenance_due": "2024-12-18",
  "message": "Maintenance logged successfully. Drone cleared for flight."
}
```

---

### Run Diagnostics

Execute comprehensive diagnostic tests on a drone.

```http
POST /fleet/drones/{drone_id}/diagnostics/run
Authorization: Bearer {token}
Content-Type: application/json

{
  "test_suite": "pre_flight",
  "tests": [
    "motors",
    "sensors",
    "battery",
    "communication",
    "gps",
    "camera_systems",
    "spray_system"
  ]
}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "diagnostic_id": "diag_9472",
  "started_at": "2024-12-01T08:00:00Z",
  "completed_at": "2024-12-01T08:03:24Z",
  "overall_status": "pass",
  "health_score": 98,
  "results": [
    {
      "test": "motors",
      "status": "pass",
      "details": {
        "motor_1": {"rpm": 6800, "temperature": 25, "status": "pass"},
        "motor_2": {"rpm": 6750, "temperature": 26, "status": "pass"},
        "motor_3": {"rpm": 6820, "temperature": 25, "status": "pass", "note": "Slight vibration within tolerance"},
        "motor_4": {"rpm": 6790, "temperature": 27, "status": "pass"}
      }
    },
    {
      "test": "sensors",
      "status": "pass",
      "details": {
        "gps": {"fix": "rtk", "satellites": 18, "status": "pass"},
        "imu": {"calibration": "good", "status": "pass"},
        "compass": {"calibration": "good", "interference": "none", "status": "pass"},
        "barometer": {"reading": 1013.25, "status": "pass"}
      }
    },
    {
      "test": "battery",
      "status": "pass",
      "details": {
        "voltage": 25.2,
        "capacity_percent": 94,
        "health_percent": 94,
        "charge_cycles": 147,
        "status": "pass"
      }
    },
    {
      "test": "camera_systems",
      "status": "pass",
      "details": {
        "rgb_camera": {"status": "pass", "gimbal": "calibrated"},
        "multispectral": {"status": "pass", "bands": 5},
        "thermal": {"status": "pass", "calibration": "good"}
      }
    },
    {
      "test": "spray_system",
      "status": "pass",
      "details": {
        "tank_level": 0,
        "nozzles": {"count": 4, "status": "all_functional"},
        "pump": {"status": "operational"},
        "flow_sensors": {"status": "calibrated"}
      }
    },
    {
      "test": "communication",
      "status": "pass",
      "details": {
        "telemetry_link": {"signal_strength": -65, "status": "excellent"},
        "command_link": {"latency_ms": 12, "status": "good"}
      }
    }
  ],
  "warnings": [
    "Motor 3 vibration slightly elevated - monitor during next flight"
  ],
  "errors": [],
  "flight_clearance": "approved"
}
```

---

### Get Component Health

Retrieve detailed health metrics for specific drone components.

```http
GET /fleet/drones/{drone_id}/health
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "drone_id": "A-23",
  "overall_health_score": 98,
  "status": "operational",
  "last_diagnostic": "2024-12-01T08:00:00Z",
  "components": {
    "motors": {
      "health_score": 97,
      "status": "good",
      "flight_hours": 342.5,
      "details": [
        {
          "motor_id": 1,
          "health_score": 98,
          "flight_hours": 342.5,
          "avg_temperature": 42,
          "vibration_level": "normal",
          "predicted_replacement_hours": 1157.5
        },
        {
          "motor_id": 3,
          "health_score": 95,
          "flight_hours": 342.5,
          "avg_temperature": 44,
          "vibration_level": "slightly_elevated",
          "predicted_replacement_hours": 957.5,
          "note": "AI predicts potential issue in 600-800 flight hours"
        }
      ]
    },
    "battery": {
      "health_score": 94,
      "status": "good",
      "capacity_percent": 94,
      "charge_cycles": 147,
      "max_charge_cycles": 200,
      "predicted_replacement_date": "2025-01-15",
      "degradation_rate_percent_per_month": 0.8
    },
    "sensors": {
      "health_score": 100,
      "status": "excellent",
      "gps": {"status": "nominal", "last_calibration": "2024-11-15"},
      "imu": {"status": "nominal", "last_calibration": "2024-11-15"},
      "compass": {"status": "nominal", "last_calibration": "2024-11-15"}
    },
    "camera_systems": {
      "health_score": 98,
      "status": "good",
      "rgb_camera": {"status": "nominal", "lens_condition": "clean"},
      "multispectral": {"status": "nominal", "last_calibration": "2024-11-20"},
      "thermal": {"status": "nominal", "last_calibration": "2024-11-20"}
    },
    "spray_system": {
      "health_score": 96,
      "status": "good",
      "pump": {"status": "nominal", "hours_since_service": 42},
      "nozzles": {"status": "good", "last_inspection": "2024-11-15"},
      "tank": {"status": "good", "cleaning_due": false}
    },
    "airframe": {
      "health_score": 99,
      "status": "excellent",
      "flight_hours": 342.5,
      "landings": 847,
      "inspection_due_hours": 57.5
    }
  },
  "ai_predictions": [
    {
      "component": "motor_3",
      "prediction": "Potential bearing wear detected",
      "confidence": 72,
      "estimated_issue_in_hours": 700,
      "recommendation": "Schedule early inspection at 400 hour mark"
    }
  ]
}
```

---

## Analytics & Reporting

### Get Fleet Analytics

Retrieve fleet-wide performance analytics.

```http
GET /analytics/fleet
Authorization: Bearer {token}
```

**Query Parameters:**
- `start_date` (required): ISO 8601 date
- `end_date` (required): ISO 8601 date
- `farm_id` (optional): Filter by farm
- `region` (optional): Filter by region

**Response (200 OK):**
```json
{
  "period": {
    "start_date": "2024-11-01",
    "end_date": "2024-12-01",
    "days": 30
  },
  "fleet_summary": {
    "total_drones": 50,
    "avg_operational_percent": 94,
    "total_flight_hours": 1247.3,
    "total_missions": 342,
    "mission_success_rate_percent": 98.5
  },
  "operational_metrics": {
    "area_surveyed_hectares": 12450,
    "area_sprayed_hectares": 847,
    "fields_monitored": 156,
    "irrigation_systems_checked": 34,
    "avg_mission_duration_minutes": 24.3
  },
  "agricultural_impact": {
    "crop_health_avg_percent": 83,
    "ai_detections": {
      "pest_outbreaks": 23,
      "disease_outbreaks": 12,
      "nutrient_deficiencies": 47,
      "irrigation_issues": 18
    },
    "interventions": {
      "precision_sprays": 45,
      "fertilizer_applications": 23,
      "early_detections": 67
    }
  },
  "economic_impact": {
    "chemical_savings_usd": 127400,
    "chemical_reduction_percent": 45,
    "yield_improvement_percent": 12,
    "estimated_yield_value_usd": 847000,
    "early_detection_loss_prevention_usd": 234000,
    "roi_per_dollar": 4.20
  },
  "efficiency_metrics": {
    "battery_efficiency_percent": 92,
    "avg_response_time_minutes": 3.2,
    "ai_autonomy_rate_percent": 89,
    "avg_spray_accuracy_meters": 0.5
  },
  "maintenance": {
    "total_maintenance_hours": 87,
    "unscheduled_maintenance_events": 3,
    "avg_downtime_hours_per_drone": 1.8,
    "maintenance_cost_usd": 12400
  },
  "safety": {
    "incidents": 0,
    "near_misses": 0,
    "ai_collision_preventions": 12,
    "emergency_landings": 2,
    "regulatory_violations": 0
  }
}
```

---

### Get Crop Analytics

Retrieve agricultural performance analytics across all farms.

```http
GET /analytics/agriculture
Authorization: Bearer {token}
```

**Query Parameters:**
- `start_date` (required): ISO 8601 date
- `end_date` (required): ISO 8601 date
- `crop_type` (optional): Filter by crop type
- `farm_id` (optional): Filter by farm

**Response (200 OK):**
```json
{
  "period": {
    "start_date": "2024-11-01",
    "end_date": "2024-12-01"
  },
  "farms_monitored": 47,
  "total_area_hectares": 85000,
  "crop_types": ["wheat", "corn", "soybeans", "rice"],
  "overall_crop_health": {
    "average_score_percent": 83,
    "healthy_percent": 78,
    "stressed_percent": 15,
    "diseased_percent": 5,
    "critical_percent": 2,
    "trend": "improving"
  },
  "by_crop_type": [
    {
      "crop": "wheat",
      "area_hectares": 32000,
      "avg_health_percent": 83,
      "predicted_yield_tonnes_per_ha": 4.2,
      "yield_vs_5year_avg_percent": 7,
      "issues": {
        "pest_outbreaks": 8,
        "disease_incidents": 5,
        "nutrient_deficiencies": 18
      }
    },
    {
      "crop": "corn",
      "area_hectares": 28000,
      "avg_health_percent": 76,
      "predicted_yield_tonnes_per_ha": 9.8,
      "yield_vs_5year_avg_percent": 12,
      "issues": {
        "pest_outbreaks": 6,
        "disease_incidents": 3,
        "nutrient_deficiencies": 12
      }
    }
  ],
  "ai_performance": {
    "total_detections": 156,
    "prediction_accuracy_percent": 93,
    "early_detection_rate_percent": 87,
    "false_positive_rate_percent": 5
  },
  "interventions": {
    "precision_sprays": 45,
    "area_treated_hectares": 847,
    "chemical_used_liters": 4234,
    "chemical_savings_vs_broadcast_percent": 45,
    "cost_savings_usd": 127400
  },
  "yield_predictions": {
    "total_estimated_yield_tonnes": 587000,
    "improvement_vs_baseline_percent": 12,
    "confidence_percent": 89,
    "value_estimate_usd": 87000000
  },
  "regional_comparison": [
    {
      "region": "North America",
      "avg_health_percent": 83,
      "avg_yield_tonnes_per_ha": 4.2,
      "issues_per_1000ha": 12
    },
    {
      "region": "South America",
      "avg_health_percent": 79,
      "avg_yield_tonnes_per_ha": 3.8,
      "issues_per_1000ha": 18
    },
    {
      "region": "Asia",
      "avg_health_percent": 88,
      "avg_yield_tonnes_per_ha": 5.1,
      "issues_per_1000ha": 8
    }
  ]
}
```

---

### Export Report

Generate and export comprehensive reports.

```http
POST /analytics/reports/export
Authorization: Bearer {token}
Content-Type: application/json

{
  "report_type": "fleet_performance",
  "period": {
    "start_date": "2024-11-01",
    "end_date": "2024-12-01"
  },
  "format": "pdf",
  "sections": [
    "executive_summary",
    "fleet_operations",
    "agricultural_impact",
    "economic_roi",
    "maintenance_summary",
    "safety_compliance"
  ],
  "filters": {
    "farm_ids": ["farm_miller_iowa"],
    "crop_types": ["wheat", "corn"]
  },
  "include_charts": true,
  "include_maps": true
}
```

**Response (202 Accepted):**
```json
{
  "report_id": "rpt_8472",
  "status": "generating",
  "estimated_completion_seconds": 45,
  "message": "Report generation started"
}
```

**Get Report Status:**
```http
GET /analytics/reports/{report_id}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "report_id": "rpt_8472",
  "status": "completed",
  "format": "pdf",
  "download_url": "https://storage.acme.ai/reports/rpt_8472.pdf",
  "expires_at": "2024-12-08T14:30:00Z",
  "file_size_bytes": 2847392,
  "generated_at": "2024-12-01T14:30:45Z"
}
```

---

## Weather Integration

### Get Weather Forecast

Retrieve weather forecast for farm locations.

```http
GET /weather/forecast
Authorization: Bearer {token}
```

**Query Parameters:**
- `farm_id` (required): Farm identifier
- `hours` (optional): Forecast hours (default: 48, max: 168)

**Response (200 OK):**
```json
{
  "farm_id": "farm_miller_iowa",
  "location": {
    "latitude": 41.9850,
    "longitude": -93.6210
  },
  "current": {
    "timestamp": "2024-12-01T14:00:00Z",
    "temperature_celsius": 22,
    "feels_like_celsius": 20,
    "humidity_percent": 65,
    "pressure_hpa": 1013.25,
    "wind_speed_kph": 6,
    "wind_direction_degrees": 315,
    "wind_gust_kph": 12,
    "precipitation_mm": 0,
    "cloud_cover_percent": 35,
    "visibility_meters": 10000,
    "uv_index": 4
  },
  "hourly_forecast": [
    {
      "timestamp": "2024-12-01T15:00:00Z",
      "temperature_celsius": 23,
      "wind_speed_kph": 8,
      "wind_direction_degrees": 320,
      "precipitation_probability_percent": 10,
      "precipitation_mm": 0,
      "conditions": "partly_cloudy",
      "spray_suitability": "optimal"
    },
    {
      "timestamp": "2024-12-01T16:00:00Z",
      "temperature_celsius": 24,
      "wind_speed_kph": 12,
      "wind_direction_degrees": 330,
      "precipitation_probability_percent": 20,
      "precipitation_mm": 0,
      "conditions": "partly_cloudy",
      "spray_suitability": "marginal"
    },
    {
      "timestamp": "2024-12-01T17:00:00Z",
      "temperature_celsius": 22,
      "wind_speed_kph": 18,
      "wind_direction_degrees": 340,
      "precipitation_probability_percent": 60,
      "precipitation_mm": 2.3,
      "conditions": "rain",
      "spray_suitability": "unsuitable"
    }
  ],
  "spray_windows": {
    "next_24_hours": [
      {
        "start": "2024-12-01T15:00:00Z",
        "end": "2024-12-01T16:00:00Z",
        "duration_hours": 1,
        "suitability": "optimal"
      },
      {
        "start": "2024-12-02T06:00:00Z",
        "end": "2024-12-02T14:00:00Z",
        "duration_hours": 8,
        "suitability": "optimal"
      }
    ]
  },
  "alerts": [
    {
      "type": "rain",
      "severity": "moderate",
      "start_time": "2024-12-01T17:00:00Z",
      "duration_hours": 4,
      "message": "Rain expected. Delay spray operations."
    },
    {
      "type": "wind",
      "severity": "low",
      "start_time": "2024-12-01T16:00:00Z",
      "duration_hours": 2,
      "message": "Wind speeds increasing to 18 kph. Monitor spray drift."
    }
  ]
}
```

---

### Get Spray Recommendations

AI-powered spray timing recommendations based on weather.

```http
GET /weather/spray-recommendations
Authorization: Bearer {token}
```

**Query Parameters:**
- `farm_id` (required): Farm identifier
- `field_ids` (optional): Comma-separated field IDs
- `hours_ahead` (optional): Planning window (default: 48)

**Response (200 OK):**
```json
{
  "farm_id": "farm_miller_iowa",
  "analysis_timestamp": "2024-12-01T14:00:00Z",
  "optimal_windows": [
    {
      "window_id": 1,
      "start_time": "2024-12-02T06:00:00Z",
      "end_time": "2024-12-02T14:00:00Z",
      "duration_hours": 8,
      "suitability_score": 95,
      "conditions": {
        "avg_temperature_celsius": 20,
        "avg_wind_speed_kph": 6,
        "precipitation_probability_percent": 5,
        "humidity_percent": 60
      },
      "recommendation": "Excellent conditions for spraying. All parameters optimal.",
      "estimated_area_possible_hectares": 450
    }
  ],
  "marginal_windows": [
    {
      "window_id": 2,
      "start_time": "2024-12-01T15:00:00Z",
      "end_time": "2024-12-01T16:00:00Z",
      "duration_hours": 1,
      "suitability_score": 65,
      "conditions": {
        "avg_temperature_celsius": 23,
        "avg_wind_speed_kph": 12,
        "precipitation_probability_percent": 15,
        "humidity_percent": 55
      },
      "recommendation": "Marginal conditions. Wind increasing. Monitor drift.",
      "constraints": ["wind_speed_elevated"]
    }
  ],
  "unsuitable_periods": [
    {
      "start_time": "2024-12-01T17:00:00Z",
      "end_time": "2024-12-01T21:00:00Z",
      "reasons": ["precipitation_forecast", "wind_too_high"],
      "recommendation": "Do not spray. Rain and high winds expected."
    }
  ],
  "ai_recommendation": {
    "best_time_to_spray": "2024-12-02T08:00:00Z",
    "confidence_percent": 92,
    "reasoning": "Optimal temperature, low wind, no precipitation forecast, ideal humidity for chemical efficacy."
  }
}
```

---

## Webhooks & Events

### Register Webhook

Subscribe to real-time events via webhooks.

```http
POST /webhooks
Authorization: Bearer {token}
Content-Type: application/json

{
  "url": "https://your-server.com/acme-webhooks",
  "events": [
    "mission.started",
    "mission.completed",
    "mission.failed",
    "drone.battery_low",
    "drone.maintenance_due",
    "ai.issue_detected",
    "weather.spray_window_opening",
    "compliance.spray_logged"
  ],
  "filters": {
    "farm_ids": ["farm_miller_iowa"],
    "drone_ids": ["A-23", "B-12"]
  },
  "secret": "your_webhook_secret_for_verification"
}
```

**Response (201 Created):**
```json
{
  "webhook_id": "wh_8472",
  "url": "https://your-server.com/acme-webhooks",
  "events": ["mission.started", "mission.completed"],
  "status": "active",
  "created_at": "2024-12-01T14:30:00Z"
}
```

---

### Webhook Event Examples

**Mission Started:**
```json
{
  "event_type": "mission.started",
  "event_id": "evt_94728",
  "timestamp": "2024-12-01T14:23:00Z",
  "data": {
    "mission_id": "m_42",
    "mission_type": "crop_survey",
    "drone_id": "A-23",
    "farm_id": "farm_miller_iowa",
    "field_ids": ["field_b23"],
    "estimated_duration_minutes": 18
  }
}
```

**AI Issue Detected:**
```json
{
  "event_type": "ai.issue_detected",
  "event_id": "evt_94729",
  "timestamp": "2024-12-01T14:28:00Z",
  "data": {
    "mission_id": "m_42",
    "drone_id": "A-23",
    "field_id": "field_b23",
    "issue_type": "nutrient_deficiency",
    "severity": "moderate",
    "affected_area_hectares": 12.4,
    "location": {
      "latitude": 41.9878,
      "longitude": -93.6195
    },
    "confidence_percent": 94,
    "recommendation": "Precision fertilizer application recommended"
  }
}
```

**Battery Low:**
```json
{
  "event_type": "drone.battery_low",
  "event_id": "evt_94730",
  "timestamp": "2024-12-01T14:35:00Z",
  "data": {
    "drone_id": "A-23",
    "battery_percent": 22,
    "mission_id": "m_42",
    "action": "returning_to_base",
    "estimated_landing_minutes": 5
  }
}
```

---

## Error Codes

### HTTP Status Codes

- **200 OK**: Request successful
- **201 Created**: Resource created successfully
- **202 Accepted**: Request accepted, processing asynchronously
- **400 Bad Request**: Invalid request parameters
- **401 Unauthorized**: Authentication required or invalid token
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Request conflicts with current state
- **422 Unprocessable Entity**: Validation error
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error
- **503 Service Unavailable**: Service temporarily unavailable

---

### Error Response Format

```json
{
  "error": {
    "code": "DRONE_NOT_FOUND",
    "message": "Drone with ID 'A-99' does not exist",
    "details": {
      "drone_id": "A-99",
      "available_drones": 50
    },
    "request_id": "req_8472",
    "timestamp": "2024-12-01T14:30:00Z"
  }
}
```

---

### Common Error Codes

| Code | Description |
|------|-------------|
| `INVALID_TOKEN` | Authentication token is invalid or expired |
| `INSUFFICIENT_PERMISSIONS` | User lacks required permissions |
| `DRONE_NOT_FOUND` | Specified drone does not exist |
| `MISSION_NOT_FOUND` | Specified mission does not exist |
| `DRONE_UNAVAILABLE` | Drone is not available for operation |
| `WEATHER_UNSUITABLE` | Weather conditions prevent operation |
| `BATTERY_TOO_LOW` | Insufficient battery for mission |
| `GEOFENCE_VIOLATION` | Mission path violates geofence |
| `MAINTENANCE_REQUIRED` | Drone requires maintenance before flight |
| `INVALID_WAYPOINTS` | Mission waypoints are invalid |
| `RATE_LIMIT_EXCEEDED` | API rate limit exceeded |

---

## Rate Limits

- **Standard Tier**: 1,000 requests/hour
- **Professional Tier**: 10,000 requests/hour
- **Enterprise Tier**: Custom limits

**Rate Limit Headers:**
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 847
X-RateLimit-Reset: 1701446400
```

---

## Versioning

API versioning is handled via the URL path (`/v2/`). Breaking changes will result in a new version.

**Current Version**: v2.1.0
**Supported Versions**: v2.x
**Deprecated Versions**: v1.x (sunset: 2025-06-01)

---

## Support

- **Documentation**: https://docs.acme.ai
- **API Status**: https://status.acme.ai
- **Support Email**: api-support@acme.ai
- **Developer Portal**: https://developers.acme.ai

---

**Copyright © 2024 Acme.ai. All rights reserved.**
