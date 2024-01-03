 # Sonos API (Unsupported/unofficial)

This Swift package uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network. 

Really useful information regarding the unofficial API: https://svrooij.io/sonos-api-docs/

If you are interested... How to get started with the official Sonos API: https://developer.sonos.com
The issue with the official API is that you need to send network requests to Sonos's servers - i.e. it is a not a local network API. So this incurs network latency, uses your Internet bandwidth, requires setting up a web server, etc, etc. Works really well but painful to use.

* As this uses an unofficial API, this code may break at any time. You may have to tweak the different Sonos models (e.g. AVTransport, GroupRenderingControl, etc.). The network data retrieved is in XML, converted to JSON and then decoded to Swift structures. There is a lot of custom code to do this and the XML conversion is currently not as reliable as it should be.

To learn out in how to use this API, look at the demo at: ????????????????

This API is functional but currently only implements a few of the available API calls; there is a lot more that can be done (e.g. changing volume, tracks, etc.)

* This API currently only supports MacOS *

Coding environment for this package:
 - MacOS 14.2.1
 - Xcode 15.1
