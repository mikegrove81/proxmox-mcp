---
name: dev-cpanel-deploy
description: "Deploy a Node.js + Postgres app to Namecheap Stellar cPanel shared hosting over SSH. Use when the user asks to 'deploy to cPanel', 'deploy to Namecheap', 'push the app live', 'set up the Node app on the server', or needs the SSH/git-pull + build + migrate + Node.js App configuration procedure. Shared deploy skill for the Node/static/WordPress stacks; the Node/Postgres/SPA build itself is dev-webapp."
categories:
  - deployment
  - ops
tags:
  - cpanel
  - namecheap
  - nodejs
  - postgres
  - ssh
  - deployment
  - lsnode
summary: "Namecheap cPanel deploy procedure for Node/Postgres apps: domain + Postgres db setup, passphrase-less SSH deploy key, server git pull, npm build, node-pg-migrate, cPanel Node.js App config + env vars, LiteSpeed lsnode restart, and verification. Links references/cpanel-namecheap-nodeapp-gotchas.md for hard-won failure modes."
source: home-dev
---

# Namecheap cPanel Deploy Skill

> **Wrapper skill** - source of truth is in home-dev.

Read and follow `../home-dev/skills/dev-cpanel-deploy/SKILL.md` in the context of THIS repo.
