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

tests = (test:set put [
        (test-simple)
        (test-map-data)
    ])