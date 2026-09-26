# Retail Shop Management: Full-Stack POS System

A comprehensive, full-stack Retail Shop Management and Point of Sale (POS) application. Built with a Flutter frontend and a Node.js/Express backend (MongoDB), this system streamlines retail operations by offering real-time inventory tracking, smart checkout with barcode scanning, dynamic PDF thermal invoice generation, and detailed sales analytics.

## 🎓 Academic Project Details
- **Course:** CSE489: Android App Development
- **Institution:** BRAC University
- **Group:** N/A (Individual Project)

### Developer Details
| Name                 | Student ID | Email                  | Responsibilities                            |
| :------------------- | :--------- | :--------------------- | :------------------------------------------ |
| **Jotee Sarkar Joy** | 22301001   | joysarkar077@gmail.com | Full Stack Development, UI/UX, Backend APIs |

### 💡 Key Concepts Implemented
- **Role-Based Access Control:** Secure multi-tier login system tailored for Admins, Owners, Managers, and Staff, with specific dashboard access.
- **Real-time Inventory Tracking:** Automatic deduction of stock levels during transactions and automated stock restoration for voided/cancelled orders.
- **Barcode Scanning:** Seamless integration with the device camera to scan retail barcodes, rapidly identifying products and adding them to the billing cart.
- **Digital Billing & Checkout:** Dynamic cart system that calculates totals, taxes, and discounts (coupons), and generates a shareable/printable PDF thermal invoice.

## 🎥 Demonstration Video
[Watch the Demonstration Video](https://youtu.be/1WmOnS-DUUo)

## 📄 Project Documents & Source Code
The following important files are available in the repository:
- [Project Report (PDF)](./CSE489_22301001_Jotee%20Sarkar%20Joy_Retail%20Shop%20Management.pdf)
- [Project Report (DOC)](./CSE489_22301001_Jotee%20Sarkar%20Joy_Retail%20Shop%20Management.doc)

## 🚀 Core Features

### Product & Inventory
- **Product Management:** Complete module to seamlessly add, edit, and manage products, pricing, and stock counts.
- **Low-Stock Alerts:** Automated dashboard warnings and interactive adjustment sheets when items fall below a specific quantity to prevent stockouts.

### Sales & Analytics
- **Sales Analytics & Reporting:** Real-time dashboards visualizing today's snapshot, top-selling products, and revenue trends over time.
- **Customer Database Management:** Tracking for walk-in vs. registered customers, their transaction history, and total amount spent.

## 🛠️ Quick Start Guide

### 1. Backend Setup
1. **Navigate to the `backend` directory:**
   ```bash
   cd backend
   ```
2. **Install Dependencies:**
   ```bash
   npm install
   ```
3. **Environment Variables Configuration:**
   Create a `.env` file in the `backend` directory and configure the following variables:
   ```env
   PORT=your_preferred_port
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret
   ```
4. **Start the Application:**
   ```bash
   npm start
   ```

### 2. Frontend Setup
1. **Navigate to the project root directory:**
   ```bash
   cd ..
   ```
2. **Install Flutter Packages:**
   ```bash
   flutter pub get
   ```
3. **Run the Application:**
   ```bash
   flutter run
   ```

## 💻 Technology Stack
- **Frontend Framework:** Flutter (with Provider & go_router)
- **Frontend Packages:** `mobile_scanner`, `pdf`, `printing`, `fl_chart`
- **Backend Environment:** Node.js
- **Backend Framework:** Express.js
- **Database:** MongoDB (via Mongoose)
- **Authentication:** JWT (JSON Web Tokens)

## 🔮 Future Enhancements / Technical Deep Dive
- **Multi-Branch Synchronization:** Allow super-admins to manage centralized inventory pushed out to multiple localized retail branches.
- **Offline Mode:** Enable the POS system to function without an internet connection, seamlessly syncing transactions to the backend once the connection is restored.
- **AI Sales Forecasting:** Utilize historical transaction data to predict future sales trends and automatically suggest restock quantities.
- **Customer Loyalty Program:** A point-based reward system integrated into the checkout process based on a customer's total spent history.
- **Supplier & Purchase Orders:** A dedicated module to track suppliers, generate purchase orders, and automatically log incoming deliveries into the inventory.
