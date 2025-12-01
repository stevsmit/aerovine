# AeroVine Database Schema

**PostgreSQL + PostGIS + TimescaleDB Architecture**

---

## Table of Contents

1. [Database Overview](#database-overview)
2. [Core Tables](#core-tables)
3. [Agricultural Tables](#agricultural-tables)
4. [Telemetry & Time-Series](#telemetry--time-series)
5. [Analytics & ML Tables](#analytics--ml-tables)
6. [Relationships & Indexes](#relationships--indexes)
7. [Sample Queries](#sample-queries)
8. [Data Lifecycle](#data-lifecycle)

---

## Database Overview

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Primary Database** | PostgreSQL 13+ | Relational data (users, farms, drones) |
| **Geospatial Extension** | PostGIS 3.0+ | Geographic data (field boundaries, flight paths) |
| **Time-Series Database** | TimescaleDB | High-frequency telemetry (GPS, battery, sensors) |
| **Cache** | Redis 6+ | Session management, real-time drone status |
| **Object Storage** | AWS S3 / GCS / Azure Blob | Images (multispectral, RGB, thermal) |
| **Search** | Elasticsearch (optional) | Full-text search for farms, alerts |

### Database Sizing

| Environment | Storage | Connections | Backup |
|-------------|---------|-------------|--------|
| **Development** | 50 GB | 50 | Daily |
| **Staging** | 200 GB | 100 | Daily |
| **Production** | 2 TB+ | 500 | Hourly incremental, daily full |

---

## Core Tables

### 1. `users`

User accounts for vineyard owners, pilots, and administrators.

```sql
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL DEFAULT 'customer', -- 'customer', 'pilot', 'admin', 'analyst'
    company_name VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    metadata JSONB -- Additional user preferences
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
```

**Sample Data:**
```sql
INSERT INTO users VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'john.smith@napavalley.com',
    '$2b$12$...',  -- bcrypt hash
    'John',
    'Smith',
    '+1-707-555-0123',
    'customer',
    'Napa Valley Estate Winery',
    TRUE,
    FALSE,
    NULL,
    '2024-01-15 08:30:00',
    '2024-01-15 08:30:00',
    '2025-12-01 09:15:00',
    TRUE,
    'America/Los_Angeles',
    'en',
    '{"subscription_tier": "premium", "alert_preferences": {"email": true, "sms": true, "push": true}}'
);
```

---

### 2. `organizations`

Companies that own multiple farms/vineyards.

```sql
CREATE TABLE organizations (
    org_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_name VARCHAR(255) NOT NULL,
    org_type VARCHAR(50), -- 'winery', 'farm_cooperative', 'agricultural_enterprise'
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    website VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    billing_email VARCHAR(255),
    subscription_tier VARCHAR(50) DEFAULT 'basic', -- 'basic', 'premium', 'enterprise'
    subscription_status VARCHAR(50) DEFAULT 'active', -- 'active', 'suspended', 'cancelled'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_orgs_name ON organizations(org_name);
CREATE INDEX idx_orgs_subscription ON organizations(subscription_tier, subscription_status);
```

---

### 3. `user_organizations`

Many-to-many relationship: users can belong to multiple organizations.

```sql
CREATE TABLE user_organizations (
    user_org_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    org_id UUID NOT NULL REFERENCES organizations(org_id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member', -- 'owner', 'admin', 'member', 'viewer'
    joined_at TIMESTAMP DEFAULT NOW(),
    is_primary BOOLEAN DEFAULT FALSE,
    UNIQUE(user_id, org_id)
);

CREATE INDEX idx_user_orgs_user ON user_organizations(user_id);
CREATE INDEX idx_user_orgs_org ON user_organizations(org_id);
```

---

### 4. `drones`

Physical drone fleet registry.

```sql
CREATE TABLE drones (
    drone_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drone_serial VARCHAR(100) UNIQUE NOT NULL,
    drone_name VARCHAR(100), -- 'V-08', 'A-23', etc.
    model VARCHAR(100) DEFAULT 'AeroVine-X7-AG',
    manufacturer VARCHAR(100) DEFAULT 'AeroVine',
    org_id UUID REFERENCES organizations(org_id),
    purchase_date DATE,
    last_maintenance_date DATE,
    next_maintenance_due DATE,
    total_flight_hours DECIMAL(10, 2) DEFAULT 0,
    total_missions_completed INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'available', -- 'available', 'in_flight', 'charging', 'maintenance', 'retired'
    battery_health_percentage INTEGER DEFAULT 100,
    firmware_version VARCHAR(50),
    last_known_location GEOGRAPHY(POINT, 4326), -- PostGIS: lat/lon
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB -- Sensor configs, calibration data, etc.
);

CREATE INDEX idx_drones_serial ON drones(drone_serial);
CREATE INDEX idx_drones_org ON drones(org_id);
CREATE INDEX idx_drones_status ON drones(status);
CREATE INDEX idx_drones_location ON drones USING GIST(last_known_location);
```

**Sample Data:**
```sql
INSERT INTO drones VALUES (
    '660e8400-e29b-41d4-a716-446655440001',
    'AV-X7-2024-0108',
    'V-08',
    'AeroVine-X7-AG',
    'AeroVine',
    '770e8400-e29b-41d4-a716-446655440002',
    '2024-01-15',
    '2024-11-01',
    '2025-02-01',
    247.5,
    156,
    'in_flight',
    95,
    '2.4.1',
    ST_GeogFromText('POINT(-122.4194 38.2919)'), -- Napa Valley coordinates
    '2024-01-15 10:00:00',
    '2025-12-01 14:32:15',
    '{"sensors": {"rgb": "Sony IMX183", "multispectral": "MicaSense RedEdge-MX", "thermal": "FLIR Lepton 3.5"}, "max_payload_kg": 3.5}'
);
```

---

## Agricultural Tables

### 5. `farms`

Individual farms or vineyards.

```sql
CREATE TABLE farms (
    farm_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES organizations(org_id) ON DELETE CASCADE,
    farm_name VARCHAR(255) NOT NULL,
    farm_type VARCHAR(50), -- 'vineyard', 'orchard', 'row_crop', 'mixed'
    primary_crop VARCHAR(100), -- 'wine_grapes', 'almonds', 'wheat', etc.
    total_area_hectares DECIMAL(10, 4),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50) DEFAULT 'UTC',
    farm_boundary GEOGRAPHY(POLYGON, 4326), -- PostGIS: farm perimeter
    elevation_meters DECIMAL(8, 2),
    soil_type VARCHAR(100),
    irrigation_system VARCHAR(100), -- 'drip', 'sprinkler', 'flood', 'none'
    organic_certified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_farms_org ON farms(org_id);
CREATE INDEX idx_farms_name ON farms(farm_name);
CREATE INDEX idx_farms_type ON farms(farm_type);
CREATE INDEX idx_farms_location ON farms(latitude, longitude);
CREATE INDEX idx_farms_boundary ON farms USING GIST(farm_boundary);
```

---

### 6. `fields`

Subdivisions within farms (blocks, parcels, vineyard rows).

```sql
CREATE TABLE fields (
    field_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id UUID NOT NULL REFERENCES farms(farm_id) ON DELETE CASCADE,
    field_name VARCHAR(255) NOT NULL, -- 'Block 7', 'East Vineyard', 'Parcel A'
    field_type VARCHAR(50), -- 'vineyard_block', 'orchard_section', 'crop_field'
    area_hectares DECIMAL(10, 4),
    field_boundary GEOGRAPHY(POLYGON, 4326), -- PostGIS
    crop_variety VARCHAR(100), -- 'Cabernet Sauvignon', 'Chardonnay', etc.
    planting_date DATE,
    vine_age_years INTEGER,
    vine_density_per_hectare INTEGER, -- For vineyards
    row_spacing_meters DECIMAL(5, 2),
    vine_spacing_meters DECIMAL(5, 2),
    trellis_type VARCHAR(100), -- 'VSP', 'Geneva Double Curtain', etc.
    rootstock VARCHAR(100),
    clone VARCHAR(100),
    expected_yield_tons_per_hectare DECIMAL(6, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_fields_farm ON fields(farm_id);
CREATE INDEX idx_fields_name ON fields(field_name);
CREATE INDEX idx_fields_crop ON fields(crop_variety);
CREATE INDEX idx_fields_boundary ON fields USING GIST(field_boundary);
```

**Sample Data:**
```sql
INSERT INTO fields VALUES (
    '880e8400-e29b-41d4-a716-446655440003',
    '990e8400-e29b-41d4-a716-446655440004',
    'Block 7',
    'vineyard_block',
    2.3,
    ST_GeogFromText('POLYGON((-122.4200 38.2920, -122.4190 38.2920, -122.4190 38.2910, -122.4200 38.2910, -122.4200 38.2920))'),
    'Cabernet Sauvignon',
    '2010-04-15',
    15,
    2500,
    2.4,
    1.2,
    'Vertical Shoot Positioning (VSP)',
    '110R',
    'Clone 337',
    3.2,
    TRUE,
    '2024-02-01 10:00:00',
    '2025-12-01 08:30:00',
    '{"soil_analysis": {"ph": 6.8, "nitrogen_ppm": 45, "phosphorus_ppm": 22}, "irrigation_zone": "A3"}'
);
```

---

### 7. `missions`

Drone flight missions (surveys, spraying, monitoring).

```sql
CREATE TABLE missions (
    mission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drone_id UUID NOT NULL REFERENCES drones(drone_id),
    farm_id UUID REFERENCES farms(farm_id),
    field_id UUID REFERENCES fields(field_id),
    pilot_user_id UUID REFERENCES users(user_id),
    mission_type VARCHAR(50) NOT NULL, -- 'survey', 'spray', 'monitoring', 'mapping'
    mission_purpose VARCHAR(255), -- 'health_assessment', 'disease_detection', 'yield_prediction'
    status VARCHAR(50) DEFAULT 'planned', -- 'planned', 'in_progress', 'completed', 'failed', 'cancelled'
    planned_start_time TIMESTAMP,
    actual_start_time TIMESTAMP,
    actual_end_time TIMESTAMP,
    duration_minutes INTEGER,
    flight_path GEOGRAPHY(LINESTRING, 4326), -- PostGIS: planned route
    actual_flight_path GEOGRAPHY(LINESTRING, 4326), -- PostGIS: actual route
    area_covered_hectares DECIMAL(10, 4),
    altitude_meters DECIMAL(6, 2),
    speed_meters_per_second DECIMAL(5, 2),
    weather_conditions JSONB, -- Wind, temp, humidity at mission time
    battery_start_percentage INTEGER,
    battery_end_percentage INTEGER,
    images_captured INTEGER,
    data_size_gb DECIMAL(8, 2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_missions_drone ON missions(drone_id);
CREATE INDEX idx_missions_farm ON missions(farm_id);
CREATE INDEX idx_missions_field ON missions(field_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_type ON missions(mission_type);
CREATE INDEX idx_missions_start_time ON missions(actual_start_time);
CREATE INDEX idx_missions_flight_path ON missions USING GIST(flight_path);
```

---

### 8. `crop_health_assessments`

AI-generated health analysis from drone surveys.

```sql
CREATE TABLE crop_health_assessments (
    assessment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID NOT NULL REFERENCES missions(mission_id) ON DELETE CASCADE,
    field_id UUID NOT NULL REFERENCES fields(field_id),
    assessment_date TIMESTAMP DEFAULT NOW(),
    overall_health_score DECIMAL(5, 2), -- 0-100
    ndvi_average DECIMAL(5, 4), -- -1 to 1
    ndvi_min DECIMAL(5, 4),
    ndvi_max DECIMAL(5, 4),
    ndvi_std_dev DECIMAL(5, 4),
    healthy_percentage DECIMAL(5, 2),
    stressed_percentage DECIMAL(5, 2),
    diseased_percentage DECIMAL(5, 2),
    critical_percentage DECIMAL(5, 2),
    canopy_density_percentage DECIMAL(5, 2),
    canopy_uniformity_score DECIMAL(5, 2),
    berry_size_uniformity DECIMAL(5, 2), -- Vineyard-specific
    predicted_yield_tons_per_hectare DECIMAL(6, 2),
    confidence_score DECIMAL(5, 2), -- AI confidence
    analysis_version VARCHAR(50), -- Model version used
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB -- Detailed analysis results
);

CREATE INDEX idx_health_mission ON crop_health_assessments(mission_id);
CREATE INDEX idx_health_field ON crop_health_assessments(field_id);
CREATE INDEX idx_health_date ON crop_health_assessments(assessment_date);
CREATE INDEX idx_health_score ON crop_health_assessments(overall_health_score);
```

---

### 9. `disease_detections`

Specific disease/pest detections by AI.

```sql
CREATE TABLE disease_detections (
    detection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id UUID REFERENCES crop_health_assessments(assessment_id) ON DELETE CASCADE,
    field_id UUID NOT NULL REFERENCES fields(field_id),
    detection_type VARCHAR(50) NOT NULL, -- 'disease', 'pest', 'nutrient_deficiency', 'water_stress'
    disease_name VARCHAR(100), -- 'powdery_mildew', 'downy_mildew', 'botrytis', etc.
    severity VARCHAR(50), -- 'low', 'moderate', 'high', 'critical'
    confidence_percentage DECIMAL(5, 2),
    affected_area_hectares DECIMAL(10, 4),
    affected_location GEOGRAPHY(POINT, 4326), -- Center point
    affected_polygon GEOGRAPHY(POLYGON, 4326), -- Affected area boundary
    detection_date TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'detected', -- 'detected', 'confirmed', 'treated', 'resolved'
    recommended_action TEXT,
    treatment_deadline TIMESTAMP,
    estimated_loss_if_untreated DECIMAL(12, 2), -- Dollar amount
    priority_score INTEGER, -- 1-10, higher = more urgent
    images_with_detection JSONB, -- References to S3 image keys
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_detections_assessment ON disease_detections(assessment_id);
CREATE INDEX idx_detections_field ON disease_detections(field_id);
CREATE INDEX idx_detections_type ON disease_detections(detection_type, disease_name);
CREATE INDEX idx_detections_severity ON disease_detections(severity);
CREATE INDEX idx_detections_status ON disease_detections(status);
CREATE INDEX idx_detections_date ON disease_detections(detection_date);
CREATE INDEX idx_detections_location ON disease_detections USING GIST(affected_location);
```

**Sample Data:**
```sql
INSERT INTO disease_detections VALUES (
    'aa0e8400-e29b-41d4-a716-446655440005',
    'bb0e8400-e29b-41d4-a716-446655440006',
    '880e8400-e29b-41d4-a716-446655440003',
    'disease',
    'powdery_mildew',
    'moderate',
    94.3,
    2.3,
    ST_GeogFromText('POINT(-122.4195 38.2915)'),
    ST_GeogFromText('POLYGON((-122.4200 38.2920, -122.4190 38.2920, -122.4190 38.2910, -122.4200 38.2910, -122.4200 38.2920))'),
    '2025-12-01 06:15:00',
    'detected',
    'Apply sulfur-based fungicide. Precision application to affected 2.3 hectares recommended. Estimated cost: $380 vs $13,000 for broadcast treatment.',
    '2025-12-03 18:00:00',
    255000.00,
    8,
    '{"image_keys": ["missions/2025-12-01/mission-123/multispectral_block7_001.tif", "missions/2025-12-01/mission-123/multispectral_block7_002.tif"]}',
    '2025-12-01 06:20:00',
    '2025-12-01 06:20:00',
    '{"spectral_signature": {"red": 0.42, "nir": 0.38, "red_edge": 0.40}, "historical_spread_rate": "15% per week if untreated"}'
);
```

---

## Telemetry & Time-Series

### 10. `drone_telemetry` (TimescaleDB Hypertable)

High-frequency telemetry data from drones (10 Hz updates).

```sql
-- Create TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE drone_telemetry (
    time TIMESTAMPTZ NOT NULL,
    drone_id UUID NOT NULL REFERENCES drones(drone_id),
    mission_id UUID REFERENCES missions(mission_id),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    altitude_meters DECIMAL(8, 2),
    speed_meters_per_second DECIMAL(6, 2),
    heading_degrees DECIMAL(5, 2), -- 0-360
    battery_voltage DECIMAL(5, 2),
    battery_percentage INTEGER,
    battery_current_amps DECIMAL(6, 2),
    temperature_celsius DECIMAL(5, 2),
    signal_strength_dbm INTEGER,
    satellites_visible INTEGER,
    gps_accuracy_meters DECIMAL(6, 2),
    flight_mode VARCHAR(50), -- 'manual', 'auto', 'rtl' (return to launch)
    status VARCHAR(50), -- 'flying', 'hovering', 'landing', 'takeoff'
    wind_speed_mps DECIMAL(5, 2),
    wind_direction_degrees DECIMAL(5, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert to TimescaleDB hypertable (partitioned by time)
SELECT create_hypertable('drone_telemetry', 'time');

-- Create indexes
CREATE INDEX idx_telemetry_drone_time ON drone_telemetry(drone_id, time DESC);
CREATE INDEX idx_telemetry_mission ON drone_telemetry(mission_id, time DESC);

-- Set retention policy (keep 90 days hot, compress older data)
SELECT add_retention_policy('drone_telemetry', INTERVAL '90 days');
SELECT add_compression_policy('drone_telemetry', INTERVAL '7 days');
```

**Sample Data:**
```sql
INSERT INTO drone_telemetry VALUES (
    '2025-12-01 14:32:15',
    '660e8400-e29b-41d4-a716-446655440001',
    'cc0e8400-e29b-41d4-a716-446655440007',
    38.2919,
    -122.4194,
    45.3,
    12.5,
    87.2,
    23.8,
    87,
    4.2,
    34.5,
    -68,
    14,
    0.8,
    'auto',
    'flying',
    5.2,
    240.0,
    '2025-12-01 14:32:15'
);
```

---

### 11. `sensor_readings` (TimescaleDB Hypertable)

Sensor data (multispectral, thermal, environmental).

```sql
CREATE TABLE sensor_readings (
    time TIMESTAMPTZ NOT NULL,
    drone_id UUID NOT NULL REFERENCES drones(drone_id),
    mission_id UUID REFERENCES missions(mission_id),
    sensor_type VARCHAR(50) NOT NULL, -- 'multispectral', 'thermal', 'rgb', 'lidar'
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    altitude_meters DECIMAL(8, 2),
    -- Multispectral bands (reflectance 0-1)
    band_blue DECIMAL(6, 4),
    band_green DECIMAL(6, 4),
    band_red DECIMAL(6, 4),
    band_red_edge DECIMAL(6, 4),
    band_nir DECIMAL(6, 4),
    -- Derived indices
    ndvi DECIMAL(6, 4), -- (NIR - Red) / (NIR + Red)
    ndre DECIMAL(6, 4), -- (NIR - RedEdge) / (NIR + RedEdge)
    gndvi DECIMAL(6, 4), -- (NIR - Green) / (NIR + Green)
    -- Thermal
    surface_temperature_celsius DECIMAL(6, 2),
    -- Environmental
    ambient_temperature_celsius DECIMAL(5, 2),
    humidity_percentage DECIMAL(5, 2),
    light_intensity_lux INTEGER,
    -- Image reference
    image_s3_key VARCHAR(500), -- Path to full-resolution image in S3
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert to hypertable
SELECT create_hypertable('sensor_readings', 'time');

CREATE INDEX idx_sensor_drone_time ON sensor_readings(drone_id, time DESC);
CREATE INDEX idx_sensor_mission ON sensor_readings(mission_id, time DESC);
CREATE INDEX idx_sensor_type ON sensor_readings(sensor_type);
CREATE INDEX idx_sensor_ndvi ON sensor_readings(ndvi) WHERE ndvi IS NOT NULL;

-- Retention and compression
SELECT add_retention_policy('sensor_readings', INTERVAL '365 days');
SELECT add_compression_policy('sensor_readings', INTERVAL '30 days');
```

---

## Analytics & ML Tables

### 12. `ml_models`

Machine learning model registry and versioning.

```sql
CREATE TABLE ml_models (
    model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(100) NOT NULL, -- 'powdery_mildew_detector_v2', 'yield_predictor_v1'
    model_type VARCHAR(50), -- 'classification', 'detection', 'regression', 'segmentation'
    model_purpose VARCHAR(255), -- 'Disease detection for wine grapes'
    framework VARCHAR(50), -- 'tensorflow', 'pytorch', 'scikit-learn'
    version VARCHAR(50) NOT NULL,
    training_date DATE,
    training_dataset_size INTEGER, -- Number of images/samples
    accuracy DECIMAL(5, 2),
    precision_score DECIMAL(5, 2),
    recall DECIMAL(5, 2),
    f1_score DECIMAL(5, 2),
    model_s3_path VARCHAR(500), -- S3 path to model file
    is_production BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB -- Hyperparameters, training config, etc.
);

CREATE INDEX idx_models_name_version ON ml_models(model_name, version);
CREATE INDEX idx_models_production ON ml_models(is_production, is_active);
```

---

### 13. `alerts`

User notifications and alerts.

```sql
CREATE TABLE alerts (
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    org_id UUID REFERENCES organizations(org_id),
    farm_id UUID REFERENCES farms(farm_id),
    field_id UUID REFERENCES fields(field_id),
    detection_id UUID REFERENCES disease_detections(detection_id),
    alert_type VARCHAR(50) NOT NULL, -- 'disease_detected', 'mission_completed', 'low_battery', 'weather_warning'
    severity VARCHAR(50) DEFAULT 'info', -- 'critical', 'warning', 'info', 'success'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_required BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    sent_at TIMESTAMP DEFAULT NOW(),
    read_at TIMESTAMP,
    acknowledged_at TIMESTAMP,
    delivery_channels JSONB, -- {"email": true, "sms": true, "push": true}
    delivery_status JSONB, -- {"email": "sent", "sms": "delivered", "push": "read"}
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_alerts_user ON alerts(user_id, sent_at DESC);
CREATE INDEX idx_alerts_org ON alerts(org_id, sent_at DESC);
CREATE INDEX idx_alerts_type ON alerts(alert_type, severity);
CREATE INDEX idx_alerts_unread ON alerts(user_id, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_alerts_action_required ON alerts(user_id, acknowledged_at) WHERE action_required = TRUE AND acknowledged_at IS NULL;
```

---

### 14. `spray_applications`

Pesticide/fertilizer application tracking (regulatory compliance).

```sql
CREATE TABLE spray_applications (
    application_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID REFERENCES missions(mission_id),
    field_id UUID NOT NULL REFERENCES fields(field_id),
    detection_id UUID REFERENCES disease_detections(detection_id),
    applicator_user_id UUID REFERENCES users(user_id),
    application_date TIMESTAMP NOT NULL,
    application_type VARCHAR(50), -- 'pesticide', 'fungicide', 'herbicide', 'fertilizer', 'growth_regulator'
    product_name VARCHAR(255) NOT NULL,
    epa_registration_number VARCHAR(100), -- EPA reg number (US)
    active_ingredient VARCHAR(255),
    concentration_percentage DECIMAL(6, 2),
    application_rate_liters_per_hectare DECIMAL(8, 2),
    total_volume_liters DECIMAL(10, 2),
    area_treated_hectares DECIMAL(10, 4),
    treated_polygon GEOGRAPHY(POLYGON, 4326), -- Exact area sprayed
    weather_at_application JSONB, -- Wind, temp, humidity
    target_pest_disease VARCHAR(255),
    organic_approved BOOLEAN DEFAULT FALSE,
    phi_days INTEGER, -- Pre-harvest interval
    rei_hours INTEGER, -- Restricted entry interval
    applicator_license_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_spray_field ON spray_applications(field_id);
CREATE INDEX idx_spray_date ON spray_applications(application_date);
CREATE INDEX idx_spray_product ON spray_applications(product_name);
CREATE INDEX idx_spray_detection ON spray_applications(detection_id);
CREATE INDEX idx_spray_polygon ON spray_applications USING GIST(treated_polygon);
```

---

## Relationships & Indexes

### Entity Relationship Diagram (ASCII)

```
┌──────────────┐         ┌─────────────────┐         ┌──────────────┐
│    users     │─────────│ user_organizations │─────────│organizations │
└──────────────┘         └─────────────────┘         └──────────────┘
       │                                                      │
       │                                                      │
       │ (pilot)                                              │ (owns)
       │                                                      │
       ▼                                                      ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   missions   │◄────────│    drones    │         │    farms     │
└──────────────┘         └──────────────┘         └──────────────┘
       │                        │                         │
       │                        │                         │
       │                        │ (telemetry)             │ (contains)
       │                        │                         │
       │                        ▼                         ▼
       │                 ┌──────────────────┐      ┌──────────────┐
       │                 │ drone_telemetry  │      │    fields    │
       │                 └──────────────────┘      └──────────────┘
       │                                                  │
       │                 ┌──────────────────┐            │
       │                 │ sensor_readings  │            │
       │                 └──────────────────┘            │
       │                                                  │
       │ (generates)                                      │
       ▼                                                  │
┌─────────────────────────┐                              │
│ crop_health_assessments │◄─────────────────────────────┘
└─────────────────────────┘
       │
       │ (identifies)
       │
       ▼
┌─────────────────────┐         ┌──────────────┐
│ disease_detections  │─────────│    alerts    │
└─────────────────────┘         └──────────────┘
       │
       │ (triggers)
       │
       ▼
┌─────────────────────┐
│ spray_applications  │
└─────────────────────┘
```

### Foreign Key Constraints Summary

| Table | Foreign Key | References | On Delete |
|-------|-------------|------------|-----------|
| user_organizations | user_id | users(user_id) | CASCADE |
| user_organizations | org_id | organizations(org_id) | CASCADE |
| drones | org_id | organizations(org_id) | SET NULL |
| farms | org_id | organizations(org_id) | CASCADE |
| fields | farm_id | farms(farm_id) | CASCADE |
| missions | drone_id | drones(drone_id) | RESTRICT |
| missions | farm_id | farms(farm_id) | SET NULL |
| missions | field_id | fields(field_id) | SET NULL |
| crop_health_assessments | mission_id | missions(mission_id) | CASCADE |
| disease_detections | field_id | fields(field_id) | RESTRICT |
| alerts | user_id | users(user_id) | CASCADE |
| spray_applications | field_id | fields(field_id) | RESTRICT |

---

## Sample Queries

### 1. Get All Missions for a Vineyard Today

```sql
SELECT
    m.mission_id,
    m.mission_type,
    m.status,
    d.drone_name,
    f.field_name,
    m.actual_start_time,
    m.duration_minutes,
    m.area_covered_hectares
FROM missions m
JOIN drones d ON m.drone_id = d.drone_id
JOIN fields f ON m.field_id = f.field_id
JOIN farms fm ON f.farm_id = fm.farm_id
WHERE fm.farm_name = 'Napa Valley Estate'
  AND m.actual_start_time >= CURRENT_DATE
ORDER BY m.actual_start_time DESC;
```

### 2. Find All Disease Detections in Last 7 Days (High Priority)

```sql
SELECT
    dd.detection_id,
    dd.disease_name,
    dd.severity,
    dd.confidence_percentage,
    dd.affected_area_hectares,
    fm.farm_name,
    f.field_name,
    dd.detection_date,
    dd.recommended_action,
    dd.estimated_loss_if_untreated
FROM disease_detections dd
JOIN fields f ON dd.field_id = f.field_id
JOIN farms fm ON f.farm_id = fm.farm_id
WHERE dd.detection_date >= NOW() - INTERVAL '7 days'
  AND dd.severity IN ('high', 'critical')
  AND dd.status = 'detected'
ORDER BY dd.priority_score DESC, dd.detection_date DESC;
```

### 3. Calculate Average NDVI for a Field Over Time

```sql
SELECT
    DATE(time) as survey_date,
    AVG(ndvi) as avg_ndvi,
    MIN(ndvi) as min_ndvi,
    MAX(ndvi) as max_ndvi,
    STDDEV(ndvi) as stddev_ndvi,
    COUNT(*) as reading_count
FROM sensor_readings
WHERE mission_id IN (
    SELECT mission_id
    FROM missions
    WHERE field_id = '880e8400-e29b-41d4-a716-446655440003'
)
  AND ndvi IS NOT NULL
  AND time >= NOW() - INTERVAL '30 days'
GROUP BY DATE(time)
ORDER BY survey_date DESC;
```

### 4. Get Real-Time Drone Positions (Last 10 Seconds)

```sql
SELECT DISTINCT ON (drone_id)
    dt.drone_id,
    d.drone_name,
    dt.latitude,
    dt.longitude,
    dt.altitude_meters,
    dt.speed_meters_per_second,
    dt.battery_percentage,
    dt.flight_mode,
    dt.time
FROM drone_telemetry dt
JOIN drones d ON dt.drone_id = d.drone_id
WHERE dt.time >= NOW() - INTERVAL '10 seconds'
ORDER BY dt.drone_id, dt.time DESC;
```

### 5. Vineyard Health Trend (Last 90 Days)

```sql
SELECT
    f.field_name,
    f.crop_variety,
    DATE(cha.assessment_date) as date,
    cha.overall_health_score,
    cha.ndvi_average,
    cha.diseased_percentage,
    cha.predicted_yield_tons_per_hectare
FROM crop_health_assessments cha
JOIN fields f ON cha.field_id = f.field_id
JOIN farms fm ON f.farm_id = fm.farm_id
WHERE fm.farm_name = 'Napa Valley Estate'
  AND cha.assessment_date >= NOW() - INTERVAL '90 days'
ORDER BY f.field_name, cha.assessment_date DESC;
```

### 6. Spray Application Compliance Report

```sql
SELECT
    sa.application_date,
    fm.farm_name,
    f.field_name,
    sa.product_name,
    sa.epa_registration_number,
    sa.area_treated_hectares,
    sa.application_rate_liters_per_hectare,
    sa.target_pest_disease,
    sa.applicator_license_number,
    u.first_name || ' ' || u.last_name as applicator_name
FROM spray_applications sa
JOIN fields f ON sa.field_id = f.field_id
JOIN farms fm ON f.farm_id = fm.farm_id
LEFT JOIN users u ON sa.applicator_user_id = u.user_id
WHERE sa.application_date >= '2025-01-01'
  AND sa.application_date < '2025-12-31'
ORDER BY sa.application_date DESC;
```

### 7. Economic Impact: Chemical Savings (Monthly)

```sql
WITH precision_spray AS (
    SELECT
        DATE_TRUNC('month', application_date) as month,
        SUM(area_treated_hectares) as precision_area,
        AVG(application_rate_liters_per_hectare) as avg_rate
    FROM spray_applications
    WHERE application_date >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', application_date)
),
total_area AS (
    SELECT
        DATE_TRUNC('month', m.actual_start_time) as month,
        SUM(m.area_covered_hectares) as surveyed_area
    FROM missions m
    WHERE m.mission_type = 'survey'
      AND m.actual_start_time >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', m.actual_start_time)
)
SELECT
    ps.month,
    ps.precision_area,
    ta.surveyed_area,
    -- Traditional broadcast would treat entire surveyed area
    ta.surveyed_area * ps.avg_rate * 15 as broadcast_cost_estimate, -- $15/liter
    ps.precision_area * ps.avg_rate * 15 as precision_cost,
    (ta.surveyed_area - ps.precision_area) * ps.avg_rate * 15 as savings
FROM precision_spray ps
JOIN total_area ta ON ps.month = ta.month
ORDER BY ps.month DESC;
```

---

## Data Lifecycle

### Data Retention Policies

| Data Type | Hot Storage | Warm Storage | Cold Archive | Total Retention |
|-----------|-------------|--------------|--------------|-----------------|
| **Telemetry (10Hz)** | 7 days | 90 days (compressed) | N/A | 90 days |
| **Sensor Readings** | 30 days | 1 year (compressed) | 7 years | 7 years |
| **Mission Data** | Forever | N/A | N/A | Forever |
| **Health Assessments** | Forever | N/A | N/A | Forever |
| **Disease Detections** | Forever | N/A | N/A | Forever |
| **Spray Applications** | Forever (regulatory) | N/A | N/A | Forever |
| **Alerts** | 90 days | 1 year | N/A | 1 year |
| **Images (S3)** | 30 days (hot) | 1 year (warm) | 7 years (glacier) | 7 years |

### Archiving Strategy

```sql
-- Automatically compress old telemetry
SELECT add_compression_policy('drone_telemetry', INTERVAL '7 days');

-- Delete very old telemetry
SELECT add_retention_policy('drone_telemetry', INTERVAL '90 days');

-- Archive old alerts
CREATE OR REPLACE FUNCTION archive_old_alerts() RETURNS void AS $$
BEGIN
    DELETE FROM alerts
    WHERE sent_at < NOW() - INTERVAL '1 year'
      AND read_at IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- Run monthly
SELECT cron.schedule('archive-alerts', '0 0 1 * *', 'SELECT archive_old_alerts();');
```

---

## Database Sizing Estimates

### Storage Projections (50 Drones, 1 Year)

| Table | Rows/Year | Row Size | Total Size |
|-------|-----------|----------|------------|
| **drone_telemetry** | 1.5 billion (10Hz × 50 drones × 90 days) | ~100 bytes | ~150 GB → 15 GB (compressed 10:1) |
| **sensor_readings** | 50 million (1/sec × 50 drones × 365 days) | ~200 bytes | ~10 GB → 1 GB (compressed) |
| **missions** | 50,000 | ~2 KB | ~100 MB |
| **crop_health_assessments** | 50,000 | ~1 KB | ~50 MB |
| **disease_detections** | 10,000 | ~2 KB | ~20 MB |
| **spray_applications** | 5,000 | ~1 KB | ~5 MB |
| **Images (S3)** | 5 million images | 50 MB avg | 250 TB |

**Total Database Size (1 year, 50 drones)**: ~20-30 GB (PostgreSQL) + 250 TB (S3 images)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-01
**Schema Version**: v1.0.0

**For implementation questions, see**: `AEROVINE-SYSTEM-ARCHITECTURE.md`
