Usage:

Install the Google Maps POD, run:

   pod update GoogleMaps

After that, open Geocube.xcworkspace in Xcode and under Supporting
Files, copy the file EncryptionKeysExample.plist to EncryptionKeys.plist
and populate with the information you have (Google Maps key,
Geocaching Australia API consumer, shared secrets). This file is
not supposed to be in the SCCS as it contains secret information.

To obtain the keys: 
- Geocaching Australia key: http://geocaching.com.au/api/services/
- Google Maps key: https://developers.google.com/maps/documentation/ios-sdk/start
- Mapbox key: https://www.mapbox.com/studio/

The shared secrets are (currently only) used to hide the API keys
hidden downloaded via geocube_sites.geocube:

    <oauth_key_public sharedsecret="1">
is encoded with "shared_secret_1":
    <key>sharedsecret_1</key>
    <string>foobar</string>


Then build and run!
