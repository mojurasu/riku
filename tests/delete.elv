use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (echo (riku:delete "https://httpbin.org/delete")[content] | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple DELETE request")
}

# Need a way to have **kwargs functionality first
fn test-params {
    res = (riku:delete "https://httpbin.org/delete" &params=[&key=value] | from-json)
    put (test:check { eq $res[args] [&key=value] } "DELETE request with parameters")
}

fn test-headers {
    res = (riku:delete "https://httpbin.org/delete" &headers=[&Authorization=password] | from-json)
    put (test:check { eq $res[args] [&key=value] } "DELETE request with headers")
}

tests = (test:set delete [
        (test-simple)
    ])