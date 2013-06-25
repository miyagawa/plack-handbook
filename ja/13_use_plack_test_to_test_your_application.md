## Day 13: Plack::Test でアプリケーションをテストする

### Testing

Webアプリケーションのテストにはいろいろな方法があり、ライブのサーバを使ったり、モックリクエストを使う方法などがあります。こうしたテスト手法を提供しているフレームワークもありますが、どのようにテストを記述するかはフレームワークごとに異なっていることが多いです。

Plack::TestはどんなPSGI対応のWebアプリケーションフレームワークでも、共通のインターフェースを使って、それぞれモックとライブのサーバを使ったテスト手法を導入できます。

### Plack::Testを利用

Plack::Testの利用はとても簡単で、Perlのテストプロトコル標準である[TAP](http://testanything.org/wiki/) や[Test::More](http://search.cpan.org/perldoc?Test::More)と互換性があります。

    use Plack::Test;
    use Test::More;
    use HTTP::Request;
    
    my $app = sub {
        return [ 200, [ 'Content-Type', 'text/plain' ], [ "Hello" ] ];
    };
    
    test_psgi $app, sub {
        my $cb = shift;
        
        my $req = HTTP::Request->new(GET => 'http://localhost/');
        my $res = $cb->($req);
        
        is $res->code, 200;
        is $res->content, "Hello";
    };
    
    done_testing;

PSGIアプリを作成またはロード([Plack::Util](http://search.cpan.org/perldoc?Plack::Util)の `load_psgi` 関数をつかって`.psgi`ファイルからアプリケーションをロードできます)し、`test_psgi`関数でアプリケーションをテストします。2個目の引数はコールバックで、テスト用クライアントコードを記述します。

名前付き引数をつかって、以下のようにも書けます:

    test_psgi app => $app, client => sub { ... }

クライアントコードはコールバック `$cb` を受け取り、これに対して HTTP::Request オブジェクトを渡すと HTTP::Response オブジェクトを返します。1つのクライアントコード内で複数のリクエストを投げて、リクエストやレスポンスのテストを記述できます。

このファイルを`.t`で保存し、`prove`などでテストを実行します。

### HTTP::Request::Common

これは必須ではありませんが、[HTTP::Request::Common](http://search.cpan.org/perldoc?HTTP::Request::Common) を利用してHTTPリクエストを作成することをおすすめします。コードがより簡潔になります。

    use HTTP::Request::Common;
    
    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        # ...
    };

スキームやホスト名は省略可能で、http://localhost/ (ライブ・テストの場合ポート番号は自動補完されます) になります。

### ライブ/モックモード

デフォルトでは`test_psgi`のコールバックはモックHTTPリクエストモードで実行され、受け取ったHTTP::RequestオブジェクトをPSGI環境変数ハッシュに変換し、PSGIアプリケーションを実行し、レスポンスをHTTP::Responseに変換します。

これをライブHTTPモードに変更して実行するには、a) パッケージ変数`$Plack::Test::Impl` または b) 環境変数 `PLACK_TEST_IMPL` を `Server` に設定します。

    use Plack::Test;
    $Plack::Test::Impl = "Server";
    
    test_psgi ... # the same code

環境変数を使えば、`.t`コードを変更する必要がありません。

    env PLACK_TEST_IMPL=Server prove -l t/test.t

Serverモードでは、PSGIアプリケーションをスタンドアロンサーバで記述し、LWP::UserAgent を利用してHTTPリクエストを送信します。テスト内のクライアントコードを変更する必要はありませんし、ホスト名やポート番号はテスト環境によって自動で設定されます。

### フレームワークをPlack::Testでテスト

繰り返しになりますが、PSGIとPlackの素晴らしいところは、PSGIをターゲットにして書かれたアプリケーションフレームワークであればなんでも利用が可能であるということです。Plack::Testも同様に、PSGIに対応したWebアプリケーションフレームワークをテストすることができます。

    use Plack::Test;
    use MyCatalystApp;
    
    my $app = MyCatalystApp->psgi_app;
    
    test_psgi $app, sub {
        my $cb = shift;
        # ...
    };
    done_testing;

