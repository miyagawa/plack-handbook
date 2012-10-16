## Day 10: Plackミドルウェアの利用

### ミドルウェア

ミドルウェアはPSGIにおけるコンセプト(いつものように、PythonのWSGIやRubyのRackからのパクリです)で、サーバとアプリケーション両側の動作をするコンポーネントです。

![WSGI middleware onion](images/pylons_as_onion.png)

(画像は Pylons project)

この画像はミドルウェアのコンセプトをうまく解説しています。玉ねぎの真ん中にPSGIアプリケーションがあり、それをミドルウェアがラップし、リクエストが来るごとに(外側から内側に)前処理をおこない、レスポンスが出力されたら(内側から外側に)後処理を行います。

HTTP認証、エラーの補足、JSONPなど数多くの機能をミドルウェアとして実装することによって、PSGIアプリケーションやフレームワークに動的に機能追加していくことが可能になります。

### Plack::Middleware

[Plack::Middleware](http://search.cpan.org/perldoc?Plack::Middleware) はミドルウェアを記述するためのベースクラスで、シンプルにかつ再利用可能な形でミドルウェアを書くことができます。

Plack::Middlewareで書かれたミドルウェアの利用は簡単で、元のアプリケーションを`wrap`メソッドでラップするだけです。

    my $app = sub { [ 200, ... ] };
    
    use Plack::Middleware::StackTrace;
    $app = Plack::Middleware::StackTrace->wrap($app);

この例は元のアプリケーションをStackTraceミドルウェア(実際にはplackupのデフォルトで有効)の`wrap`メソッドでラップします。ラップされたアプリケーションが例外を投げた場合、ミドルウェアがエラーを捕捉して、Devel::StackTrace::AsHTMLを利用して美しいHTMLページを表示します。

ミドルウェアの中にはパラメータをとるものもあります。その場合、`$app`の後ろにハッシュでパラメータを渡すことができます。:

    my $app = sub { ... };
    
    use Plack::Middleware::MethodOverride;
    $app = Plack::Middleware::MethodOverride->wrap($app, header => 'X-Method');

多くのミドルウェアをラップするのは、とくにそのミドルウェアを実装したモジュールを先にuseする必要もあるため、退屈になりがちです。この対策として、DSL風の記述法が用意されています。

    use Plack::Builder;
    my $app = sub { ... };

    builder {
        enable "StackTrace";
        enable "MethodOverride", header => 'X-Method';
        enable "Deflater";
        $app;
    };

Plack::Builderの利用方法については明日解説します。

### Middleware and Frameworks

ミドルウェアの美しい点は、どんなPSGIアプリケーションにも適用できるところです。このコード例からは当たり前かもしれませんが、実際にはラップされたアプリケーションはどんなものでも構いません。既存のWebアプリケーションをPSGIモードで起動し、それにPlackミドルウェアを追加することだってできます。例えば、CGI::Applicationで、

    use CGI::Application::PSGI;
    use WebApp;
    
    my $app = sub {
        my $env = shift;
        my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
        CGI::Application::PSGI->run($app);
    };
    
    use Plack::Builder;
    builder {
        enable "Auth::Basic", authenticator => sub { $_[1] eq 'foobar' };
        $app;
    };

このようにすると、CGI::ApplicationベースのアプリケーションにBasic認証をつけることができます。[PSGIをサポートしているフレームワーク](http://plackperl.org/#frameworks)であればなんでもこのようなことが可能です。
