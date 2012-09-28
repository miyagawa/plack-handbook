## Day 18: ミドルウェアを条件ロードする

いくつかのミドルウェアを紹介しました。便利なので全体に有効にできるものもあれば、ある条件下でのみ有効にしたいものもあるでしょう。どうやってそれを実現するかを解説します。

### ミドルウェアを条件分岐でロードする

Conditional ミドルウェアはメタミドルウェアで、1つのミドルウェアを受け取り、それをランタイムの条件によって適用させるか決定するミドルウェアを返します。例をとってみましょう。

* JSONP ミドルウェアをパスが /public で始まるときだけ有効にしたい
* Basic認証をローカルIPからのリクエストについては無効にしたい

WSGIやRackでこうした問題をどのように対処するかを調査していましたが、きれいな方法は見つかりませんでした。各ミドルウェアで有効にする条件を設定するのは、あまりいい方法だとは思えませんでした。

### Middleware::Conditional

Conditional ミドルウェアはこうした問題を柔軟に解決します。

    use Plack::Builder;
    
    builder {
        enable_if { $_[0]->{REMOTE_ADDR} !~ /^192\.168\.0\./ }
            "Auth::Basic", authenticator => ...;
        $app;
    };

Plack::Builder に新しいキーワード `enable_if` が追加されています。ブロックを受け取り、リクエスト時に評価され(`$_[0]`がPSGI環境変数ハッシュ) ブロックがtrueを返した場合、ミドルウェアでラップされたアプリケーションを、そうでない場合はなにもせずにパススルーします。

この例ではリクエストがローカルネットワークから来ているかチェックし、そうでない場合にBasic認証ミドルウェアを適用しています。

Conditional は普通のミドルウェアとして実装ｓれているので、内部的には以下のコードと同等です:
    
    use Plack::Middleware::Conditional;
    use Plack::Middleware::Auth::Basic;
    
    my $app = sub { ... };
    
    $app = Plack::Middleware::Conditional->wrap($app,
        builder => sub {
            Plack::Middleware::Auth::Basic->wrap(
                $_[0], authenticator => ...,
            );
        },
        condition => sub {
            my $env = shift;
            $env->{REMOTE_ADDR} !~ /^192\.168\.0\./;
        },
    );

ですがこれを毎回書くのは退屈ですので、DSL版をおすすめします :)
