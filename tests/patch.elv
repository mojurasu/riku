use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    var res = (echo (riku:patch "https://httpbin.org/patch")[content] | from-json)
    var user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple PATCH Request")
}

fn test-map-data {
    var res = (echo (riku:patch "https://httpbin.org/patch" &data=[&key="value"])[content] | from-json)
    put (test:check { eq $res[json][key] "value" } "PATCH request with map data")
}

fn test-200 {
    var res = (riku:get "https://httpbin.org/status/200" &params=[&key=value])
    put (test:check { eq $res[status_code] 200 } "HTTP 200 &status_code")
    put (test:check { eq $res[ok] $true } "HTTP 200 &ok")
}

fn test-300 {
    var res = (riku:get "https://httpbin.org/status/300" &params=[&key=value])
    put (test:check { eq $res[status_code] 300 } "HTTP 300 &status_code")
    put (test:check { eq $res[ok] $true } "HTTP 300 &ok")
}

fn test-400 {
    var res = (riku:get "https://httpbin.org/status/400" &params=[&key=value])
    put (test:check { eq $res[status_code] 400 } "HTTP 400 &status_code")
    put (test:check { eq $res[ok] $false } "HTTP 400 &ok")
}

fn test-500 {
    var res = (riku:get "https://httpbin.org/status/500" &params=[&key=value])
    put (test:check { eq $res[status_code] 500 } "HTTP 500 &status_code")
    put (test:check { eq $res[ok] $false } "HTTP 500 &ok")
}

var tests = (test:set patch [
        (test-simple)
        (test-map-data)
        (test-200)
        (test-300)
        (test-400)
        (test-500)
    ])