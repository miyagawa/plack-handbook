## Day 23: ミドルウェアを書く

ミドルウェアの紹介の最後として、自分で書いてみることにしましょう。

### ミドルウェアを書く

PSGIミドルウェアは、通常のPSGIアプリケーションと同様に動作しますが、実際のPSGIアプリケーションをラップするため、サーバからみるとアプリケーションのように見え、ラップされたアプリケーションからはサーバのように振る舞います。

User-Agentを偽装するためのシンプルなミドルウェアは以下のようになります。

    # Wrapped application
    my $app = sub {
        my $env = shift;
        my $who = $env->{HTTP_USER_AGENT} =~ /Mobile Safari/ ? 'iPhone' : 'non-iPhone';
        return [ 200, ['Content-Type','text/html'], ["Hello $who"] ];
    };
    
    # Middleware to wrap $app
    my $mw = sub {
        my $env = shift;
        $env->{HTTP_USER_AGENT} .= " (Mobile Safari)";
        $app->($env);
    };

アプリケーションはリクエストがiPhoneブラウザ (*Mobile Safari*) からきた場合のみ、"Hello iPhone" を表示します。このミドルウェアは Mobile Safari 文字列をすべてのリクエストに追加します。このアプリケーションを実行して、任意のブラウザで表示すると、"Hello iPhone" が表示され、アクセスログには以下のように表示されるでしょう。

    127.0.0.1 - - [23/Dec/2009 12:34:31] "GET / HTTP/1.1" 200 12 "-" "Mozilla/5.0 
    (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like
    Gecko) Version/4.0.4 Safari/531.21.10 (Mobile Safari)"

" (Mobile Safari)" がUser-Agent文字列に追加されています。

### 再利用可能なMiddlewareにする

`.psgi`にインラインで記述する方法は、一度きりの利用をするには大変便利ですが、多くの場合、一般化して他のアプリケーションでも再利用できるようにしたいでしょう。Plack::Middlewareを利用すると、これが可能になります。

    package Plack::Middleware::FakeUserAgent;
    use strict;
    use parent qw(Plack::Middleware);
    use Plack::Util::Accessor qw(agent);
    
    sub call {
        my($self, $env) = @_;
        $env->{HTTP_USER_AGENT} = $self->agent;
        $self->app->($env);
    };
    
    1;

たったこれだけです。Plack::Middlewareを継承し、必要とするオプションをAccessorで定義し、`call`メソッドを実装して`$self->app`に処理をデリゲートします。このミドルウェアはPlack::BuilderのDSL(Day 11)と互換性があるので、

    use Plack::Builder;
    
    builder {
        enable "FakeUserAgent", agent => "Mozilla/3.0 (MSIE 4.0)";
        $app;
    };

としてすべてのリクエストをInternet Explorer 4から来たように偽装することができます。また、条件によって有効にするには`enable_if` (Day 18)を使うことができます。

### リクエストの後処理

上で紹介した例はリクエストの`$env`に対して前処理を行いました。レスポンスに対しての場合はどうでしょう。ほとんど同じで、

    my $app = sub { ... };
    
    # Middleware to fake status code to 500
    my $mw = sub {
        my $env = shift;
        my $res = $app->($env);
        $res->[0] = 500 unless $res->[2] == 200;
        $res;
    };

これはとても実用的でないミドルウェアで、すべての200以外のステータスコードを500に変更します。使う場面は想像できませんが、例としては十分でしょう。

多くのサーバがPSGIの[streaming interface](http://bulknews.typepad.com/blog/2009/10/psgiplack-streaming-is-now-complete.html)を実装して、レスポンスのストリームを可能にしていますが、このミドルウェアはそのインタフェースには対応していません。このインタフェースに対応するコードを各ミドルウェアで書くのは効率的でないので、Plack::Middlewareではそのユーティリティを用意しています。

    package Plack::Middleware::BadStatusCode;
    use strict;
    use parent qw(Plack::Middleware);
    
    sub call {
        my($self, $env) = @_;
        my $res = $self->app->($env);
        $self->response_cb($res, sub {
            my $res = shift;
            $res->[0] = 500 unless $res->[0] == 200;
        });
    }
    
    1;

レスポンス `$res` を`response_cb` に渡し、レスポンスをラップするコールバックを渡します。このユーティリティが、ストリーミングインタフェースへの対応を面倒みてくれます。

### 名前空間

この例では Plack::Middleware 名前空間にモジュールを定義しましたが、必ずしもこの名前空間を使う必要はありません。多くのPSGIアプリケーションで利用できる一般的なものであれば、この名前空間で問題ありませんが、特殊な用途に利用するものや、特定のフレームワークのみで動作するものなどは、その他の名前空間を利用し、

    package MyFramework::Middleware::Foo;
    use parent qw(Plack::Middleware);

+（プラス)記号をつかって名前空間を指定します。

    enable '+MyFramework::Middleware::Foo', ...;

DSLでないAPIを使う場合には、

    $app = MyFramework::Middleware::Foo->wrap($app, ...);

とすれば問題なく動作します。
