## Day 22: さらにミドルウェアの紹介

この連載も終了に近づいて来ましたが、すべてのミドルウェアを紹介するには紙面が足りないようです。今日はまだ紹介していないいくつかの素晴らしいミドルウェアを簡単に紹介しましょう。

### ErrorDocument

アプリケーションが500エラーを出した際や、認証が失敗した際のForbiddenページを出力する際、レスポンスコードに応じて、カスタムのエラーページを表示したいことがあります。ErrorDocumentは、Apacheの同名ディレクティブと同様、この処理を実装しています。

    builder {
        enable "ErrorDocument", 500 => "/path/to/error.html";
        $app;
    };

任意のエラーコードをスタティックファイルのパスにマップします。開発時にはStackTraceミドルウェア、プロダクションではErrorDocumentできれいなエラーページを表示するとよいでしょう。

このミドルウェアはPlackディストリビューションに付属しています。

### Session

Rackでは`rack.session`をRackの環境変数で標準定義しており、Hashオブジェクトのインタフェースを提供しています。PSGIではこれを標準には取り入れていませんが、アイデアと実装についてはかなりインスパイアされています。

     builder {
         enable "Session", store => "File";
         $qpp;
     };

デフォルトではセッションデータはオンメモリのハッシュに保存されますので、preforkやマルチプロセス型のサーバではうまく動作しません。CHIなどのエンジンが付属していて、またその他のストレージエンジンに対するインタフェースを記述することで、Authミドルウェアなどと同様、拡張を簡単に行うことができます。

セッションデータは`psgix.session`というPSGI環境変数にハッシュリファレンスとして格納されています。アプリケーションやフレームワークはこのハッシュに直接アクセスしてもよいですし、Plack::Sessionモジュールを使ってラッパーを定義することも可能です。例えば、Tatsumakiフレームワークでは以下のように利用できます。

     # Tatsumaki app
     sub get {
         my $self = shift;
         my $uid = $self->request->session->get('uid');
         $self->request->session->set(last_access => time);
         ...
     }

Sessionミドルウェアの利点として、PSGIアプリケーション間でのセッション共有が可能になるということです。フレームワークのアダプターによっては、ユーザアプリケーションからPSGI環境変数へのアクセスが許可されていない場合がありますが、こうした問題は徐々に解消されていくはずです。

SessionミドルウェアはStevan Littleによって開発され、[github](http://github.com/stevan/plack-middleware-session) とCPANから入手できます。

### Debug

こちらも[Rack-bug](http://github.com/brynary/rack-bug)と[django debug toolbar](http://github.com/robhudson/django-debug-toolbar)からのインスパイアで、このミドルウェアを有効にすると、デバッグ用の「パネル」が表示され、リクエストに関するデータやアナリティクスが表示されます。

標準のパネルにはTimer(リクエスト時間)、Memory(メモリー使用量)、Request(リクエストヘッダ情報)、Response(レスポンスヘッダ)などが含まれています。

     builder {
         enable "Debug";
         $app;
     };

利用はたったこれだけで、利用するパネルを制限したり、標準以外のものを追加するには、`panels`パラメータを指定します。

DBIのクエリプロファイラや、Catalystのログなどの拡張パネルはCPANとgithubから入手可能です。

### Proxy

HTTPリクエストをインターネットまたはローカルネットワークで動いている別のアプリケーションにプロキシしたいことがあります。たとえば、JSONPをサポートしていないJSON APIをプロキシしたい場合など、Cross Origin Policy上アクセスできないため、プロキシを立てる必要があります。また、ローカルで動く別のアプリケーションに対してフロントエンド的に動作させるリバースプロキシ的な利用法もあるでしょう。

Plack::App::Proxyはこれらを可能にします。

    use Plack::App::Proxy;
    use Plack::Builder;
    
    my $app = Plack::App::Proxy->new(host => '192.168.0.2:8080')->to_app;
    
    builder {
        mount "/app" => $app;
    };

Plack::App::ProxyはLee Aylwardによって[github](http://github.com/leedo/Plack-App-Proxy)で開発されています。

### さらに

さらに多くのミドルウェアがPlackディストリビューションに付属し、またCPANから検索することができます。すべてのミドルウェアがすぐに使えるというわけではないかもしれませんが、PSGIをサポートするフレームワークで共有できるというすばらしいメリットがあります。
