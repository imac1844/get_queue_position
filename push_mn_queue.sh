#!/bin/bash
curl -s \
  --form-string "token=aj6kmtua94n5c4ss6vp6iwkyj6qhfp" \
  --form-string "user=u69uin39geyd7w4244sfbws6abd1wn" \
  --form-string "message=hello world <b>word</b>" \
  --form-string "timestamp=1331249662" \
  --form-string "title=Direct message from @someuser" \
  --form-string "sound=magic" \
https://api.pushover.net/1/messages.json
# import http.client, urllib
# conn = http.client.HTTPSConnection("api.pushover.net:443")
# conn.request("POST", "/1/messages.json",
#   urllib.parse.urlencode({
#     "token": "u69uin39geyd7w4244sfbws6abd1wn",
#     "user": "aj6kmtua94n5c4ss6vp6iwkyj6qhfp",
#     "message": "hello world",
#   }), { "Content-type": "application/x-www-form-urlencoded" })
# conn.getresponse()
#Client = Client("u69uin39geyd7w4244sfbws6abd1wn", api_token="aj6kmtua94n5c4ss6vp6iwkyj6qhfp")
