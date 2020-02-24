# riku
curl wrapper written in elvish with the API of Pythons `requests`

**Note:** Currently additional arguments can't be passed to the convenience methods since this needs support from elvish itself: [Map explosion and rest options #584](https://github.com/elves/elvish/issues/584)

## Table of Contents
- [Examples](#examples)
  - [Simple GET request](#simple-get-request)
  - [GET request with parameters](#get-request-with-parameters)
- [Tests](#tests)
- [API](#api)
  - [riku:request](#rikurequest)
  - [riku:head](#rikuhead)
  - [riku:get](#rikuget)
  - [riku:post](#rikupost)
  - [riku:put](#rikuput)
  - [riku:patch](#rikupatch)
  - [riku:delete](#rikudelete)

## Examples

### Simple GET request
```
~> use github.com/mojurasu/riku/riku
~> riku:get "https://httpbin.org/get"
[
 &content = "{\n  \"args\": {}, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"riku/0.1.0\", \n    \"X-Amzn-Trace-Id\": \"Root=1-5e5460e4-c9e58d87d61479be5c539cd8\"\n  }, \n  \"origin\": \"77.189.17.177\", \n  \"url\": \"https://httpbin.org/get\"\n}"
 &headers = [
   [
    &date = 'Mon, 24 Feb 2020 23:48:52 GMT'
    &access-control-allow-origin = '*'
    &access-control-allow-credentials = true
    &content-length = 254
    &content-type = application/json
    &server = gunicorn/19.9.0
   ]
  ]
 &status_code = 200
 &elapsed = 0.390181
 &cookies = []
 &url = https://httpbin.org/get
 &ok = $true
]
```

### GET request with parameters
```
[
 &content = "{\n  \"args\": {\n    \"arg1\": \"value\"\n  }, \n  \"headers\": {\n    \"Accept\": \"*/*\", \n    \"Host\": \"httpbin.org\", \n    \"User-Agent\": \"riku/0.1.0\", \n    \"X-Amzn-Trace-Id\": \"Root=1-5e5461d3-71defefab809710729819cbe\"\n  }, \n  \"origin\": \"77.189.17.177\", \n  \"url\": \"https://httpbin.org/get?arg1=value\"\n}"
 &headers = [
   &date = 'Mon, 24 Feb 2020 23:52:51 GMT'
   &access-control-allow-origin = '*'
   &access-control-allow-credentials = true
   &content-length = 288
   &content-type = application/json
   &server = gunicorn/19.9.0
  ]
 &status_code = 200
 &elapsed = 0.388110
 &cookies = []
 &url = 'https://httpbin.org/get?arg1=value'
 &ok = $true
]
```

## Tests
riku comes with tests using zzambonis test module. The tests use httpbin.org to test different parameters, headers, etc.

To run them do the following:

```
use github.com/mojurasu/riku/tests riku_tests
riku_tests:run
```

## API

### `riku:request`
Raw method to send a request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| method          |    -    | The HTTP method for the request
| url             |    -    | URL for the request
| params          |   nil   | map to be sent in the query string
| data            |   nil   | string, list or map to be sent as data
| headers         |   nil   | map of headers to be sent with the request
| cookies         |   nil   | map of cookies to be sent with the request
| files           |   nil   | Not implemented. Will raise an exception
| auth            |   nil   | Not implemented. Will raise an exception
| timeout         |   nil   | Seconds to wait for the request in total or a list of [connect_timeout read_timeout]
| allow_redirects |   true  | Follow 3xx redirects
| proxies         |   nil   | Not implemented. Will raise an exception
| verify          |   true  | Pass false to disable TLS verification, pass a CA file or folder to verify the peer against
| cert            |   nil   | Path to client certificate or list of [filepath password]

### `riku:head`
Sends a HEAD request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| allow_redirects |  false  | Follow 3xx redirects
| @args           |    -    | Arguments that should be passed to riku:request

### `riku:get`
Sends a GET request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| params          |   nil   | map to be sent in the query string
| @args           |    -    | Arguments that should be passed to riku:request

### `riku:post`
Sends a POST request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| data            |   nil   | string, list or map to be sent as data
| @args           |    -    | Arguments that should be passed to riku:request

### `riku:put`
Sends a PUT request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| data            |   nil   | string, list or map to be sent as data
| @args           |    -    | Arguments that should be passed to riku:request

### `riku:patch`
Sends a PATCH request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| data            |   nil   | string, list or map to be sent as data
| @args           |    -    | Arguments that should be passed to riku:request

### `riku:delete`
Sends a DELETE request

Parameters:
|       Name      | Default | Description
| --------------- | ------- | -----------
| url             |    -    | URL for the request
| @args           |    -    | Arguments that should be passed to riku:request
