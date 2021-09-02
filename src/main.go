package main

import (
  "fmt"
  "strings"
  "net/http"
  . "github.com/MakeNowJust/heredoc/dot"
)

var WEB_SERVER_BIND_ADDRESS string = "0.0.0.0"
var WEB_SERVER_PORT int = 8000
var TEMPLATE string = D(`
<!DOCTYPE html>
<html><head>
<meta charset=\"utf-8\">
<title>WebHello</title>
</head><body>Hello, \"%s\".</body></html>
`)

func hello(w http.ResponseWriter, req *http.Request) {
  addr := strings.Split(req.RemoteAddr, ":")[0]
  fmt.Fprintf(w, TEMPLATE, addr)
}

func main() {
  for {
    http.HandleFunc("/", hello)
    http.ListenAndServe(fmt.Sprintf("%s:%d", WEB_SERVER_BIND_ADDRESS, WEB_SERVER_PORT), nil)
  }
}

