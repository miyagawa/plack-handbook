## Day 16: アプリケーションにJSONPサポートを追加する

今日はとてもシンプルですが便利な例として、HTTPのベーシック機能だけではないミドルウェアを紹介します。

### JSONP

[JSONP](http://ajaxian.com/archives/jsonp-json-with-padding) (JSON-Padding) はJSONをJavaScriptのコールバック関数にラップするテクノロジーの名前です。JSONベースのコンテンツをサードパーティサイトから`script`タグでクロスドメイン読み込みさせるために利用されています。

### Middleware::JSONP

JSONでエンコードされたデータを`application/json`コンテンツ・タイプで返すアプリケーションがあったとします。簡単なインラインPSGIアプリケーションでは以下のようになります。

    use JSON;
    my $app = sub {
        my $env = shift;
        if ($env->{PATH_INFO} eq '/whatever.json') {
            my $body = JSON::encode_json({
                hello => 'world',
            });
            return [ 200, ['Content-Type', 'application/json'], [ $body ] ];
        }
        return [ 404, ['Content-Type', 'text/html'], ['Not Found']];
    };

これにJSONPサポートを追加するには、Middleware::JSONPを利用します:

    use Plack::Builder;
    builder {
        enable "JSONP";
        $app;
    };

たった1行だけです！このミドルウェアは、レスポンスのcontent-typeが`application/json`であるかチェックし、かつ`callback`パラメータがURLにあるかどうかチェックします。"/whatever.json"といったリクエストはそのままJSONとして返されますが、"/whatever.json?callback=myCallback"のようなリクエストには、

    myCallback({"hello":"world"});

というデータが Content-Type `text/javascript` で返され、 Content-Length は自動で調整されます（すでに設定されていた場合）。

### フレームワーク

JSONに加えてJSONPをサポートするのは、多くのフレームワークでは簡単なことですが、Middleware::JSONP はPSGI/Plackのレイヤで共通動作させるものを簡単につくれるよい例でしょう。

もちろん、JSONPミドルウェアはJSONを出力するフレームワークであればどんなものでも適用することができます。Catalystであれば、

    package MyApp::View::JSON;
    use base qw( Catalyst::View::JSON );

    package MyApp::Controller::Foo;
    sub hello : Local {
        my($self, $c) = @_;
        $c->stash->{message} = 'Hello World!';
        $c->forward('MyApp::View::JSON');
    }

これに、Plack::BuilderでJSONPサポートを追加します。

    use MyApp;
    my $app = MyApp->psgi_app;
    
    use Plack::Builder;
    builder {
        enable "JSONP";
        $app;
    };

JSONを出力する[Catalyst::View::JSON](http://search.cpan.org/perldoc?Catalyst::View::JSON) は私が書いたもので、JSONPコールバックはネイティブでサポートされていますが、やり方は1つではありません！
