use github.com/zzamboni/elvish-modules/test
use ./tests/head
use ./tests/get
use ./tests/post
use ./tests/put
use ./tests/patch
use ./tests/delete

fn run {
    (test:set riku [
        $head:tests
        $get:tests
        $post:tests
        $put:tests
        $patch:tests
        $delete:tests
    ]
)
}
