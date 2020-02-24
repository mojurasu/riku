use str
version = '0.1.0'

fn -parse-bool [val]{
    if (eq $val "TRUE") {
        put $true
    } elif (eq $val "FALSE") {
        put $false
    } else {
        put $nil
    }
}

# See https://curl.haxx.se/docs/http-cookies.html for more detail
fn -parse-cookies [lines]{
    for l $lines {
        if (and (not (has-prefix $l '#')) (not-eq (count $l) 0))  {
            domain subdomains path secure expires name value = (splits "\t" $l)
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

fn -parse-headers [lines]{
    headers = [&]
    for l $lines {
        l = (replaces "\r" '' $l)
        if (and (not (has-prefix $l "HTTP")) (not-eq (count $l) 0)) {
            key @value = (splits ':' $l)
            value = (str:trim-space (joins ':' $value))
            headers[$key] = $value
        }
    }
    put $headers
}

fn request [method url
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
            &cert=$nil]{
    session-path = (mktemp -d riku-XXXXXXXXXXXXXXXXXXXX --tmpdir)
    output-file = $session-path"/"output
    headers-file = $session-path"/"headers
    cookies-file = $session-path"/"cookies
    # --disable Disables loading of a .curlrc
    curl_args = ['--silent' '--show-error' '--disable'
                 '--user-agent' 'riku/'$version
                 '--output' $output-file
                 '--dump-header' $headers-file
                 '--cookie-jar' $cookies-file
                 '-w' '%{http_code}\n%{time_total}\n%{url_effective}\n'
    ]

    if (eq $method "GET") {
        curl_args = [$@curl_args "-G"]
    } elif (eq $method "HEAD") {
        curl_args = [$@curl_args "-I"]
    } else {
        curl_args = [$@curl_args "-X" $method]
    }

    if (not-eq $params $nil) {
        keys $params | each [k]{
            curl_args = [$@curl_args '-d' $k'='$params[$k]]
        }
    }

    if (not-eq $data $nil) {
        if (eq (kind-of $data) "string") {
            curl_args = [$@curl_args '-d' $data]
        } elif (eq (kind-of $data) "list") {
            curl_args = [$@curl_args '-d' $data]
        } elif (eq (kind-of $data) "map") {
            curl_args = [$@curl_args '-H' 'Content-Type: application/json'
                                     '--data-raw' (put $data | to-json)]
        }

    }

    if (not-eq $headers $nil) {
        keys $headers | each [k]{
            curl_args = [$@curl_args '-H' $k': '$headers[$k]]
        }
    }

    if (not-eq $cookies $nil) {
        cookie_string = ""
        keys $cookies | each [k]{
            cookie_string = $cookie_string$k'='$cookies[$k]";"
        }
        curl_args = [$@curl_args '--cookie' $cookie_string]
    }

    if (not-eq $files $nil) {
        fail "riku: &files Not implemented"
    }

    if (not-eq $auth $nil) {
        fail "riku: &auth Not implemented"
    }

    if (not-eq $timeout $nil) {
        if (eq (kind-of $timeout) "string") {
            curl_args = [$@curl_args "--max-time" $timeout]
        } elif (eq (kind-of $timeout) "list") {
            connect_timeout read_timeout = $@timeout
            curl_args = [$@curl_args "--connect-timeout" $connect_timeout]
            # add connect and read timeout together since --max-time is
            # the maximum time allowed for the entire command
            curl_args = [$@curl_args "--max-time" (+ $connect_timeout $read_timeout)]

        }
    }

    if (eq $allow_redirects $true) {
        curl_args = [$@curl_args "--location"]
    }

    if (not-eq $proxies $nil) {
        fail "riku: &proxies Not implemented"
    }

    if (eq $verify $false) {
        curl_args = [$@curl_args "--insecure"]
    } elif (eq (kind-of $verify "string")) {
        if ?(test -d $verify) {
            curl_args = [$@curl_args "--capath" $verify]
        } else {
            curl_args = [$@curl_args "--cacert" $verify]
        }
    }

    if (not-eq $cert $nil) {
        cert_arg = ""
        if (eq (kind-of $cert) "string") {
            cert_arg = $cert
        } elif (eq (kind-of $cert) "list") {
            certificate password = $@cert
            cert_arg = $certificate":"$password
        }
        curl_args = [$@curl_args "--cert" $cert_arg]
    }

    status_code total_time effective_url = (e:curl $url $@curl_args)
    status_ok = $false
    if (< $status_code 400) {
        status_ok = $true
    }

    f = (fopen $output-file)
    content = (joins "\n" [(cat < $f)])
    fclose $f

    f = (fopen $headers-file)
    headers = (-parse-headers [(cat < $f)])
    fclose $f

    f = (fopen $cookies-file)
    cookies = [(-parse-cookies [(cat < $f)])]
    fclose $f

    response = [
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

fn head [url &allow_redirects=$false @args]{
    request "HEAD" $url &allow_redirects=$allow_redirects $@args
}

fn get [url &params=$nil @args]{
    request "GET" $url &params=$params $@args
}

fn post [url &data=$nil @args]{
    request "POST" $url &data=$data $@args
}

fn put [url &data=$nil @args]{
    request "PUT" $url &data=$data $@args
}

fn patch [url &data=$nil @args]{
    request "PATCH" $url &data=$data $@args
}

fn delete [url @args]{
    request "DELETE" $url $@args
}