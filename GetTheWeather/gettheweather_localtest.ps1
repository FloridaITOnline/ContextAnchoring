<#
2026 Justin Rodriguez  
Licensed under GPL v3  

*Version 1.1 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)
#>  
  # Be sure to properly update the paths to the files
  # C:\gemini\CodexCliChecker\GetTheWeather\gettheweather_localtest.ps1

  $orchestratorPath = "C:\gemini\CodexCliChecker\GetTheWeather\WeatherOrchastrator.txt"
  $weatherJsonPath  = "C:\gemini\CodexCliChecker\GetTheWeather\weather.txt"
  $outputPath       = "C:\gemini\CodexCliChecker\GetTheWeather\output.txt"

  $orchestrator = Get-Content -Raw $orchestratorPath
  $rawJson      = Get-Content -Raw $weatherJsonPath
  $json         = $rawJson | ConvertFrom-Json

  $weatherData = @"
  Temperature_C: $($json.current.temperature_2m)
  Humidity_%: $($json.current.relative_humidity_2m)
  WindSpeed_mps: $($json.current.wind_speed_10m)
  WindDirection_deg: $($json.current.wind_direction_10m)
  Precipitation_mm: $($json.current.precipitation)
  WeatherCode: $($json.current.weather_code)
"@

  $prompt = @"
  $orchestrator

  Weather data:
  $weatherData

  Return a descriptive yet conscise update on the weather. 100 words or less, please include some personality.
"@

  if ($prompt -is [array]) { $prompt = $prompt -join "`n" }
  $prompt = $prompt.Trim()
  if (-not $prompt) { throw "Prompt is empty." }

  $response = codex exec --skip-git-repo-check "$prompt"

  $weather = $response | Out-String
  Set-Content -Path $outputPath -Value $weather -Encoding utf8