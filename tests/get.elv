use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (riku:get "https://httpbin.org/get" | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple GET request")
}

fn test-params {
    res = (riku:get "https://httpbin.org/get" &params=[&key=value] | from-json)
    put (test:check { eq $res[args] [&key=value] } "GET request with parameters")
}

# Need a way to have **kwargs functionality first
fn test-headers {
    res = (riku:get "https://httpbin.org/get" &headers=[&Authorization=password] | from-json)
    put (test:check { eq $res[args] [&key=value] } "GET request with headers")
}

tests = (test:set get [
        (test-simple)
        (test-params)
    ])