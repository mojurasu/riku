use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    var res = (echo (riku:delete "https://httpbin.org/delete")[content] | from-json)
    var user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple DELETE request")
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

# Need a way to have **kwargs functionality first
fn test-params {
    var res = (riku:delete "https://httpbin.org/delete" &params=[&key=value] | from-json)
    put (test:check { eq $res[args] [&key=value] } "DELETE request with parameters")
}

fn test-headers {
    var res = (riku:delete "https://httpbin.org/delete" &headers=[&Authorization=password] | from-json)
    put (test:check { eq $res[args] [&key=value] } "DELETE request with headers")
}

var tests = (test:set delete [
        (test-simple)
        (test-200)
        (test-300)
        (test-400)
        (test-500)
    ])