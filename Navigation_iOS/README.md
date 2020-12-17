# Navigation_iOS

<img src="https://img.shields.io/badge/swift5.0-compatible-4BC51D.svg?style=flat" alt="Swift 5.0 compatible" /></a>

In-app navigation with apple maps (if they are supported in the user's country) or in google maps as a fallback.
An other option is to navigate to a destination using an external app (waze, 2gis, google maps, apple maps - navigon and sygic are still incomplete) installed on the device

### Notes:

- Useful icons list: [gmapsdevelopment](https://sites.google.com/site/gmapsdevelopment/)
- Google maps sdk 'Directions API' requires billing info (free up to 1000 calls)
- pList addition:
  1. In-app or external google maps view / navigation
  2. google image tap for google maps sdk
  3. check for the rest of the external apps
```swift
 <key>LSApplicationQueriesSchemes</key>
 <array>
     <string>comgooglemaps</string>
     <string>googlechromes</string>
     <string>waze</string>
     <string>dgis</string>
     <string>com.sygic.aura</string>
 </array>
```


### Sample images

<img src="https://raw.githubusercontent.com/nicolaouG/Navigation_iOS/master/IMG_0001.PNG" width="150"/> <img src="https://raw.githubusercontent.com/nicolaouG/Navigation_iOS/master/IMG_0002.PNG" width="150"/> <img src="https://raw.githubusercontent.com/nicolaouG/Navigation_iOS/master/IMG_0003.PNG" width="150"/> <img src="https://raw.githubusercontent.com/nicolaouG/Navigation_iOS/master/IMG_0004.PNG" width="150"/>
