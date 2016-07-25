GateKeeper = require './gatekeeper.coffee'

module.exports = class GateKeeperClient extends GateKeeper

  constructor: (@host) ->
    super
    if @host?
      @version = 3

  usePassport: (@ticket, @profile) ->
    if @msgType > 0
      throw Error 'GateKeeper already initialized'
    if !@ticket? || !@profile?
      throw SyntaxError 'PassportTicket and PassportProfile are required'
    @passport = true
    @type = 'GateKeeperPassport'

  passportStringify: (str) ->
    pre = (("00000000" + str.length.toString(16)).substr -8) + str

  init: ->
    @msgType = 1
    return @createHeader @version, @msgType++

  process: (data) ->
    if data !instanceof Buffer
      throw TypeError 'data must be a Buffer'

    if @msgType is 2 # Challenge
      if data.length isnt 24 # Check length is header + 8 bytes
        return false

      header = @readHeader data.slice 0, 16
      if ((header.signature.equals GateKeeper.Signature) is false) or
         (header.version isnt @version) or
         (header.msgType isnt @msgType++)
        return false

      newBuffer = Buffer.alloc 48
      (@createHeader @version, @msgType++).copy newBuffer # Add header
      (@calculate data.slice 16).copy newBuffer, 16 # Append challenge response

      if (@passport is true)
        newGUID = GateKeeper.emptyGUID()
      else
        newGUID = GateKeeper.newGUID()
      newGUID.copy newBuffer, 32 # Append GUID
      console.log newBuffer
      return newBuffer

    else if @msgType is 4 and @passport is true
      if (data.equals GateKeeper.OK) isnt true
        return false

      @msgType++
      return (@passportStringify @ticket) +
             (@passportStringify @profile)

    else
      return false # Unexpected data received
