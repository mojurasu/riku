use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (echo (riku:put "https://httpbin.org/put")[content] | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple PUT Request")
}

fn test-map-data {
    res = (echo (riku:put "https://httpbin.org/put" &data=[&key="value"])[content] | from-json)
    put (test:check { eq $res[json][key] "value" } "PUT request with map data")
}

fn test-200 {
    res = (riku:get "https://httpbin.org/status/200" &params=[&key=value])
    put (test:check { eq $res[status_code] 200 } "HTTP 200 &status_code")
    put (test:check { eq $res[ok] $true } "HTTP 200 &ok")
}

fn test-300 {
    res = (riku:get "https://httpbin.org/status/300" &params=[&key=value])
    put (test:check { eq $res[status_code] 300 } "HTTP 300 &status_code")
    put (test:check { eq $res[ok] $true } "HTTP 300 &ok")
}

fn test-400 {
    res = (riku:get "https://httpbin.org/status/400" &params=[&key=value])
    put (test:check { eq $res[status_code] 400 } "HTTP 400 &status_code")
    put (test:check { eq $res[ok] $false } "HTTP 400 &ok")
}

fn test-500 {
    res = (riku:get "https://httpbin.org/status/500" &params=[&key=value])
    put (test:check { eq $res[status_code] 500 } "HTTP 500 &status_code")
    put (test:check { eq $res[ok] $false } "HTTP 500 &ok")
}

tests = (test:set put [
        (test-simple)
        (test-map-data)
        (test-200)
        (test-300)
        (test-400)
        (test-500)
    ])