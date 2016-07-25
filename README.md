# gatekeeper-sspi
GateKeeper SSPI compatible with the esoteric Microsoft GateKeeper SSPI
Both GKSSPv2 and GKSSPv3 are supported.

This is a GateKeeper and GateKeeperPassport client library for use with Node.js.
While node.js is the target, very little effort would be required to change the library for use in bare Javascript.

Usage:
### NPM Installation
$ npm install --save gatekeeper-sspi
### require
var GateKeeperClient = require('gatekeeper-sspi').Client


## gkClient = new GateKeeperClient([host])
(String host) is optional and will cause gatekeeper-sspi to use v3 authentication (instead of the default v2 authentication)
## gkClient.usePassport(String &lt;passportTicket&gt;, String &lt;passportProfile&gt;)
Forces gkClient to use 'GateKeeperPassport' mode. Must be called before gkClient.init()
## gkClient.init()
Returns a Buffer object, containing the initial authentication string.
## gkClient.process(Buffer &lt;data&gt;)
Returns a Buffer object, containing the reply to the supplied data.
If supplied data is unexpected (incorrect), returns Boolean false.

# Contributions: To contribute, please fork and issue a Pull Request. (Hint: README needs updating)
