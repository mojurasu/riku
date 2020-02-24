use github.com/zzamboni/elvish-modules/test
use ../riku

fn test-simple {
    res = (riku:patch "https://httpbin.org/patch" | from-json)
    user_agent = $res[headers][User-Agent]
    put (test:check { eq $user_agent "riku/"$riku:version } "Simple PATCH Request")
}

fn test-map-data {
    res = (riku:patch "https://httpbin.org/patch" &data=[&key="value"] | from-json)
    put (test:check { eq $res[json][key] "value" } "PATCH request with map data")
}

tests = (test:set patch [
        (test-simple)
        (test-map-data)
    ])