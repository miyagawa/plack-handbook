## Day 12: 複数のアプリケーションをmountとURLMapでマウントする

### Hello World! but anyone else?

本書では、シンプルなアプリケーションの例として "Hello World" を使っていました。

    my $app = sub {
        return [ 200, [], [ "Hello World" ] ];
    };

より複雑な例として、Webアプリケーションフレームワークを使って書かれた複数のアプリケーションを、1つのサーバ内でmod_aliasなどでマップしているような例を考えてみましょう。

### Plack::App::URLMap

Plack::App::URLMap は複数のPSGIアプリケーションを*合成*して1つのPSGIアプリケーションのように振る舞います。リクエストパスやヴァーチャルホストのようにホスト名ベースでアプリケーションをディスパッチすることができます。

    my $app1 = sub {
        return [ 200, [], [ "Hello John" ] ];
    };
    
    my $app2 = sub {
        return [ 200, [], [ "Hello Bob" ] ];
    };

このように2つのアプリがあり、1つはJohnもう1つはBobにHelloを返します。この2つのPSGIアプリを1つのサーバで動作させたい場合、どうすればよいでしょう。Plack::App::URLMapを利用すると以下のように出来ます。

    use Plack::App::URLMap;
    my $app = Plack::App::URLMap->new;
    $app->mount("/john" => $app1);
    $app->mount("/bob"  => $app2);

たったこれだけです。リクエストパスに応じて、`/john`には`$app1`つまり"Hello John", `/bob`には`$app2`つまり"Hello Bob"へディスパッチします。またマップされいていないパス、たとえばルートの "/" などは404が返ります。

`PATH_INFO`や`SCRIPT_NAME`といったPSGI環境変数は自動的に調整され、Apacheのmod_aliasやCGIスクリプトを起動したときのように、そのまま動きます。アプリケーションやフレームワークは、`PATH_INFO`を使ってリクエストを処理し、`SCRIPT_NAME`をベースパスとしてURLを生成する必要があります。

### mount DSL

Plack::App::URLMapの`mount`はとても便利なので、Plack::BuilderのDSLにも追加してあります。Rack::Builderでは`map`を使っていますが、これもPerlでは使えないので、`mount`として使います。

    use Plack::Builder;
    builder {
        mount "/john" => $app1;
        mount "/bob"  => builder {
            enable "Auth::Basic", authenticator => ...;
            $app2;
        };
    };

'/john' へのリクエストはURLMapのときと同様、`$app1`にディスパッチされます。この例では"/bob"に対して`builder`をネストさせ、"Hello Bob"を表示するアプリケーションにBasic認証を追加しています。この例は以下のコードと同様です。

    $app = Plack::App::URLMap->new;
    $app->mount("/john", $app1);
    
    $app2 = Plack::Middleware::Auth::Basic->wrap($app2, authenticator => ...);
    $app->mount("/bob",  $app2);

が、DSLを利用した方がより短いコードで、簡潔になっています。

### マルチテナントフレームワーク

もちろん、このURLMapやmount APIをつかって複数のフレームワークのアプリケーションを1つのサーバにマウントすることができます。3つのアプリケーションがあって、"Foo"がCatalyst, "Bar"がCGI::Application, "Baz"がSquattingで書かれているとしましょう。

    # Catalyst
    use Foo;
    my $app1 = Foo->psgi_app;
    
    # CGI::Application
    use Bar;
    use CGI::Application::PSGI;
    my $app2 = sub { 
        my $app = Bar->new({ QUERY => CGI::PSGI->new(shift) });
        CGI::Application::PSGI->run($app);
    };
    
    # Squatting
    use Baz 'On::PSGI';
    Baz->init;
    my $app3 = sub { Baz->psgi(shift) };
    
    builder {
        mount "/foo" => $app1;
        mount "/bar" => $app2;
        mount "/baz" => $app3;
    };

こうすると、別々のフレームワークで書かれた3つのアプリケーションが、plackupなどを利用して同一サーバ上で異なるパスにマップされて起動します。
