crypto = require 'crypto'
uuid = require 'node-uuid'

module.exports = class GateKeeper
  # Private class with useful functions. NOT EXPOSED.

  @newGUID = -> uuid.v4 { }, Buffer.allocUnsafe 16

  @emptyGUID = -> Buffer.from [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  _createKey = (pad, arr) -> # Function to make writing keys easier
    buf = Buffer.alloc 64, pad, 'binary'
    Buffer.from(arr).copy buf
    return buf

  Key1 = _createKey 0x36, [
    0x65, 0x64, 0x70, 0x7B, 0x7D, 0x65, 0x7C, 0x77,
    0x78, 0x72, 0x64, 0x73, 0x65, 0x7D, 0x7D, 0x75,
  ]

  Key2 = _createKey 0x5C, [
    0x0F, 0x0E, 0x1A, 0x11, 0x17, 0x0F, 0x16, 0x1D,
    0x12, 0x18, 0x0E, 0x19, 0x0F, 0x17, 0x17, 0x1F
  ]

  md5 = (data) -> # Takes Buffer, returns Buffer
    return do
      crypto.createHash 'md5'
      .update data
      .digest

  @Signature: Buffer.from [0x47, 0x4B, 0x53, 0x53, 0x50, 0x00]

  @OK: Buffer.from [0x4F, 0x4B]

  constructor: ->
    # Defaults:
    @version = 2
    @passport = false
    @msgType = 0
    @type = 'GateKeeper'

  calculate: (challenge) -> # This is where the magic is done!
    if challenge !instanceof Buffer
      throw TypeError 'challenge must be a Buffer'

    if @version is 3 # GKSSPv3
      buf = Buffer.allocUnsafe challenge.length + @host.length # temporary buf
      challenge.copy buf # Copy original challenge to new buffer
      buf.write @host, challenge.length, @host.length, 'binary' # Add host
      challenge = buf # update 'challenge' variable

    b1 = Buffer.allocUnsafe Key1.length + challenge.length # buffer1
    Key1.copy b1 # Copy key1 to buffer1
    challenge.copy b1, Key1.length # Copy key1 to buffer1
    b2 = md5 b1 # buffer2 - md5 of buffer1
    b3 = Buffer.allocUnsafe Key2.length + b2.length # buffer3
    Key2.copy b3 # Copy key2 to buffer3
    b2.copy b3, Key2.length # Append buffer2 to buffer3
    return md5 b3 # The final result is md5 of buffer3

  createHeader: (version, msgType) ->
    header = Buffer.allocUnsafe 16 # New buffer
    GateKeeper.Signature.copy header # Add header to buffer
    header.writeUInt32LE version, 8 # Add version to buffer
    header.writeUInt32LE msgType, 12 # Add msgType to buffer
    return header # return buffer

  readHeader: (data) -> # Takes header, returns Object
    return Object.freeze # Can't be modified - Ever!
      signature: data.slice 0, 6
      version: data.readUInt32LE 8
      msgType: data.readUInt32LE 12
