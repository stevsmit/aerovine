#!/bin/bash

# AeroVine Repository Organization Script
# Organizes files into department directories based on the startup simulation structure

# Create directory structure
mkdir -p marketing
mkdir -p software
mkdir -p sales
mkdir -p finance
mkdir -p hr
mkdir -p manufacturing
mkdir -p website
mkdir -p docs

echo "Created directory structure..."

# Marketing Department Files
echo "Organizing Marketing files..."
mv aerovine-brand-board.html marketing/ 2>/dev/null
mv aerovine-homepage-copy.md marketing/ 2>/dev/null
mv aerovine-30-day-launch-campaign.md marketing/ 2>/dev/null
mv aerovine-press-release-template.md marketing/ 2>/dev/null

# Software Department Files
echo "Organizing Software files..."
mv aerovine-ai-api-documentation.md software/ 2>/dev/null
mv aerovine-ai-api-quick-reference.md software/ 2>/dev/null
mv aerovine-ai-postman-collection.json software/ 2>/dev/null
mv AEROVINE-DATABASE-SCHEMA.md software/ 2>/dev/null
mv AEROVINE-SYSTEM-ARCHITECTURE.md software/ 2>/dev/null
mv AEROVINE-TECHNICAL-REQUIREMENTS.md software/ 2>/dev/null
mv UI-PROTOTYPE-GUIDE.md software/ 2>/dev/null
mv aerovine-dashboard.html software/ 2>/dev/null

# Sales Department Files
echo "Organizing Sales files..."
# Sales-specific files would go here if they exist
# Currently, sales materials might be in marketing or docs

# Finance Department Files
echo "Organizing Finance files..."
# Finance files would include financial models, budgets, etc.
# These might be in CSV format or markdown

# HR Department Files
echo "Organizing HR files..."
mv AeroVine_Employee_Handbook.md hr/ 2>/dev/null
mv "AeroVine Employee Handbook.odt" hr/ 2>/dev/null
mv AeroVine_Job_Descriptions.md hr/ 2>/dev/null
mv AeroVine_Org_Chart_Template.md hr/ 2>/dev/null
mv AeroVine_Performance_Review_Framework.md hr/ 2>/dev/null
mv "AeroVine Employee Startup Document.md" hr/ 2>/dev/null
mv "AeroVine Employment Offer Letter & Agreement.odt" hr/ 2>/dev/null
mv "AeroVine Non-Compete_Non....md" hr/ 2>/dev/null
mv "AeroVine Onboarding Check....md" hr/ 2>/dev/null
mv "AeroVine Background Check Authorization document.md" hr/ 2>/dev/null

# Website Files
echo "Organizing Website files..."
mv index.html website/ 2>/dev/null
mv aerovine-investor-pitch.html website/ 2>/dev/null

# Documentation Files
echo "Organizing Documentation files..."
mv README.md docs/ 2>/dev/null
mv AEROVINE-STARTUP-PACKAGE.md docs/ 2>/dev/null
mv STARTUP-SIMULATION-PACKAGE.md docs/ 2>/dev/null
mv GITHUB_PAGES_SETUP.md docs/ 2>/dev/null

echo "Organization complete!"
echo ""
echo "Directory structure:"
echo "  marketing/     - Brand guides, campaigns, press releases"
echo "  software/      - API docs, technical specs, dashboards"
echo "  sales/         - Sales materials and processes"
echo "  finance/       - Financial models and budgets"
echo "  hr/            - Employee handbooks, job descriptions, org charts"
echo "  website/       - Website HTML files"
echo "  docs/          - General documentation and guides"

