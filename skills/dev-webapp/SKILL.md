---
name: dev-webapp
description: "Generate a production-ready Node/Postgres/SPA web application as a TypeScript monorepo. Use when the user asks to 'create a web app', 'build a Node app', 'React SPA', 'Express API', 'Postgres app', or needs a public-facing web-native app (NOT the .NET Web Forms stack — see dev-webform for that). Scaffolds npm workspaces: packages/engine (pure domain logic), apps/api (Express + pg + zod + session auth), apps/web (React + Vite). Deploys to Namecheap cPanel — see dev-cpanel-deploy."
categories:
  - web-application
  - nodejs
tags:
  - typescript
  - monorepo
  - express
  - postgres
  - react
  - vite
  - zod
  - session-auth
summary: "Node/Postgres/SPA generator: TypeScript npm-workspaces monorepo (engine + Express/pg API + React/Vite SPA), SQL migrations via node-pg-migrate, session auth (express-session + connect-pg-simple + bcryptjs), zod validation, vitest+supertest. Deploys to Namecheap cPanel (see dev-cpanel-deploy)."
source: home-dev
---

# Node / Postgres / SPA Web App Skill

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/dev-webapp/SKILL.md` in the context of THIS repo.
