# \# OpenGate Mobile App

# 

# Mobile client for opening community gates via OpenGate Cloud Server.

# 

# This app is intentionally simple and server-driven.

# 

# ---

# 

# \## Purpose

# 

# Allow authorized users to open gates through a central server.

# The app acts only as a client and does not communicate directly with hardware or phones.

# 

# ---

# 

# \## Architecture

# 

# \- Flutter mobile app (this repo)

# \- OpenGate Cloud Server (Flask + Redis on Railway)

# \- Single Android phone executing commands via MacroDroid

# 

# The server is the single source of truth.

# 

# ---

# 

# \## Core Design Rules

# 

# \- Polling only (2 seconds)

# \- No background services

# \- No Pushbullet

# \- No device logic in app

# \- One task at a time

# \- Deterministic behavior

# \- Server-driven flow

# 

# ---

# 

# \## App Flow

# 

# 1\. Splash screen (2 seconds)

# 2\. Token validation

# 3\. Gate selection

# 4\. Open request

# 5\. Status polling until completion

# 

# ---

# 

# \## Configuration

# 

# \### Token

# 

# User identity is based on a token.

# The token is stored locally using SharedPreferences.

# 

# ---

# 

# \## Local Development

# 

# ```bash

# flutter pub get

# flutter run

# 

