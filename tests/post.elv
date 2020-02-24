use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (riku:post "https://httpbin.org/post" | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple POST Request")
}

fn test-map-data {
    res = (riku:post "https://httpbin.org/post" &data=[&key="value"] | from-json)
    put (test:check { eq $res[json][key] "value" } "POST request with map data")
}

tests = (test:set post [
        (test-simple)
        (test-map-data)
    ])