use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (echo (riku:get "https://httpbin.org/get")[content] | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple GET request")
}

fn test-params {
    res = (echo (riku:get "https://httpbin.org/get" &params=[&key=value])[content] | from-json)
    put (test:check { eq $res[args] [&key=value] } "GET request with parameters")
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

fn test-cookie {
    res = (riku:get "https://httpbin.org/cookies/set/keks/lecker")
    cookie = $res[cookies][0]
    put (test:check { eq $cookie[name] "keks" } "Cookie Name")
    put (test:check { eq $cookie[value] "lecker" } "Cookie Value")
}

# Need a way to have **kwargs functionality first
fn test-headers {
    res = (riku:get "https://httpbin.org/get" &headers=[&Authorization=password] | from-json)
    put (test:check { eq $res[args] [&key=value] } "GET request with headers")
}

tests = (test:set get [
        (test-simple)
        (test-params)
        (test-200)
        (test-300)
        (test-400)
        (test-500)
        (test-cookie)
    ])