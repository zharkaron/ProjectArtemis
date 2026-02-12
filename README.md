# ProjectArtemis

ProjectArtemis is a **local-only personal web platform and home lab environment** designed for experimentation, learning, and personal productivity. It combines web applications for lifestyle management with a secure home lab setup, emphasizing clean backend design, RESTful APIs, and Docker orchestration.

---

## Features

### Web Applications

* **Workout Tracker** – Track calisthenics routines, progress, and personal bests.
* **Recipe Manager** – Store and organize cooking recipes with ingredient lists and serving adjustments.
* **Magic: The Gathering Inventory** – Catalog cards, manage collections, and track trades or decks.

### Home Lab Services

* **VPN** – Secure remote access via WireGuard or OpenVPN.
* **DNS & Ad Blocking** – Local network DNS management with Pi-Hole or Bind.
* **File Sharing & NAS** – Samba-powered network file storage and sharing.
* **Docker Orchestration** – Containerized environment for all applications and services.
* **Reverse Proxy** – Nginx configuration for routing and local web access.

---

## Tech Stack

* **Backend:** Flask (Python)
* **Frontend:** HTML/CSS/JavaScript (minimal, lightweight)
* **Orchestration:** Docker & Docker Compose
* **Web Server:** Nginx
* **Networking:** WireGuard/OpenVPN for VPN, Pi-Hole/Bind for DNS
* **File Storage:** Samba/NAS integration
* **Database:** SQLite/PostgreSQL (for experimentation, configurable)

---

## Project Structure

```
ProjectArtemis/
├─ docker/                # Docker Compose configs and service-specific Dockerfiles
├─ web/                   # Flask applications
│  ├─ workout/            # Workout tracking app
│  ├─ recipes/            # Recipe manager app
│  └─ mtg_inventory/      # Magic: The Gathering inventory app
├─ home_lab/              # VPN, DNS, NAS configurations
├─ nginx/                 # Reverse proxy configurations
├─ data/                  # Persistent volumes for apps and services
├─ scripts/               # Utility and setup scripts
└─ README.md
```

Each service is containerized for modularity, portability, and easy experimentation.

---

## Setup Instructions (Docker-Based)

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/ProjectArtemis.git
cd ProjectArtemis
```

2. **Configure environment variables**
   Copy `.env.example` to `.env` and update settings for:

* VPN credentials
* DNS configurations
* Database connections
* Nginx routing

3. **Start the environment**

```bash
docker compose up -d
```

4. **Access web apps locally** via `http://localhost:<port>` or through Nginx reverse proxy.

5. **Stop environment**

```bash
docker compose down
```

> All data persists in Docker volumes under `data/` for safe experimentation.

---

## Security Philosophy

ProjectArtemis is designed for **local-only, secure experimentation**:

* No public-facing exposure by default.
* VPN ensures encrypted access for any remote connections.
* Nginx acts as a controlled reverse proxy with HTTPS support.
* Docker isolation prevents cross-service contamination.
* Security awareness and clean backend practices are emphasized in all services.

---

## Disclaimer

ProjectArtemis is intended **solely for personal use, learning, and experimentation**. It is **not designed for public deployment**. Users should ensure all networking and data access remains local to avoid unintended exposure.

---

## Future Roadmap

* **Enhanced API Integration:** RESTful APIs for all web apps with token-based authentication.
* **Automated Backups:** Scheduled backups for recipes, workout data, and MTG inventory.
* **Monitoring & Logging:** Container-level metrics, log aggregation, and alerting.
* **Home Lab Expansion:** Integration of additional services (e.g., home automation, media servers).
* **UI Improvements:** More polished frontend interfaces with dynamic dashboards.
* **Mobile-Friendly Access:** Progressive Web App support for personal devices.

---

ProjectArtemis showcases **secure, modular, and containerized backend design**, perfect for developers, security engineers, or recruiters evaluating practical home lab and personal web application experience.
