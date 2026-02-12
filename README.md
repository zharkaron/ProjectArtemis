# ProjectArtemis

**ProjectArtemis** is a local-only personal web platform built with Flask and Docker, designed as a home lab project for backend engineering and security-focused development.

The purpose of this project is to serve as a structured learning environment for:

* Backend architecture design
* RESTful API development
* Secure coding practices
* Containerization with Docker
* Linux-based deployment workflows

ProjectArtemis is intentionally **not intended for public deployment**. It exists as a controlled environment to practice building production-quality systems with strong architectural and security foundations.

---

## 🚀 Features

### 🏋 Workout Tracking

* Track calisthenics-based routines
* Log sets, reps, and progression
* Structured data model for workout sessions

### 🍳 Recipe Management

* Store and manage cooking recipes
* Track ingredients and measurements
* Designed for future serving-size scaling logic

### 🂯 Magic: The Gathering Inventory

* Maintain a structured card inventory
* Track card metadata and collection details
* Designed with extensibility in mind

### 🔒 Security-Oriented Backend Design

* Authentication architecture (planned/implemented progressively)
* Input validation and data integrity enforcement
* Role-based access control concepts
* Secure Docker-based isolation
* Environment variable management for secrets

---

## 🧱 Tech Stack

| Layer             | Technology                                                   |
| ----------------- | ------------------------------------------------------------ |
| Backend Framework | Flask (Python)                                               |
| Containerization  | Docker & Docker Compose                                      |
| OS Environment    | Linux                                                        |
| Version Control   | Git & GitHub                                                 |
| Database          | (SQLite/PostgreSQL – depending on environment configuration) |
| API Style         | RESTful principles                                           |

---

## 📁 Project Structure Overview

```
ProjectArtemis/
│
├── app/                  # Main Flask application package
│   ├── __init__.py       # Application factory
│   ├── config.py         # Configuration management
│   ├── models/           # Database models
│   ├── routes/           # API route definitions
│   ├── services/         # Business logic layer
│   └── utils/            # Helpers and validation logic
│
├── docker/               # Docker-related configuration
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── instance/             # Local configuration & database files
│
├── tests/                # Unit and integration tests
│
├── .env                  # Environment variables (not committed)
├── requirements.txt      # Python dependencies
└── README.md
```

The architecture separates:

* Routing (HTTP layer)
* Business logic (service layer)
* Data models (persistence layer)

This separation improves maintainability, testability, and long-term scalability.

---

## ⚙️ Setup (Docker-Based)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/yourusername/ProjectArtemis.git
cd ProjectArtemis
```

### 2️⃣ Create Environment Variables

Create a `.env` file in the project root:

```
FLASK_ENV=development
SECRET_KEY=change_this_in_production
DATABASE_URL=sqlite:///artemis.db
```

*(This project is local-only, but secure secret handling practices are still followed.)*

### 3️⃣ Build and Start the Containers

```bash
docker compose up --build
```

### 4️⃣ Access the Application

By default:

```
http://localhost:5000
```

---

## 🔒 Security Philosophy

ProjectArtemis is built with a **security-first mindset**, even though it is local-only.

Core principles:

* **Least Privilege** – Containers and services run with minimal required permissions.
* **Input Validation** – All user inputs are validated and sanitized.
* **Separation of Concerns** – Business logic is isolated from routing logic.
* **Environment-Based Configuration** – Secrets are not hard-coded.
* **Container Isolation** – Application runs in Docker to reduce host exposure.
* **Secure Defaults** – Debug modes and sensitive configurations are environment-controlled.

The project serves as a safe environment to learn defensive backend design and understand common web security considerations in practice.

---

## ⚠️ Local-Only Disclaimer

ProjectArtemis is intentionally designed for **local development and learning purposes only**.

It is:

* Not hardened for internet exposure
* Not configured for public deployment
* Not intended to handle real user traffic

If adapted for public deployment, additional security controls (HTTPS enforcement, hardened authentication, rate limiting, logging infrastructure, production-grade database configuration, etc.) would be required.

---

## 🗽️ Future Roadmap

Planned improvements include:

* Full RESTful API structure with versioning
* Token-based authentication (JWT or session-based)
* Role-based access control (RBAC)
* Pagination and filtering for API endpoints
* Structured logging and audit logging
* Unit and integration test expansion
* CI workflow integration (GitHub Actions)
* Database migration tooling
* API documentation (OpenAPI/Swagger)

---

## 🎯 Purpose of This Project

ProjectArtemis represents:

* A practical backend engineering lab
* A security-conscious development approach
* A structured progression from beginner to production-ready design principles
* A foundation for understanding real-world API systems

It demonstrates the ability to:

* Design clean backend architecture
* Work within containerized environments
* Apply secure coding principles
* Maintain organized, scalable project structure

---

**Author:** Daron Valdivia
**Environment:** Linux + Docker
**Project Type:** Local Development / Home Lab Backend System
