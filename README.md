## Katliey Graphics Order Management System

The Katliey Graphics Order Management System is an integrated software prototype developed by NexGen Solutions for Katliey Graphics Solutions. The system is designed to centralise customer orders, improve communication between customers and the manager, provide order status tracking, and improve the overall management of design orders. The proposed system consists of a Flutter mobile application for customers, an ASP.NET Core Web for the manager/web application, and a shared Supabase backend.

## NexGen Solutions Team Members
Gabatsewe Themba
Mbongo Bongani
Moletsane Lehlohonolo
Ranthako Mahlatse
Botman Phakamile
Lemphane Thapelo

## About NexGen Solutions

NexGen Solutions is a software development team formed as part of a Work Integrated Learning (WIL) project.

Our team is responsible for analysing, designing, developing, testing and documenting an integrated software solution for Katliey Graphics Solutions.

Our team works collaboratively using GitHub for source control and project collaboration.

## Project Overview
Katliey Graphics Solutions currently manages customer orders through different communication channels such as WhatsApp, Facebook, Email, and phone calls.

Because the information is spread across different platforms and orders are manually tracked, the business may experience difficulties such as:

- Lost or overlooked customer inquiries
- Delays in processing orders
- Poor order tracking
- Duplicate orders
- Communication problems
- Missed deadlines
- Difficulty managing a large number of orders

The proposed system provides a centralised platform for managing customer orders and communication.

## Project Objectives
The system aims to:

- Provide customer registration and login.
- Centralise customer and manager information using Supabase.
- Allow the manager/admin to approve or decline order requests.
- Allow customers to view their orders and track their progress.
- Allow customers to view their order history.
- Notify customers when their order is ready for collection.

## Main Features
### Customer Features

- Customer registration
- Customer login
- Create new orders
- Select design services
- View order history
- Track order status
- Update profile information
- Provide feedback after order completion

### Manager Features

- Manager login
- View customer orders
- Approve or decline orders
- Update order status
- Manage customer information
- View order history
- View audit information

### Order Status Tracking

Orders can progress through the following statuses:

- Pending
- In Progress
- Review
- Completed
- Cancelled

## Scope 
### In Scope

The project includes:

- User registration and authentication
- Order creation and management
- Order status tracking
- Flutter Android application
- ASP.NET Core Web API
- Supabase PostgreSQL database
- Real-time order status updates
- Security using authentication and Row Level Security

### Out of Scope

The following features are outside the current project scope:

- Online payment processing
- Multi-language support
- Offline functionality

## System Users Role

### Customer Role

The customer uses the Flutter mobile application to:

- Register and log in
- Place orders
- View order history
- Track orders
- Update profile information
- Provide feedback

### Manager Role

The manager uses the web application to:

- View orders
- Approve or decline orders
- Update order progress
- Manage customer information
- View order history

## System Architecture

The proposed system consists of three main parts:

### Flutter Mobile Application 

The Flutter application is used by customers to:

- Register and log in
- Place orders
- View orders
- Track order progress
- Manage their profile

### ASP.NET Core Web Application/API

The ASP.NET Core component is used for the manager side of the system.

The manager can:

- View customer orders
- Approve or decline orders
- Update order status
- Manage customer information

### Supabase Backend

Supabase provides the shared backend and PostgreSQL database.

It is responsible for:

- Authentication
- Storing customer information
- Storing order information
- Supporting real-time updates
- Database security
