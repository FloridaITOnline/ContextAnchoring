  <#
2026 Justin Rodriguez  
Licensed under GPL v3  

*Version 1.4 — GPL v3 Open Framework*  
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](./LICENSE)
#>
  
  #Set Path
  $weatherPath = "C:\gemini\CodexCliChecker\GetTheWeather\weather.txt"
  
  # Get public IP
  $ip = (Invoke-WebRequest -Uri "https://api.ipify.org").Content.Trim()

  # Get approximate location (free, less precise)
  $geo = Invoke-RestMethod -Uri "http://ip-api.com/json/$ip"

  $lat = $geo.lat
  $lon = $geo.lon
  $url = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,wind_direction_10m"

  $response = Invoke-WebRequest -Uri $url
  $response.Content | Set-Content -Path $weatherPath