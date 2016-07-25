net = require 'net'
GateKeeper = require './index.coffee'
GKClient = GateKeeper.Client

host = '199.116.113.167'
#host = '199.116.113.93'
gk = new GKClient host
gk.usePassport '5cqAnppTuO0vIMwGT9r5vDqr5bnOitqFkR2aw3JlNsYJ3oLx*DC8pUZf*fYsfX95k1mOWJcmEydze34n1*XKFDA$$', '5OaPxEnvNnemccNRwiM5*ZqFIB5jbstkazx7IXA1DWU*ICxLI7pKBLPl7TS74JfDA*BgcetkCXd3bZdMqPd3qcxdFAGKIx2UL51cl99DvtGbIV4f5s17agwdRrC26o58oKWlWg4dNIv4BSR9*3xc7tv0WomAR9SaWo4rlzw2FB*X3NIUdtnf5PQ$$'

client = net.createConnection {
  port: 6667
  host: host
}, ->
  console.log '** Connected'
  write "AUTH #{ gk.type } I :#{ authescape gk.init() }"

write = (data) ->
  console.log '->', data.toString 'binary'
  client.write Buffer.from "#{ data.toString 'binary' }\r\n", 'binary'

client.on 'data', (data) ->
  arrData = data.toString('binary').split('\r').join('\n').split('\n')
  for line in arrData
    continue if line is '' # Skip empty lines
    console.log "<- #{ line }"
    word = line.split ' '
    if word[0] is 'AUTH'
      if word[2] is 'S'
        authData = Buffer.from authunescape word[3].substr 1
        authReply = authescape gk.process authData
        oBuf = Buffer.allocUnsafe (9 + gk.type.length + authReply.length)
        t = "AUTH #{ gk.type } S :"
        authReply.copy oBuf, oBuf.write t
        write oBuf
      else if word[2] is '*'
        write 'USER CHIP . . :JD'
        write 'NICK JD[Javascript]'
        write 'JOIN %#The\\bLobby'
    else if word[0] is 'PING'
      write 'PONG ' + word[1]

client.on 'end', ->
  console.log '** Disconnected'

authunescape = (data) ->
  skip = false
  out = ''
  for letter, i in data
    if skip is true
      skip = false
    else if letter is '\\'
      ec = data[i + 1]
      skip = true
      if ec is '0' then out += '\0'
      else if ec is 'b' then out += ' '
      else if ec is 'c' then out += ','
      else if ec is 'n' then out += '\n'
      else if ec is 'r' then out += '\r'
      else if ec is 't' then out += '\t'
      else if ec is '\\' then out += '\\'
      else # Not a valid escape char.
        out += letter
        skip = false
    else
      out += letter
  return out

authescape = (data) ->
  out = ''
  for letter, i in data.toString 'binary'
    if letter is '\0' then out += '\\0'
    else if letter is ' ' then out += '\\b'
    else if letter is ',' then out += '\\c'
    else if letter is '\n' then out += '\\n'
    else if letter is '\r' then out += '\\r'
    else if letter is '\t' then out += '\\t'
    else if letter is '\\' then out += '\\\\'
    else out += letter
  return Buffer.from out, 'binary'
