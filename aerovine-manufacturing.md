# Manufacturing Department: Mission & Objectives

The mission of the Manufacturing Department at AeroVine is to simulate production operations. This department focuses on designing the necessary workflows, documentation, and systems required to transition the AI-first drone product from design into scalable production.

## Production Planning (Production Workflow and Quality Systems)

- Design a production workflow for assembling agricultural drones optimized for vineyard monitoring and spraying at scale. Detail the stages of payload integration and sensor calibration.
- Generate a parts catalog with specifications for vineyard drone components, including corrosion-resistant frames, high-precision GPS, and liquid payload systems.
- Create a quality control checklist for drone manufacturing, specifically focusing on flight stability, spray nozzle uniformity, and GPS accuracy needed for vineyard operations.

## Manufacturing Dashboard and Documentation

- Create a manufacturing dashboard showing production metrics, quality scores, and inventory levels for specialized agricultural drone sensors.
- Generate maintenance schedules and equipment documentation for corrosion-prone drone assembly tools and calibration rigs used in the manufacturing environment.
- Design a work order system for custom vineyard drone configurations, detailing steps for sensor selection, payload modification, and final client sign-off.

---

## Vineyard Drone Manufacturing Workflow

*[Image: Manufacturing Workflow Diagram]*

1. Assemble the carbon-fiber frame. Apply specialized corrosion-resistant coating and seals to all internal joints and battery compartments.
2. Mount all motor arms and Electronic Speed Controllers (ESCs). Install propellers and dynamically balance them for minimal vibration.
3. Mount the Flight Controller unit and connect primary power, ESC, and Global Positioning System (GPS) lines. Perform initial firmware flash with the base flight parameters.
4. Mount the High-Precision Real-Time Kinematic (RTK) with L1 and L5 GPS units. Install the required Multispectral/Light Detection and Ranging (LiDAR) sensor payload mount. Ensure sensors are vibration-isolated.
5. Mount the reservoir/tank. Install pumps, tubing, and the specialized nozzle manifold designed for targeted vine spraying.
6. Inertial Measurement Unit (IMU) Calibration. Magnetometer Calibration. Compass Calibration for navigation accuracy.
7. Sensor Calibration (such as, Normalized Difference Vegetation Index (NDVI)). Payload Weight Calibration (compensate for a full spray tank).
8. Dry-Run Spray Test (verify pump pressure/uniformity). Communication Check. Ground Station Integration check.
9. Seal all external ports. Perform a Final Visual Inspection. Record all unique serial numbers for components.
10. Load user maintenance protocols. Package the drone with spare nozzles and quick-start guides.

---

## Parts Catalog with Specifications for Vineyard Drone Components

*[Image: Parts Catalog Diagram]*

### Table 1: Core Structure and Propulsion (Corrosion-Resistant) Part Specifications

| Component Name | Model/Type | Key Specification | Purpose & Anti-Corrosion Measure |
|:---------------|:-----------|:-----------------|:----------------------------------|
| Main frame arms | X8 Folding Arm Unit | T700 Grade Carbon Fiber with Epoxy Resin Seal | Provides high strength; epoxy sealing prevents chemical ingress and corrosion. |
| Central Hub/Motor Mounts | CNC Milled Aluminum Alloy | 7075-T6 Aluminum, Anodized (Mil-Spec Type III) | High stiffness and durability; heavy-duty anodization resists acid/alkaline residue from sprays. |
| ESC | Field-Oriented Control (FOC) 80A | IP67 Waterproof and Dustproof | Essential protection against spray drift and moisture intrusion. |
| Propellers | High-Efficiency Folding Propellers | Glass Fiber Reinforced Nylon (GF-Nylon) | Optimized for heavy lift (payload); Nylon provides superior chemical resistance compared to standard composites. |

### Table 2: High-Precision Navigation and Control Parts Specification

| Component Name | Model/Type | Key Specification | Purpose & Accuracy |
|:---------------|:-----------|:-----------------|:-------------------|
| Flight Controller (FC) | Triple-Redundancy Flight Stack | STM32H753, GNSS Ports: Dual RTK Input | High processing power for real-time kinematic calculations and complex mission planning. |
| High-Precision GPS/GNSS | RTK/PPK Dual-Frequency Module | GPS L1/L5, Glonass L1/L2, Galileo E1/E5 | Centimeter-level precision (±1 cm). Crucial for staying centered over narrow vine rows and repeatability. |
| Inertial Measurement Unit (IMU) | Triple-Redundant Sensor Array | Dampened Mount (Gel/Foam) | Ensures stable flight and accurate sensor readings even under heavy payload turbulence. |

### Table 3: Liquid Payload and Spray System Parts Specification

| Component Name | Model/Type | Key Specification | Purpose & Efficiency |
|:---------------|:-----------|:-----------------|:---------------------|
| Liquid Tank/Reservoir | Quick-Swap Modular Tank | High-Density Polyethylene (HDPE) | HDPE offers excellent resistance to degradation from agricultural chemicals and minimizes corrosion risk. |
| High-Volume Pump | Diaphragm Pump System | 4–6 Liters per Minute (L/min) | Provides consistent pressure necessary for fine, uniform spray droplet size and coverage. |
| Spray Nozzle Manifold | Targeted Valve Manifold | Stainless Steel / Ceramic Tips | Individual nozzle control via solenoid valves. Stainless steel resists corrosion better than standard brass/plastic. |
| Flow Sensor | Digital Hall Effect Sensor | ±1% of measured flow rate | Provides real-time feedback to the FC for precise control over chemical dosage (Variable Rate Application). |

---

## Quality Control Checklist: Vineyard Agricultural Drone

This checklist is tailored for the high-precision requirements of vineyard operations, ensuring that the drone is chemically resistant, stable in flight, and accurate in its spraying and navigation capabilities.

### Phase 1: Structural and Environmental Durability Checks (Corrosion Resistance)

| ID | Component/System | Check Standard | Pass/Fail | Notes |
|:---|:-----------------|:---------------|:----------|:------|
| S-1 | Frame Sealing & Coating | Verify application of corrosion-resistant epoxy/sealing on all central hub joints and battery tray edges. | | |
| S-2 | Motor Mount Integrity | Confirm proper torque specifications on all motor mount bolts and check for zero play/wobble. | | |
| S-3 | ESC Housing Integrity | Verify all ESC units have the required IP67 rating housing protection to guard against spray moisture. | | |
| S-4 | Liquid Tank/Mounts | Confirm the tank material is High-Density Polyethylene (HDPE) and mounting securement is free of strain points. | | |

### Phase 2: Navigation & GPS Accuracy Checks

| ID | Component/System | Check Standard | Pass/Fail | Notes |
|:---|:-----------------|:---------------|:----------|:------|
| G-1 | GPS Initialization | Verify RTK/PPK module achieves a **"FIXED"** status lock within 60 seconds (requires clear sky simulation). | | |
| G-2 | Magnetometer Calibration | Confirm the compass offset reading is within acceptable manufacturing tolerance (≤5 degrees). | | |
| G-3 | Static GPS Accuracy | After achieving RTK lock, verify the reported position drift is ≤1 cm over a 5-minute period (bench test). | | |
| G-4 | Vibration Isolation | Verify the Flight Controller (FC) and IMU mounting gel/dampers are installed correctly to minimize vibration influence on GPS/IMU readings. | | |

### Phase 3: Flight Stability & Control Checks

| ID | Component/System | Check Standard | Pass/Fail | Notes |
|:---|:-----------------|:---------------|:----------|:------|
| F-1 | Propeller Balancing | Verify all propellers are dynamically balanced; deviation must be below 0.5 mg/inch. | | |
| F-2 | Motor Consistency | Run motors at 50% throttle; measure current draw across all four motors—deviation must be ≤2% across the set. | | |
| F-3 | Flight Controller (FC) Setup | Verify failsafe protocols (Loss of Signal, Low Battery) are correctly configured and trigger. | | |
| F-4 | Load Compensation | Test FC's ability to maintain stability with a full payload simulation (weights equal to a full spray tank). | | |

---

## Manufacturing Dashboard

The following dashboard shows production metrics, quality scores, and inventory levels for specialized agricultural drone sensors:

*[Image: Manufacturing Dashboard - Production Metrics]*

*[Image: Manufacturing Dashboard - Quality Scores and Inventory]*

---

## Maintenance Schedules and Equipment Documentation

Maintenance schedules and equipment documentation for corrosion-prone drone assembly tools and calibration rigs used in the manufacturing environment are documented as follows:

### Daily or Shift-End Maintenance

| Equipment | Maintenance Tasks | Purpose |
|:----------|:-----------------|:--------|
| Tooling & Fixtures (Used near sealing/coating stations) | Wipe down with neutral pH industrial cleaner to remove chemical residue. | Prevents chemical hardening and long-term corrosion. |
| Assembly Work Surfaces | Clean and dry all exposed metal surfaces. | Eliminates standing moisture and residual corrosive agents. |
| RTK/GPS Calibration Rig | Dust and debris inspection; check cable integrity. | Ensures the rig remains clean and stable for accurate measurements. |

### Weekly Maintenance

| Equipment | Maintenance Tasks | Purpose |
|:----------|:-----------------|:--------|
| All Assembly Torque Tools | Calibration check against a certified standard. | Maintains precision necessary for structural integrity and motor mounting. |
| Fluid System Assembly Tools (Pump/Nozzle Fitters) | Disassemble, clean, and lubricate seals (using chemical-resistant grease). | Prevents seizing and maintains the integrity of the sealing surfaces. |
| Inventory & Part Racks | Inspect storage areas for signs of moisture or rust; replace desiccant packs if humidity is high. | Protects unsealed inventory from atmospheric corrosion. |

### Quarterly Maintenance

| Equipment | Maintenance Tasks | Purpose |
|:----------|:-----------------|:--------|
| RTK/GPS Calibration Rig | Full diagnostic check and re-certification by a qualified technician. | Guarantees that the precision required for centimeter-level accuracy is maintained. |
| Power Supply Units (PSUs) | Inspect cooling fans and ventilation for blockage (dust/chemical residue). | Prevents overheating and premature failure of critical electronic controls. |
| Corrosion Protection Re-application | Inspect frame assembly jigs and specialized tools; re-apply protective coatings or waxes if wear is observed. | Reinforces the primary defense against long-term material degradation. |

Each critical piece of equipment or rig must have comprehensive documentation available to manufacturing staff and maintenance technicians.

### RTK/GPS Calibration Rig Operating Manual

This document is essential for maintaining the accuracy of the navigation systems.

- **Calibration Procedure:** Step-by-step instructions for performing daily, shift, and weekly internal accuracy checks.
- **Drift Tolerance:** Specific acceptable deviation standards (e.g., maximum ±1 cm position drift).
- **Troubleshooting Guide:** Flowchart for addressing "No FIX" or high-drift error codes.
- **Certification Log:** Record of the last formal external certification date and due date.

### Frame Assembly Jig & Tooling Manual

This documentation focuses on preserving the tools used for structural integrity and corrosion prevention.

- **Material Compatibility:** List of approved cleaning agents and lubricants that do not react with the protective coatings.
- **Torque Sequence Diagrams:** Visual representation of the motor mount and frame bolt tightening order and specified Newton-meter (Nm) values.
- **Corrosion Inspection Guide:** Visual standards (images/diagrams) showing acceptable vs. unacceptable levels of coating wear or surface rust.

### Spray Nozzle Manifold Assembly Tool Kit Log

This log tracks the maintenance and calibration status of specialized tools used for liquid payload systems.

- **Tool Inventory:** Complete list of all tools in the kit (solenoid valve testers, flow rate meters, pressure gauges).
- **Calibration Schedule:** Dates for periodic recalibration of measurement tools (e.g., flow sensors, pressure gauges).
- **Chemical Exposure Limits:** Maximum recommended exposure time before mandatory cleaning is required.

---

## Custom Configuration Work Order System

*[Image: Work Order System Flow Diagram]*

### Phase 1: Sales & Design Handoff (Pre-Production)

1. **Client Requirements Lock:** Sales confirms and documents final client needs (e.g., vineyard size, crop density) via a signed Statement of Work (SOW).
2. **Sensor Selection & Specification:** Design specifies the required sensor (Multispectral/LiDAR) and the corresponding mounting solution ID from the Parts Catalog.
3. **Payload Modification Approval:** Design defines the specific liquid payload requirements (tank volume, nozzle size, material) for the wine application.
4. **Final BOM Generation:** Manufacturing creates the finalized Bill of Materials (BOM) based on specifications and verifies inventory stock.

### Phase 2: Manufacturing & Custom Integration

1. **Core Assembly & Sealing:** Assemble the base frame and apply the corrosion-resistant seals.
2. **Custom Payload Integration:** Install the specific liquid tank and custom nozzle manifold as defined by the design requirements.
3. **High-Precision Sensor Mounting:** Mount and connect the chosen RTK/L5 GPS and sensor package, ensuring vibration dampening is correct.
4. **Specialized Calibration:** Perform system-level testing to compensate for the custom payload weight and verify specialized sensor outputs (e.g., NDVI accuracy, flow rate).

### Phase 3: Final Acceptance & Closure

1. **Final QA Demonstration:** Manufacturing performs a final functional test, recording successful RTK lock and payload activation in the work order log.
2. **Client Sign-Off:** The client verifies the drone matches the SOW and signs the acceptance form, activating the warranty.
3. **Work Order Closure:** All documentation (BOM, test results, calibration logs, and sign-off form) is archived. The drone is marked "Shipped," and the invoice is generated.

---
