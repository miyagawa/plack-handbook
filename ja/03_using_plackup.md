## Day 3: plackupを使う

Day 2の記事ではplackupコマンドを利用してHello World PSGIアプリケーションを起動しました。

plackup はPSGIアプリケーションを起動するためのコマンドラインランチャーで、Rackのrackupにインスパイアされました。.psgiファイルに保存されたPSGIアプリケーションであれば、Plackハンドラーに対応したWebサーババックエンドの上で動かすことができます。使い方はシンプルで、.psgiファイルのパスをコマンドに渡すだけです。

    > plackup hello.psgi
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

カレントディレクトリの`app.psgi`という名前のファイルを起動する場合、ファイル名も省略可能です。

デフォルトで起動するバックエンドは以下の方法で選ばれます。

* 環境変数`PLACK_SERVER`が定義されている場合、その値
* 環境特有の環境変数、たとえば `GATEWAY_INTERFACE` や `FCGI_ROLE` などが定義されている場合、CGIやFCGIバックエンドが自動で選ばれます
* ロードされた`.psgi`ファイルがAnyEvent, CoroやPOEなどのモジュールをロードしている場合、それに対応したバックエンドが自動で選ばれます
* その他の場合、"Standalone" バックエンドが選択され、HTTP::Server::PSGIモジュールによって起動します

コマンドラインスイッチ`-s`か`--server`でバックエンドを指定することもできます。

    > plackup -s Starman hello.psgi

plackupコマンドはデフォルトで3つのミドルウェアを有効にします。Lint, AccessLog と StackTrace で、開発の際にログやスタックトレースを表示してくれて便利ですが、これを無効にするには、`-E`または`--environment`スイッチで`development`以外の値をセットします:

    > plackup -E production -s Starman hello.psgi

Plack environment に`development`を利用したいが、デフォルトのミドルウェアは無効にしたい場合、`--no-default-middleware` オプションも用意されています。

その他のコマンドラインオプションをサーババックエンドに渡すこともでき、サーバのリッスンするポートは以下のように設定できます:

    > plackup -s Starlet --host 127.0.0.1 --port 8080 hello.psgi
    Plack::Handler::Starlet: Accepting connections at http://127.0.0.1:8080/

FCGIバックエンドでUNIXドメインソケットを指定するには:

    > plackup -s FCGI --listen /tmp/fcgi.sock app.psgi

その他のオプションについては、コマンドラインから`perldoc plackup`を実行して参照してください。明日もplackupについて解説をつづけます。
