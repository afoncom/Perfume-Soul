# Docker Compose Backend Deploy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Docker Compose deployment path for the Vapor backend and PostgreSQL so the service can be deployed to a VPS.

**Architecture:** `backend/PerfumeSoulBackend` owns its deployment files. `docker-compose.yml` is the shared production base that runs `postgres` with a persistent volume and pulls the backend image from GitHub Container Registry. Local Docker Compose auto-merges `docker-compose.override.yml` to build the backend from the Swift multi-stage Dockerfile. Nginx/HTTPS stays outside Compose on the VPS.

**Tech Stack:** Swift 6, Vapor 4, Fluent PostgreSQL, PostgreSQL 18, Docker Compose.

**Spec:** GitHub issue #102: Docker Compose deployment plan.

## Global Constraints

- Keep deployment files inside `backend/PerfumeSoulBackend`.
- Do not commit production secrets.
- Backend must receive `DATABASE_URL` from environment.
- Backend container must listen on `0.0.0.0:8080`.
- Compose must bind exposed ports to `127.0.0.1` for use behind Nginx.
- Production backend image must default to `ghcr.io/afoncom/perfume-soul-backend:latest` and support `BACKEND_IMAGE_TAG` for pinned deploys.
- PostgreSQL data must persist through a named Docker volume.

---

### Task 1: Backend Container Definition

**Files:**
- Create: `backend/PerfumeSoulBackend/Dockerfile`
- Modify: `backend/PerfumeSoulBackend/.dockerignore`

**Interfaces:**
- Consumes: `Package.swift`, `Package.resolved`, `Sources`
- Produces: Docker image running `/app/PerfumeSoulBackend serve --hostname 0.0.0.0 --port 8080`

- [ ] **Step 1: Add Dockerfile**

Create a multi-stage build that compiles the Vapor app in a Swift image and copies the release binary into a smaller Ubuntu runtime image.

- [ ] **Step 2: Update .dockerignore**

Exclude local build products, SwiftPM metadata, local env files, editor files, and git metadata from the Docker build context.

- [ ] **Step 3: Verify Dockerfile syntax**

Run: `docker build -t perfumesoul-backend .` from `backend/PerfumeSoulBackend`.

Expected: image builds successfully on a machine with Docker and network access.

### Task 2: Compose Runtime

**Files:**
- Create: `backend/PerfumeSoulBackend/docker-compose.yml`
- Create: `backend/PerfumeSoulBackend/docker-compose.override.yml`
- Create: `backend/PerfumeSoulBackend/.env.compose.example`

**Interfaces:**
- Consumes: `POSTGRES_PASSWORD`
- Produces: `postgres` service and `backend` service connected through Compose DNS

- [ ] **Step 1: Add environment example**

Add `.env.compose.example` with `POSTGRES_PASSWORD=change-me`, local `DATABASE_URL`, optional `BACKEND_IMAGE_TAG`, and optional VPS-only `COMPOSE_FILE=docker-compose.yml`.

- [ ] **Step 2: Add docker-compose.yml**

Define `postgres` with database/user/password and named volume. Define `backend` with `image: ghcr.io/afoncom/perfume-soul-backend:${BACKEND_IMAGE_TAG:-latest}`, `DATABASE_URL=postgresql://perfumesoul:${POSTGRES_PASSWORD}@postgres:5432/perfumesoul`, `VAPOR_ENV=production`, and a `/ready` healthcheck.

- [ ] **Step 3: Add docker-compose.override.yml**

Define only local `backend.build` settings so `docker compose up` builds locally while the VPS can pin `COMPOSE_FILE=docker-compose.yml` and pull the GHCR image.

- [ ] **Step 4: Verify Compose syntax**

Run: `POSTGRES_PASSWORD=change-me docker compose config` from `backend/PerfumeSoulBackend`.

Expected: local Compose renders both services, the local build override, and the named volume without validation errors.

Run: `POSTGRES_PASSWORD=change-me docker compose -f docker-compose.yml config`.

Expected: production Compose renders the GHCR backend image without the local build override.

### Task 3: Documentation

**Files:**
- Modify: `backend/PerfumeSoulBackend/README.md`

**Interfaces:**
- Consumes: Dockerfile and docker-compose.yml from earlier tasks
- Produces: developer-facing commands for local Compose run, seed/backfill, VPS update, logs, and Nginx proxy

- [ ] **Step 1: Add Docker Compose section**

Document copying `.env.compose.example` to `.env`, starting Compose, checking logs, and testing `/health`, `/ready`, and `/quiz-of-the-day`.

- [ ] **Step 2: Add seed/backfill commands**

Document how to pipe existing SQL scripts into the PostgreSQL container with `ON_ERROR_STOP=1` and transactions where the script does not already manage its own transaction.

- [ ] **Step 3: Add GHCR publish commands**

Document `docker login ghcr.io` and `docker buildx build --platform linux/amd64 --push` for `ghcr.io/afoncom/perfume-soul-backend:latest` and the current commit tag.

- [ ] **Step 4: Add VPS deployment commands**

Document install prerequisites, clone path, startup command, update command, and Nginx reverse proxy sample.

### Task 4: Verification

**Files:**
- No file changes

**Interfaces:**
- Consumes: all changed files
- Produces: verification evidence

- [ ] **Step 1: Check git diff**

Run: `git diff --check`.

Expected: no whitespace errors.

- [ ] **Step 2: Check Docker availability**

Run: `docker --version` and `docker compose version`.

Expected: if Docker is installed, run build/config checks; if Docker is unavailable, report that runtime verification must be done on the VPS.
