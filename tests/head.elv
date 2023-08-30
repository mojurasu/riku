use github.com/zzamboni/elvish-modules/test
use ../riku


fn test-simple {
    var res = [(riku:head "https://httpbin.org/get")]
    print $res[0]
    # put (test:check { eq $user_agent "riku/"$riku:version } "Simple HEAD Request")
}

# Empty until parsing the return value of the HEAD request is implemented

var tests = (test:set head [
    ])