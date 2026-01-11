# GetTheWeather - Codex CLI Weather Reporter

2026 Justin Rodriguez  
Licensed under GPL v3  

*Version 1.4 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)

This project is a small but fun experiment in turning raw data into personality.  
It’s a local weather-reporting pipeline built with **PowerShell**, **Codex CLI**, and a **Context Anchoring orchestrator**.

Instead of just dumping JSON to a screen, it:
- Grabs live weather data,
- Feeds it into a structured prompt,
- And turns it into a playful, human-sounding forecast — complete with a TV-style personality.

Think: “Weather bot with a soul.”

## Overview

The flow is:
1) Fetch approximate location via public IP and download current conditions from Open-Meteo.
2) Load the orchestrator prompt and weather JSON.
3) Use Codex CLI (authenticated) to generate a weather report.
4) Write the final report to `output.txt`.

Codex CLI requires authentication. A free tier may be available depending on your account and region. Please see Open AI's Install instructions 
https://developers.openai.com/codex/cli

## Files

- `gettheweatherfromwebsite.ps1` - Fetches weather JSON from Open-Meteo (via IP-based geolocation) and writes to `weather.txt`.
- `gettheweather_localtest.ps1` - Loads the orchestrator + weather JSON and calls Codex CLI to generate the report.
- `WeatherOrchastrator.txt` - The Context Anchoring prompt that controls tone and structure.
- `agents.md` - Local instructions Codex reads when executing in this directory.
- `weather.txt` - Latest weather JSON payload.
- `output.txt` - Final weather report output.

## Prerequisites

- PowerShell 7+
- Codex CLI installed and authenticated
- Network access to:
  - `https://api.ipify.org`
  - `http://ip-api.com/json/`
  - `https://api.open-meteo.com`

## Quick Start

1) Fetch weather data:

```
./gettheweatherfromwebsite.ps1
```

2) Generate the weather report:

```
./gettheweather_localtest.ps1
```

3) Read the output:

```
Get-Content .\output.txt
```

## Notes

- The IP geolocation is approximate (free tier). If you want fixed coordinates, replace the geolocation block in `gettheweatherfromwebsite.ps1` with hard-coded `lat`/`lon` values.
- The orchestrator instructs Codex to speak as "Hurricane Harry" (Daytona Channel 7). You can edit `WeatherOrchastrator.txt` to change the persona or constraints.
- The output is written as UTF-8.

## Troubleshooting

- If Codex asks for `AGENTS.md`, make sure `agents.md` exists in this folder.
- If Codex launches an interactive session, the prompt is likely empty or malformed. Check the here-string closing lines in `gettheweather_localtest.ps1`.
- If the weather output is too short or too long, tweak the word/sentence limits in `WeatherOrchastrator.txt`.

## License

GPL v3. See `LICENSE` in the repository root.

---
**Written by:** Justin Rodriguez
