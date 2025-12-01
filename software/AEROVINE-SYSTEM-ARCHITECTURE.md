# AeroVine System Architecture

**Cloud-Native, Microservices-Based Architecture for Agricultural Drone Fleet Management**

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [System Layers](#system-layers)
3. [Microservices Architecture](#microservices-architecture)
4. [Data Flow Diagrams](#data-flow-diagrams)
5. [API Architecture](#api-architecture)
6. [Security Architecture](#security-architecture)
7. [Deployment Architecture](#deployment-architecture)
8. [Scalability & Performance](#scalability--performance)

---

## Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │   Web App    │  │  Mobile iOS  │  │Mobile Android│  │ Ground Ctrl │ │
│  │  (React/Vue) │  │   (Swift)    │  │  (Kotlin)    │  │   Station   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                  │                  │                  │        │
│         └──────────────────┴──────────────────┴──────────────────┘        │
│                                    │                                      │
└────────────────────────────────────┼──────────────────────────────────────┘
                                     │
                    ┌────────────────▼────────────────┐
                    │    CDN (CloudFlare/CloudFront)  │
                    │    - Static assets              │
                    │    - Image thumbnails           │
                    └────────────────┬────────────────┘
                                     │
┌────────────────────────────────────▼──────────────────────────────────────┐
│                          API GATEWAY LAYER                                 │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │              AWS API Gateway / Kong / Nginx                        │  │
│  │  - Authentication & Authorization                                  │  │
│  │  - Rate limiting (1000 req/min per user)                          │  │
│  │  - Request routing                                                 │  │
│  │  - SSL/TLS termination                                            │  │
│  │  - Request/response transformation                                │  │
│  └────────────────────────────────┬──────────────────────────────────┘  │
│                                    │                                      │
└────────────────────────────────────┼──────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼──────────────────────────────────────┐
│                        MICROSERVICES LAYER                                 │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────────┐       │
│  │   Auth      │ │   Fleet     │ │  Mission    │ │  Telemetry   │       │
│  │  Service    │ │  Service    │ │  Service    │ │   Service    │       │
│  │  (FastAPI)  │ │  (FastAPI)  │ │  (FastAPI)  │ │  (FastAPI)   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────────┘       │
│                                                                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────────┐       │
│  │Agriculture  │ │   AI/ML     │ │  Analytics  │ │ Notification │       │
│  │  Service    │ │  Service    │ │  Service    │ │   Service    │       │
│  │  (FastAPI)  │ │  (Python)   │ │  (Python)   │ │  (Node.js)   │       │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────────┘       │
│                                                                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                         │
│  │  Weather    │ │   Image     │ │  Reporting  │                         │
│  │  Service    │ │ Processing  │ │   Service   │                         │
│  │  (FastAPI)  │ │  Service    │ │  (FastAPI)  │                         │
│  └─────────────┘ └─────────────┘ └─────────────┘                         │
│                                                                            │
└───────────────────────────┬────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────┐
│                        MESSAGE QUEUE LAYER                                  │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │              RabbitMQ / Apache Kafka                                 │  │
│  │  Queues: image.processing, ai.inference, mission.scheduler,         │  │
│  │          alert.dispatch, report.generation, email.notifications      │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────┐
│                          DATA LAYER                                         │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────┐  ┌────────────────┐  ┌────────────┐  ┌─────────────┐  │
│  │  PostgreSQL   │  │  TimescaleDB   │  │   Redis    │  │   S3/GCS    │  │
│  │   + PostGIS   │  │  (Telemetry)   │  │  (Cache)   │  │  (Images)   │  │
│  │ (Primary DB)  │  │ (Time-series)  │  │            │  │             │  │
│  └───────────────┘  └────────────────┘  └────────────┘  └─────────────┘  │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────┐
│                        EXTERNAL INTEGRATIONS                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐     │
│  │  Weather    │  │  Satellite  │  │  Farm Mgmt  │  │     SMS      │     │
│  │   APIs      │  │   Imagery   │  │   Systems   │  │  (Twilio)    │     │
│  │ (OpenWeather│  │ (Sentinel-2)│  │(John Deere) │  │              │     │
│  └─────────────┘  └─────────────┘  └─────────────┘  └──────────────┘     │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────┐
│                          DRONE LAYER                                        │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Drone    │  │ Drone    │  │ Drone    │  │  ...     │  │ Drone    │   │
│  │  V-08    │  │  V-12    │  │  A-23    │  │          │  │  #50     │   │
│  │          │  │          │  │          │  │          │  │          │   │
│  │ 4G LTE   │  │ 4G LTE   │  │ 4G LTE   │  │  4G LTE  │  │ 4G LTE   │   │
│  │ MAVLink  │  │ MAVLink  │  │ MAVLink  │  │ MAVLink  │  │ MAVLink  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## System Layers

### 1. Client Layer

**Purpose**: User interfaces for vineyard managers, pilots, and administrators.

**Components**:

| Component | Technology | Users | Features |
|-----------|-----------|-------|----------|
| **Web Dashboard** | React 18 + TypeScript | Vineyard managers, analysts | Real-time monitoring, analytics, reports |
| **iOS App** | Swift + SwiftUI | Field managers | Mobile alerts, quick status checks |
| **Android App** | Kotlin + Jetpack Compose | Field managers | Mobile alerts, quick status checks |
| **Ground Control Station** | Qt/Python or Web-based | Drone pilots | Flight planning, manual control, safety override |

**Communication**:
- REST API over HTTPS
- WebSocket for real-time updates (telemetry, alerts)
- GraphQL (optional) for complex queries

---

### 2. API Gateway Layer

**Purpose**: Single entry point for all client requests; handles cross-cutting concerns.

**Technology**: AWS API Gateway, Kong, or Nginx + custom middleware

**Responsibilities**:

| Function | Implementation | Details |
|----------|---------------|---------|
| **Authentication** | OAuth 2.0 + JWT | Verify user tokens, extract claims |
| **Authorization** | Role-based access control (RBAC) | Check user permissions for resources |
| **Rate Limiting** | Token bucket algorithm | 1,000 req/min per user, 10,000 req/min per org |
| **SSL/TLS Termination** | Let's Encrypt / AWS ACM | HTTPS only, TLS 1.3 |
| **Request Routing** | Path-based routing | `/api/v1/fleet/*` → Fleet Service |
| **Load Balancing** | Round-robin, least-connections | Distribute across service instances |
| **Circuit Breaking** | Hystrix pattern | Fail fast if service is down |
| **Request Transformation** | Normalize headers, inject metadata | Add user_id, org_id, request_id |
| **Logging** | Structured JSON logs | All requests logged with trace IDs |

**Example Configuration**:
```yaml
# API Gateway routing (simplified)
routes:
  - path: /api/v1/auth/*
    service: auth-service
    methods: [POST, GET]

  - path: /api/v1/fleet/*
    service: fleet-service
    methods: [GET, POST, PUT, DELETE]
    auth_required: true

  - path: /api/v1/missions/*
    service: mission-service
    methods: [GET, POST, PUT, DELETE]
    auth_required: true
    rate_limit: 100/minute

  - path: /ws/telemetry
    service: telemetry-service
    protocol: websocket
    auth_required: true
```

---

### 3. Microservices Layer

**Architecture Pattern**: Domain-driven microservices with event-driven communication.

#### Service Breakdown

**1. Auth Service**

**Responsibilities**:
- User authentication (login, logout, password reset)
- JWT token generation and validation
- OAuth 2.0 flow management
- Two-factor authentication (2FA)
- Session management

**Technology**: Python FastAPI + Redis (session store)

**API Endpoints**:
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
POST   /api/v1/auth/password-reset
GET    /api/v1/auth/me
```

**Database**: `users`, `user_organizations`, `organizations`

---

**2. Fleet Service**

**Responsibilities**:
- Drone registry and metadata management
- Fleet status monitoring
- Drone health tracking (battery cycles, maintenance schedules)
- Ground control station management

**Technology**: Python FastAPI + PostgreSQL

**API Endpoints**:
```
GET    /api/v1/fleet/drones
GET    /api/v1/fleet/drones/{drone_id}
POST   /api/v1/fleet/drones
PUT    /api/v1/fleet/drones/{drone_id}
DELETE /api/v1/fleet/drones/{drone_id}
GET    /api/v1/fleet/drones/{drone_id}/maintenance
POST   /api/v1/fleet/drones/{drone_id}/maintenance
```

**Database**: `drones`

---

**3. Mission Service**

**Responsibilities**:
- Flight mission planning
- Mission execution tracking
- Flight path generation (waypoints)
- Mission history and analytics

**Technology**: Python FastAPI + PostgreSQL + PostGIS

**API Endpoints**:
```
GET    /api/v1/missions
POST   /api/v1/missions
GET    /api/v1/missions/{mission_id}
PUT    /api/v1/missions/{mission_id}
DELETE /api/v1/missions/{mission_id}
POST   /api/v1/missions/{mission_id}/start
POST   /api/v1/missions/{mission_id}/cancel
GET    /api/v1/missions/{mission_id}/telemetry
```

**Database**: `missions`, `fields`, `farms`

**External Calls**:
- Weather Service (check flight safety)
- Fleet Service (verify drone availability)

---

**4. Telemetry Service**

**Responsibilities**:
- Real-time drone telemetry ingestion (10 Hz GPS, battery, sensors)
- WebSocket streaming to clients
- Telemetry storage in TimescaleDB
- Anomaly detection (geofence violations, low battery)

**Technology**: Python FastAPI + WebSocket + TimescaleDB + Redis

**API Endpoints**:
```
WS     /ws/telemetry (WebSocket)
GET    /api/v1/telemetry/drones/{drone_id}/latest
GET    /api/v1/telemetry/drones/{drone_id}/history
POST   /api/v1/telemetry/ingest (from drones via 4G LTE)
```

**Database**: `drone_telemetry` (TimescaleDB hypertable)

**Data Flow**:
```
Drone (4G LTE) → POST /telemetry/ingest → Redis (pub/sub) → WebSocket → Client
                                         ↓
                                  TimescaleDB (persistent storage)
```

---

**5. Agriculture Service**

**Responsibilities**:
- Farm and field management
- Crop variety tracking
- Vineyard-specific operations (veraison tracking, brix monitoring)
- Harvest predictions

**Technology**: Python FastAPI + PostgreSQL + PostGIS

**API Endpoints**:
```
GET    /api/v1/agriculture/farms
POST   /api/v1/agriculture/farms
GET    /api/v1/agriculture/farms/{farm_id}/fields
POST   /api/v1/agriculture/fields
GET    /api/v1/agriculture/fields/{field_id}
GET    /api/v1/agriculture/fields/{field_id}/health
GET    /api/v1/agriculture/fields/{field_id}/health/history
GET    /api/v1/agriculture/fields/{field_id}/diseases
POST   /api/v1/agriculture/spray-applications
```

**Database**: `farms`, `fields`, `crop_health_assessments`, `disease_detections`, `spray_applications`

---

**6. AI/ML Service**

**Responsibilities**:
- Disease detection from multispectral imagery
- NDVI calculation and analysis
- Yield prediction models
- Model training and versioning

**Technology**: Python + TensorFlow/PyTorch + FastAPI

**API Endpoints**:
```
POST   /api/v1/ai/detect-disease (async)
POST   /api/v1/ai/calculate-ndvi
POST   /api/v1/ai/predict-yield
GET    /api/v1/ai/models
POST   /api/v1/ai/models/{model_id}/deploy
```

**Database**: `ml_models`

**Message Queue**:
- Consumes: `ai.inference` queue (image analysis requests)
- Produces: `alert.dispatch` queue (disease detected)

**GPU Requirements**: 1-4 NVIDIA V100/A100 GPUs for inference

---

**7. Analytics Service**

**Responsibilities**:
- Business intelligence dashboards
- ROI calculations
- Chemical savings reports
- Fleet performance metrics

**Technology**: Python + Pandas + FastAPI

**API Endpoints**:
```
GET    /api/v1/analytics/dashboard-stats
GET    /api/v1/analytics/roi
GET    /api/v1/analytics/chemical-savings
GET    /api/v1/analytics/fleet-performance
GET    /api/v1/analytics/vineyard-trends
```

**Database**: Read replicas (PostgreSQL + TimescaleDB)

---

**8. Notification Service**

**Responsibilities**:
- Email notifications (SendGrid/AWS SES)
- SMS alerts (Twilio)
- Push notifications (Firebase Cloud Messaging)
- Alert management and deduplication

**Technology**: Node.js + Express

**API Endpoints**:
```
POST   /api/v1/notifications/send
GET    /api/v1/notifications/alerts
PUT    /api/v1/notifications/alerts/{alert_id}/read
PUT    /api/v1/notifications/alerts/{alert_id}/acknowledge
```

**Database**: `alerts`

**Message Queue**:
- Consumes: `alert.dispatch`, `email.notifications`

---

**9. Weather Service**

**Responsibilities**:
- Fetch weather data from external APIs
- Cache weather forecasts (15-minute refresh)
- Flight safety assessments (wind, precipitation)
- Optimal spray window detection

**Technology**: Python FastAPI + Redis (caching)

**API Endpoints**:
```
GET    /api/v1/weather/current/{lat}/{lon}
GET    /api/v1/weather/forecast/{lat}/{lon}
GET    /api/v1/weather/flight-safety/{lat}/{lon}
GET    /api/v1/weather/spray-window/{lat}/{lon}
```

**External APIs**:
- OpenWeather API
- Weather Underground
- NOAA (US-only, free)

---

**10. Image Processing Service**

**Responsibilities**:
- Orthoimage stitching (photogrammetry)
- Image georeferencing
- Thumbnail generation
- Image compression and format conversion

**Technology**: Python + OpenCV + GDAL

**API Endpoints**:
```
POST   /api/v1/images/process (async)
GET    /api/v1/images/{image_id}
GET    /api/v1/images/{image_id}/thumbnail
```

**Message Queue**:
- Consumes: `image.processing` queue
- Produces: `ai.inference` queue (processed images ready for AI)

**Storage**: S3/GCS for raw and processed images

---

**11. Reporting Service**

**Responsibilities**:
- PDF report generation
- Spray application compliance reports
- Vineyard health summaries
- Economic impact reports

**Technology**: Python FastAPI + ReportLab/WeasyPrint

**API Endpoints**:
```
POST   /api/v1/reports/generate (async)
GET    /api/v1/reports/{report_id}/status
GET    /api/v1/reports/{report_id}/download
GET    /api/v1/reports/templates
```

**Message Queue**:
- Consumes: `report.generation` queue

---

### Inter-Service Communication

**Synchronous** (REST):
- Used for: Request-response operations, queries
- Example: Fleet Service → Weather Service (check flight safety)
- Timeout: 5 seconds max
- Circuit breaker: Fail fast if service unavailable

**Asynchronous** (Message Queue):
- Used for: Long-running tasks, event notifications
- Example: Mission Service → Image Processing → AI Service → Notification
- Retry policy: 3 retries with exponential backoff
- Dead letter queue: For failed messages after retries

**Event-Driven**:
- Events published to message broker
- Services subscribe to relevant topics
- Example events:
  - `mission.completed`
  - `disease.detected`
  - `drone.battery.low`
  - `alert.created`

---

## Data Flow Diagrams

### 1. Drone Survey Mission Flow

```
┌────────────┐
│  Vineyard  │
│  Manager   │
└─────┬──────┘
      │
      │ 1. Plan mission via Web Dashboard
      ▼
┌────────────────┐
│ Mission Service│
└────┬───────────┘
      │
      │ 2. Check weather, drone availability
      ▼
┌────────────────┐      ┌────────────────┐
│ Weather Service│      │  Fleet Service │
└────────────────┘      └────────────────┘
      │                         │
      │ 3. Weather OK, drone available
      ▼
┌────────────────┐
│ Mission Service│
└────┬───────────┘
      │
      │ 4. Mission approved, send to drone
      ▼
┌────────────────┐
│  Drone V-08    │
│  (4G LTE)      │
└────┬───────────┘
      │
      │ 5. Execute mission (survey vineyard)
      │    - Capture multispectral images
      │    - Stream telemetry (10 Hz)
      │
      │ 6. Telemetry stream
      ▼
┌────────────────┐      ┌────────────────┐
│Telemetry Service│────>│  Redis (cache) │
└────┬───────────┘      └────────────────┘
      │                         │
      │                         │ 7. Pub/Sub
      │                         ▼
      │                  ┌────────────────┐
      │                  │   WebSocket    │
      │                  │   (to client)  │
      │                  └────────────────┘
      │
      │ 8. Mission complete, upload images
      ▼
┌────────────────┐
│   S3 Storage   │
└────┬───────────┘
      │
      │ 9. Trigger image processing
      ▼
┌────────────────┐
│Image Processing│
│    Service     │
└────┬───────────┘
      │
      │ 10. Images processed
      ▼
┌────────────────┐
│  Message Queue │
│ (ai.inference) │
└────┬───────────┘
      │
      │ 11. AI disease detection
      ▼
┌────────────────┐
│   AI Service   │
│   (GPU)        │
└────┬───────────┘
      │
      │ 12. Powdery mildew detected!
      ▼
┌────────────────┐
│ Message Queue  │
│(alert.dispatch)│
└────┬───────────┘
      │
      │ 13. Send alert
      ▼
┌────────────────┐
│  Notification  │
│    Service     │
└────┬───────────┘
      │
      │ 14. Email + SMS + Push
      ▼
┌────────────────┐
│  Vineyard      │
│  Manager       │
│  (receives     │
│   alert)       │
└────────────────┘
```

**Timeline**:
- Mission execution: 15-30 minutes (depending on field size)
- Telemetry streaming: Real-time (100ms latency)
- Image upload: 5-10 minutes (post-flight)
- Image processing: 2-5 minutes
- AI analysis: 3-5 minutes
- Alert delivery: <1 minute
- **Total: Detection to alert in <15 minutes after mission complete**

---

### 2. Real-Time Telemetry Flow

```
┌──────────────┐
│ Drone V-08   │
│ (In Flight)  │
└──────┬───────┘
       │
       │ Every 100ms (10 Hz):
       │ - GPS (lat/lon/alt)
       │ - Battery (voltage, current, %)
       │ - Speed, heading
       │ - Flight mode, status
       │
       │ POST /api/v1/telemetry/ingest
       ▼
┌──────────────────┐
│  API Gateway     │
└──────┬───────────┘
       │
       │ Validate, route
       ▼
┌──────────────────┐
│Telemetry Service │
└──────┬───────────┘
       │
       ├────────────────────────┐
       │                        │
       │ Write to TimescaleDB   │ Publish to Redis
       ▼                        ▼
┌──────────────────┐     ┌──────────────────┐
│  TimescaleDB     │     │  Redis Pub/Sub   │
│  (persistent)    │     │  (real-time)     │
└──────────────────┘     └──────┬───────────┘
                                │
                                │ Subscribe
                                ▼
                         ┌──────────────────┐
                         │   WebSocket      │
                         │   Server         │
                         └──────┬───────────┘
                                │
                                │ Push to connected clients
                                ▼
                         ┌──────────────────┐
                         │  Web Dashboard   │
                         │  (React)         │
                         │  - Live map      │
                         │  - Battery %     │
                         │  - Status        │
                         └──────────────────┘
```

**Performance**:
- Telemetry ingestion rate: 500 data points/second (50 drones × 10 Hz)
- TimescaleDB insert latency: <10ms
- Redis pub/sub latency: <5ms
- WebSocket push latency: <50ms
- **Total end-to-end: <100ms (drone to dashboard)**

---

### 3. AI Disease Detection Pipeline

```
┌──────────────────┐
│  Drone captures  │
│  multispectral   │
│  images (5 bands)│
└────────┬─────────┘
         │
         │ Upload to S3
         ▼
┌──────────────────┐
│   S3 Storage     │
│ /missions/       │
│  2025-12-01/     │
│   mission-123/   │
└────────┬─────────┘
         │
         │ Trigger Lambda / Event
         ▼
┌──────────────────┐
│  Message Queue   │
│(image.processing)│
└────────┬─────────┘
         │
         │ Worker consumes
         ▼
┌──────────────────┐
│ Image Processing │
│    Service       │
│ - Georeference   │
│ - Stitch         │
│ - Normalize      │
└────────┬─────────┘
         │
         │ Processed images
         ▼
┌──────────────────┐
│  Message Queue   │
│  (ai.inference)  │
└────────┬─────────┘
         │
         │ AI worker consumes
         ▼
┌──────────────────────────────┐
│      AI Service (GPU)         │
│                               │
│  1. Load model:               │
│     powdery_mildew_v2.h5     │
│                               │
│  2. Preprocess:               │
│     - Resize to 512x512       │
│     - Calculate NDVI          │
│     - Normalize bands         │
│                               │
│  3. Inference:                │
│     - CNN forward pass        │
│     - Confidence score        │
│                               │
│  4. Post-process:             │
│     - Threshold (>90%)        │
│     - Bounding boxes          │
│     - Affected area calc      │
└────────┬─────────────────────┘
         │
         │ Disease detected!
         │ Confidence: 94.3%
         │ Affected: 2.3 ha
         ▼
┌──────────────────┐
│   PostgreSQL     │
│ disease_         │
│  detections      │
└────────┬─────────┘
         │
         │ Trigger alert
         ▼
┌──────────────────┐
│  Message Queue   │
│ (alert.dispatch) │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Notification    │
│    Service       │
│ - Email          │
│ - SMS            │
│ - Push           │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Vineyard        │
│  Manager         │
│  (receives alert)│
└──────────────────┘
```

**Processing Times**:
- Image upload: 5-10 minutes (2-10 GB dataset)
- Image processing: 2-5 minutes (stitching, georeferencing)
- AI inference: 3-5 minutes (85-hectare survey, ~500 images)
- Alert dispatch: <1 minute
- **Total: 10-20 minutes from mission end to alert**

---

## API Architecture

### RESTful API Design Principles

**Base URL**: `https://api.aerovine.ai/v1`

**Versioning**: URL-based (`/v1`, `/v2`) for major changes

**Authentication**: JWT Bearer tokens
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Standard Response Format**:
```json
{
  "success": true,
  "data": {
    "mission_id": "cc0e8400-e29b-41d4-a716-446655440007",
    "status": "in_progress"
  },
  "meta": {
    "request_id": "req-12345",
    "timestamp": "2025-12-01T14:32:15Z"
  }
}
```

**Error Response Format**:
```json
{
  "success": false,
  "error": {
    "code": "DRONE_UNAVAILABLE",
    "message": "Drone V-08 is currently in maintenance",
    "details": {
      "drone_id": "660e8400-e29b-41d4-a716-446655440001",
      "available_at": "2025-12-03T10:00:00Z"
    }
  },
  "meta": {
    "request_id": "req-12346",
    "timestamp": "2025-12-01T14:35:20Z"
  }
}
```

### HTTP Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| **200** | OK | Successful GET, PUT, DELETE |
| **201** | Created | Successful POST (resource created) |
| **202** | Accepted | Async operation started |
| **204** | No Content | Successful DELETE |
| **400** | Bad Request | Invalid input, validation error |
| **401** | Unauthorized | Missing or invalid token |
| **403** | Forbidden | Valid token, insufficient permissions |
| **404** | Not Found | Resource doesn't exist |
| **409** | Conflict | Resource state conflict (e.g., drone already in flight) |
| **422** | Unprocessable Entity | Semantic errors (e.g., mission time in past) |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Internal Server Error | Server-side error |
| **503** | Service Unavailable | Temporary outage, try again later |

### API Endpoint Examples

**1. List Missions**
```http
GET /api/v1/missions?farm_id={farm_id}&status=in_progress&limit=20&offset=0
Authorization: Bearer {token}

Response 200 OK:
{
  "success": true,
  "data": {
    "missions": [
      {
        "mission_id": "...",
        "drone_id": "...",
        "field_id": "...",
        "status": "in_progress",
        "progress_percentage": 67,
        "eta_minutes": 12
      }
    ],
    "total": 42,
    "limit": 20,
    "offset": 0
  }
}
```

**2. Create Mission**
```http
POST /api/v1/missions
Authorization: Bearer {token}
Content-Type: application/json

{
  "drone_id": "660e8400-e29b-41d4-a716-446655440001",
  "field_id": "880e8400-e29b-41d4-a716-446655440003",
  "mission_type": "survey",
  "planned_start_time": "2025-12-02T08:00:00Z",
  "altitude_meters": 45,
  "speed_meters_per_second": 12
}

Response 201 Created:
{
  "success": true,
  "data": {
    "mission_id": "...",
    "status": "planned",
    "flight_path": {...}
  }
}
```

**3. WebSocket Telemetry**
```javascript
// Client-side connection
const ws = new WebSocket('wss://api.aerovine.ai/ws/telemetry?token={jwt_token}');

ws.onopen = () => {
  // Subscribe to specific drone
  ws.send(JSON.stringify({
    action: 'subscribe',
    drone_id: '660e8400-e29b-41d4-a716-446655440001'
  }));
};

ws.onmessage = (event) => {
  const telemetry = JSON.parse(event.data);
  // {
  //   "drone_id": "...",
  //   "latitude": 38.2919,
  //   "longitude": -122.4194,
  //   "altitude_meters": 45.3,
  //   "battery_percentage": 87,
  //   "timestamp": "2025-12-01T14:32:15Z"
  // }
  updateDronePosition(telemetry);
};
```

---

## Security Architecture

### 1. Authentication Flow (OAuth 2.0 + JWT)

```
┌────────────┐                                  ┌────────────┐
│   Client   │                                  │Auth Service│
│ (Web/Mobile)│                                  └────────────┘
└─────┬──────┘
      │
      │ 1. POST /auth/login
      │    {email, password}
      ▼
┌────────────────────────────────────────────────────────────┐
│                    API Gateway                             │
└────────┬───────────────────────────────────────────────────┘
         │
         │ 2. Route to Auth Service
         ▼
      ┌────────────┐
      │Auth Service│
      └────┬───────┘
           │
           │ 3. Verify credentials (bcrypt)
           │    Check PostgreSQL users table
           │
           │ 4. Generate JWT token
           │    - Payload: user_id, org_id, role
           │    - Expiry: 1 hour (access token)
           │    - Sign with RS256 (private key)
           │
           │ 5. Generate refresh token
           │    - Expiry: 30 days
           │    - Store in Redis
           │
           ▼
      ┌────────────┐
      │   Client   │
      └────┬───────┘
           │
           │ 6. Store tokens
           │    - Access token: memory
           │    - Refresh token: httpOnly cookie
           │
           │ 7. Subsequent requests
           │    Authorization: Bearer {access_token}
           ▼
      ┌────────────┐
      │API Gateway │
      └────┬───────┘
           │
           │ 8. Verify JWT signature
           │    - Public key verification
           │    - Check expiry
           │    - Extract claims
           │
           │ 9. Inject user context
           │    - Headers: X-User-Id, X-Org-Id
           │
           ▼
      ┌────────────┐
      │ Service    │
      │ (e.g. Fleet)│
      └────────────┘
```

### 2. Authorization (Role-Based Access Control)

**Roles**:

| Role | Permissions | Use Case |
|------|-------------|----------|
| **admin** | Full access to all resources | System administrators |
| **pilot** | Read/write missions, read drones, read farms | Drone pilots |
| **customer** | Read/write own farms/fields, read missions | Vineyard owners |
| **analyst** | Read-only access to analytics | Data scientists |
| **viewer** | Read-only access to dashboards | Stakeholders |

**Permission Matrix**:

| Resource | Admin | Pilot | Customer | Analyst | Viewer |
|----------|-------|-------|----------|---------|--------|
| Users | CRUD | - | - | - | - |
| Organizations | CRUD | R | R (own) | R (own) | R (own) |
| Drones | CRUD | R | R | R | R |
| Missions | CRUD | CRUD | RU (own) | R (own) | R (own) |
| Farms | CRUD | R | CRUD (own) | R (own) | R (own) |
| Health Data | CRUD | R | R (own) | R (own) | R (own) |
| Analytics | CRUD | R | R (own) | R | R (own) |

**Policy Enforcement**:
```python
# Example: Mission Service
@app.get("/api/v1/missions/{mission_id}")
async def get_mission(
    mission_id: UUID,
    current_user: User = Depends(get_current_user)
):
    mission = await db.get_mission(mission_id)

    # Check ownership or admin role
    if current_user.role != "admin" and mission.org_id != current_user.org_id:
        raise HTTPException(status_code=403, detail="Access denied")

    return mission
```

### 3. Data Encryption

**In Transit**:
- TLS 1.3 for all HTTPS traffic
- Certificate: Let's Encrypt or AWS ACM
- Cipher suites: AES-256-GCM, ChaCha20-Poly1305

**At Rest**:
- PostgreSQL: Transparent Data Encryption (TDE) or volume-level encryption
- S3: Server-side encryption with AWS KMS (SSE-KMS)
- Redis: Encrypted snapshots

**Field-Level Encryption**:
- PII (phone numbers, addresses): AES-256-GCM
- Encryption keys: AWS KMS or HashiCorp Vault

### 4. Network Security

**VPC Architecture** (AWS example):
```
┌─────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │   Public Subnet (10.0.1.0/24)                  │    │
│  │   - Load Balancer                              │    │
│  │   - NAT Gateway                                │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │   Private Subnet - App Tier (10.0.2.0/24)      │    │
│  │   - API Gateway                                │    │
│  │   - Microservices (containers)                 │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │   Private Subnet - Data Tier (10.0.3.0/24)     │    │
│  │   - PostgreSQL RDS                             │    │
│  │   - Redis ElastiCache                          │    │
│  │   - No internet access                         │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Security Groups**:
- Load Balancer: Allow 443 from 0.0.0.0/0
- API Gateway: Allow 443 from Load Balancer
- Microservices: Allow 8000-8010 from API Gateway
- Database: Allow 5432 from Microservices only
- Redis: Allow 6379 from Microservices only

---

## Deployment Architecture

### Kubernetes Cluster Architecture

```
┌────────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster (GKE/EKS/AKS)         │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Ingress Controller (Nginx)             │  │
│  │  - SSL termination                                  │  │
│  │  - Path-based routing                               │  │
│  └──────────────────┬──────────────────────────────────┘  │
│                     │                                      │
│  ┌──────────────────▼───────────────────────────────────┐ │
│  │                 API Gateway Service                  │ │
│  │  Replicas: 3                                         │ │
│  │  Resources: 1 CPU, 2GB RAM each                      │ │
│  └──────────────────┬───────────────────────────────────┘ │
│                     │                                      │
│  ┌──────────────────┴───────────────────────────────────┐ │
│  │                                                       │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │
│  │  │Auth Service │  │Fleet Service│  │Mission Svc  │ │ │
│  │  │Replicas: 2  │  │Replicas: 3  │  │Replicas: 3  │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │
│  │                                                       │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │
│  │  │Telemetry Svc│  │Agri Service │  │  AI Service │ │ │
│  │  │Replicas: 5  │  │Replicas: 3  │  │Replicas: 2  │ │ │
│  │  │             │  │             │  │(GPU nodes)  │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │           Persistent Storage (StatefulSets)           │ │
│  │  - Redis (3 replicas, master-slave)                  │ │
│  │  - RabbitMQ (3 replicas, HA cluster)                 │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└────────────────────────────────────────────────────────────┘

External Managed Services:
- PostgreSQL RDS (AWS) / Cloud SQL (GCP)
- TimescaleDB (managed TimescaleDB Cloud)
- S3/GCS for object storage
```

### Container Specifications

**Example: Fleet Service Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fleet-service
  namespace: aerovine-production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fleet-service
  template:
    metadata:
      labels:
        app: fleet-service
        version: v1.2.0
    spec:
      containers:
      - name: fleet-service
        image: aerovine/fleet-service:1.2.0
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: REDIS_URL
          value: "redis://redis-master:6379"
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

## Scalability & Performance

### Horizontal Scaling Strategy

**Auto-scaling Rules**:

| Service | Min Replicas | Max Replicas | Scale Up Trigger | Scale Down Trigger |
|---------|--------------|--------------|------------------|-------------------|
| API Gateway | 3 | 20 | CPU >70% for 2 min | CPU <30% for 10 min |
| Fleet Service | 2 | 10 | CPU >70% | CPU <30% |
| Mission Service | 3 | 15 | CPU >70% or 1000 req/min | CPU <30% |
| Telemetry Service | 5 | 30 | CPU >80% or message queue depth >1000 | CPU <30% |
| AI Service | 2 | 10 | GPU utilization >70% | GPU <30% |

**Database Scaling**:
- **PostgreSQL**: Master + 3 read replicas
  - Writes: Master only
  - Reads: Round-robin across replicas
  - Connection pooling: PgBouncer (500 max connections)

- **TimescaleDB**: Continuous aggregates for faster queries
  - Raw telemetry: 10Hz inserts
  - 1-minute aggregates: Pre-computed
  - 1-hour aggregates: Pre-computed
  - Queries use aggregates when possible

- **Redis**: 3-node cluster (master + 2 replicas)
  - Automatic failover
  - Read scaling via replicas

### Performance Optimization

**Caching Strategy**:

| Data | Cache Duration | Invalidation |
|------|----------------|--------------|
| User sessions | 1 hour | On logout |
| Drone positions (latest) | 10 seconds | On new telemetry |
| Weather forecasts | 15 minutes | On API refresh |
| Farm/field metadata | 1 hour | On update |
| Dashboard aggregations | 5 minutes | On new mission completion |

**Database Indexes**:
- See `AEROVINE-DATABASE-SCHEMA.md` for comprehensive index list
- All foreign keys indexed
- Geospatial indexes on PostGIS columns
- Partial indexes for filtered queries (e.g., active missions only)

**Query Optimization**:
- Use database views for complex joins
- Materialized views for analytics (refreshed hourly)
- Avoid N+1 queries (use eager loading)
- Pagination for large result sets (limit 100 per page)

---

## Summary

**AeroVine System Architecture provides**:

✅ **Scalable microservices** - Independent scaling, fault isolation
✅ **Real-time telemetry** - <100ms latency from drone to dashboard
✅ **AI-powered insights** - Disease detection in <15 minutes
✅ **High availability** - 99.9% uptime SLA, multi-region failover
✅ **Security-first** - OAuth 2.0, TLS 1.3, data encryption
✅ **Cloud-native** - Kubernetes, containerized, infrastructure-as-code
✅ **Event-driven** - Asynchronous processing, message queues
✅ **API-first** - RESTful + WebSocket, comprehensive documentation

**Technology Summary**:
- **Languages**: Python (FastAPI), JavaScript/TypeScript (React, Node.js)
- **Databases**: PostgreSQL + PostGIS, TimescaleDB, Redis
- **Storage**: AWS S3 / Google Cloud Storage
- **Orchestration**: Kubernetes (GKE/EKS/AKS)
- **Message Queue**: RabbitMQ / Apache Kafka
- **Monitoring**: Datadog / Prometheus + Grafana
- **AI/ML**: TensorFlow/PyTorch on NVIDIA GPUs

---

**Document Version**: 1.0
**Last Updated**: 2025-12-01
**Architecture Version**: v1.0.0

**For database details, see**: `AEROVINE-DATABASE-SCHEMA.md`
**For API specifications, see**: `acme-ai-api-documentation.md`
