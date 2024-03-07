<div align="center">

  <h1>Sonos API (Unsupported/Unofficial)</h1>
  
  <p>
    This Swift package uses unsupported (i.e. unofficial) Sonos API requests to access Sonos devices on the local network.

  </p>
  
  
<!-- Badges -->
<p>
  
  ![Static Badge](https://img.shields.io/badge/macOS-14%2B-greeen)
  ![Static Badge](https://img.shields.io/badge/Xcode-15%2B-blue)

</p>
</div>

## About the Project

The issue with the official API is that you need to send network requests to Sonos's servers - i.e. it is a not a local network API. This incurs network latency, uses your Internet bandwidth, requires setting up a web server, etc, etc. Works really well but painful to use.

- As this is an unofficial API, this code may break at any time. You may have to tweak the different Sonos models (e.g. AVTransport, GroupRenderingControl, etc.). The network data retrieved is in XML, converted to JSON and then decoded to Swift structures.

- This API is functional but curently only implements a few of the available API calls; there is a lot more that can be done.

### Installation

To install this package in Xcode: Specify https://github.com/denisblondeau/SonosAPI as a package dependency. The most stable version can be found under Releases (i.e. 1.0.1, etc.). The main branch is considered experimental and is not as stable as the latest release.

To use, just import the SonosAPI module in your Swift code:

```bash
  import SonosAPI
```

### Demos

SonosAPIDemo: MacOS/Swift example on how to use this API: https://github.com/denisblondeau/SonosAPIDemo

SonosRemote: MacOS/Swift application that sends commands (Play/Pause, Previous/Next Track, Volume Up/Down) to a Sonos controller: https://github.com/denisblondeau/SonosRemote

## Roadmap

- [x] Functional, basic API.
- [x] More demos.
- [ ] Documentation.
- [ ] Full Sonos API implementation.

## License

Distributed under the MIT License. See LICENSE.txt for more information.

## Acknowledgements

Useful resources and libraries.

- [Really useful information regarding the unofficial API](https://svrooij.io/sonos-api-docs/)
- [How to get started with the official Sonos API](https://developer.sonos.com)
