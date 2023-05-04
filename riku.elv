use str
fn version { put '0.2.0' }

fn -parse-bool {|val|
    if (eq (str:to-lower $val) "true") {
        put $true
    } elif (eq (str:to-lower $val) "true") {
        put $false
    } else {
        put $val
    }
}

# See https://curl.haxx.se/docs/http-cookies.html for more detail
fn -parse-cookies {|lines|
    for l $lines {
        if (and (not (has-prefix $l '#')) (not-eq (count $l) 0))  {
            var domain subdomains path secure expires name value = (splits "\t" $l)
            put [
                &domain=$domain
                &subdomains=(-parse-bool $subdomains)
                &path=$path
                &secure=(-parse-bool $secure)
                &expires=$expires
                &name=$name
                &value=$value
            ]
        }

    }

}

fn -parse-headers {|lines|
    var headers = [&]
    for l $lines {
        l = (replaces "\r" '' $l)
        if (and (not (has-prefix $l "HTTP")) (not-eq (count $l) 0)) {
            var key @value = (splits ':' $l)
            value = (str:trim-space (joins ':' $value))
            headers[$key] = $value
        }
    }
    put $headers
}

fn request {|method url
            &params=$nil
            &data=$nil
            &headers=$nil
            &cookies=$nil
            &files=$nil
            &auth=$nil
            &timeout=$nil
            &allow_redirects=$true
            &proxies=$nil
            &verify=$true
            &cert=$nil|
    var session-path = (mktemp -d riku-XXXXXXXXXXXXXXXXXXXX --tmpdir)
    var output-file = $session-path"/"output
    var headers-file = $session-path"/"headers
    var cookies-file = $session-path"/"cookies
    # --disable Disables loading of a .curlrc
    var curl_args = ['--silent' '--show-error' '--disable'
                 '--user-agent' 'riku/'$version
                 '--output' $output-file
                 '--dump-header' $headers-file
                 '--cookie-jar' $cookies-file
                 '-w' '%{http_code}\n%{time_total}\n%{url_effective}\n'
    ]

    if (eq $method "GET") {
        set curl_args = [$@curl_args "-G"]
    } elif (eq $method "HEAD") {
        set curl_args = [$@curl_args "-I"]
    } else {
        set curl_args = [$@curl_args "-X" $method]
    }

    if (not-eq $params $nil) {
        keys $params | each {|k|
            set curl_args = [$@curl_args '-d' $k'='$params[$k]]
        }
    }

    if (not-eq $data $nil) {
        if (eq (kind-of $data) "string") {
            set curl_args = [$@curl_args '-d' $data]
        } elif (eq (kind-of $data) "list") {
            set curl_args = [$@curl_args '-d' $data]
        } elif (eq (kind-of $data) "map") {
            set curl_args = [$@curl_args '-H' 'Content-Type: application/json'
                                     '--data-raw' (put $data | to-json)]
        }

    }

    if (not-eq $headers $nil) {
        keys $headers | each {|k|
            set curl_args = [$@curl_args '-H' $k': '$headers[$k]]
        }
    }

    if (not-eq $cookies $nil) {
        var cookie_string = ""
        keys $cookies | each {|k|
            set cookie_string = $cookie_string$k'='$cookies[$k]";"
        }
        set curl_args = [$@curl_args '--cookie' $cookie_string]
    }

    if (not-eq $files $nil) {
        fail "riku: &files Not implemented"
    }

    if (not-eq $auth $nil) {
        fail "riku: &auth Not implemented"
    }

    if (not-eq $timeout $nil) {
        if (eq (kind-of $timeout) "string") {
            set curl_args = [$@curl_args "--max-time" $timeout]
        } elif (eq (kind-of $timeout) "list") {
            var connect_timeout read_timeout = $@timeout
            set curl_args = [$@curl_args "--connect-timeout" $connect_timeout]
            # add connect and read timeout together since --max-time is
            # the maximum time allowed for the entire command
            set curl_args = [$@curl_args "--max-time" (+ $connect_timeout $read_timeout)]

        }
    }

    if (eq $allow_redirects $true) {
        set curl_args = [$@curl_args "--location"]
    }

    if (not-eq $proxies $nil) {
        fail "riku: &proxies Not implemented"
    }

    if (eq $verify $false) {
        set curl_args = [$@curl_args "--insecure"]
    } elif (eq (kind-of $verify "string")) {
        if ?(test -d $verify) {
            set curl_args = [$@curl_args "--capath" $verify]
        } else {
            set curl_args = [$@curl_args "--cacert" $verify]
        }
    }

    if (not-eq $cert $nil) {
        var cert_arg = ""
        if (eq (kind-of $cert) "string") {
            set cert_arg = $cert
        } elif (eq (kind-of $cert) "list") {
            var certificate password = $@cert
            set cert_arg = $certificate":"$password
        }
        set curl_args = [$@curl_args "--cert" $cert_arg]
    }

    var status_code total_time effective_url = (e:curl $url $@curl_args)
    var status_ok = $false
    if (< $status_code 400) {
        set status_ok = $true
    }

    var f = (fopen $output-file)
    var content = (joins "\n" [(cat < $f)])
    fclose $f

    var f = (fopen $headers-file)
    var headers = (-parse-headers [(cat < $f)])
    fclose $f

    var f = (fopen $cookies-file)
    var cookies = [(-parse-cookies [(cat < $f)])]
    fclose $f

    var response = [
        &content=$content
        &cookies=$cookies
        &elapsed=$total_time
        &headers=$headers
        &ok=$status_ok
        &status_code=$status_code
        &url=$effective_url
    ]
    put $response
    e:rm -r $session-path
}

# All convenience functions have the full siganture until https://b.elv.sh/584 is implemented

fn head {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "HEAD" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}

fn get {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "GET" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}

fn post {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "POST" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}

fn put {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "PUT" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}

fn patch {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "PATCH" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}

fn delete {|url &params=$nil &data=$nil &headers=$nil &cookies=$nil &files=$nil &auth=$nil &timeout=$nil &allow_redirects=$true &proxies=$nil &verify=$true &cert=$nil|
    request "DELETE" $url &params=$params &data=$data &headers=$headers &cookies=$cookies &files=$files &auth=$auth &timeout=$timeout &allow_redirects=$allow_redirects &proxies=$proxies &verify=$verify &cert=$cert
}
