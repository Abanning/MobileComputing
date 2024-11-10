MeetMeHalfway version 1.1
Team: Alex Banning
Date Modified: Nov 9th, 2024

Changes: 
-Generalization of location input entry (can take any valid address, city, or region)
-NearbyResultsView modified to include a more info circle next to favorites button (redirects to AppleMaps but changing that in the future to be more seamless)
-State management handling (can pause/resume)

Future Changes:
-Better details view (native in UI or google maps or yelp api)
-Saving any entered information on background state change (to prevent data loss when app is killed)
-Testing
  -Unit tests
  -Edge case considerations (currently not handling if a midpoint can't be found like in the ocean)
  -Remote region cases
  -Safety considerations of recommendations
-Security considerations
  -Obfuscation/encryption of data
  -PII being used? Not really as of now...
