# Project Overview

## What is SPANR?

SPANR is a **mechanic booking platform targeting the Indian automotive service market**. It connects vehicle owners with mechanic companies and manages the end-to-end service workflow.

## Problem Solved

- Vehicle owners struggle to find reliable, nearby mechanics and book appointments
- Mechanic businesses lack digital tools to manage bookings, assign work to staff, and maintain service records
- No standardized digital service history for vehicles in India

## Users

| User Type | Application | Role |
|---|---|---|
| Vehicle owner (customer) | `spanr_app` (Flutter mobile) | Discover mechanics, book services, pay, track orders |
| Mechanic company owner/admin | `spanr-mechanic` (React web) | Manage company profile, services, staff, orders |
| Mechanic employee | `spanr-mechanic-app` (Flutter mobile) | Receive job assignments, execute and document work |

## Core Features

### For Customers
- Location-based mechanic discovery (7km radius)
- Service and plan browsing with pricing
- Vehicle management (add multiple vehicles with photos)
- Address management
- Booking flow with before-service photo capture
- Razorpay payment integration
- Order status tracking with real-time updates
- Complete service history per vehicle

### For Company Owners (Dashboard)
- Company profile management with KYC document upload
- Service and plan management with detailed configuration (pricing, fuel types, features, FAQs, steps)
- Staff management (create mechanics, provision credentials, reset passwords)
- Order management with status transitions and mechanic assignment
- Vehicle history lookup by license plate
- Order detail with job card, service notes, parts used

### For Mechanic Employees (Mobile)
- Receive real-time job assignments
- Step-by-step job execution workflow
- Before and after inspection photo capture (4 angles each)
- Parts replacement logging with photos
- Service notes
- Job completion with odometer reading
- Offline support with sync queue

## Business Domain

- **India-specific**: INR currency, `+91` phone prefix, Indian license plate format, Razorpay (Indian payment gateway)
- **Vehicle types**: car and bike
- **Service location types**: in-shop, doorstep, etc.
- **Order lifecycle**: `created → accepted → assigned → in_progress → (waiting_for_parts) → ready_for_delivery → completed` with `cancelled` and `dispute` side states
- **Multi-tenant**: each mechanic company is a completely isolated tenant

## Business Model Indicators

- Company onboarding with KYC (GST certificate, PAN card, utility bill)
- Plans with base price + tax breakdown
- Warranty and guarantee fields on plans
- Staff attendance tracking
- Denormalized vehicle service history (permanent record per completed job)
