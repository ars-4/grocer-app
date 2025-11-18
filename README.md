# Grocer App (Flutter + Odoo)

Grocer App is a mobile ecommerce application built with **Flutter**,
connected to **Odoo Ecommerce** through a dedicated middleware API
service.

This app communicates with Odoo **via REST APIs** exposed by a Node.js
middleware layer.

🔗 **Middleware Repository:** https://github.com/ars-4/grocer-middleware

------------------------------------------------------------------------

## 🚀 Features

-   Full ecommerce flow
-   Fetch categories, products, orders and customers from odoo
-   Out of the box Mobile app that needs no extra work or backend service
-   Flutter-based mobile UI

------------------------------------------------------------------------

## 📁 Required File: `creds.dart`

You must create a file inside:

    lib/creds.dart

Add the following content:

``` dart
const api = grocer_middleware_hosted_url;

const String odooDBName = odoo_db_name;

const String odooUser = odoo_username;

const String odooPass = odoo_password/api_key;
```

Replace placeholders with your real credentials.

------------------------------------------------------------------------

## ▶️ Demo Video
[Watch the Demo Video](./demo-video.mp4)

------------------------------------------------------------------------

## 🛠️ Requirements

-   Flutter 3.x+
-   Odoo instance with Ecommerce enabled
-   Node.js middleware service (see linked repo)
-   Internet-accessible middleware URL

------------------------------------------------------------------------

## 📦 Getting Started

### 1. Clone the repository

``` bash
git clone https://github.com/ars-4/grocer-app
cd grocer-app
```

### 2. Install dependencies

``` bash
flutter pub get
```

### 3. Add the required credentials file

Create `lib/creds.dart` (see instructions above).

### 4. Run the app

``` bash
flutter run
```

------------------------------------------------------------------------

## 🔗 Related Repository

Middleware (required for app functionality):
👉 https://github.com/ars-4/grocer-middleware

------------------------------------------------------------------------
