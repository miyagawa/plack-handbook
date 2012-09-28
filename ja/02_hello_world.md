## Day 2: Hello World

プログラミング言語の学習で最初に書くプログラムは "Hello World" を表示することです。PSGIでもそうしてみましょう。

**注意:** 今日のコードは理解のためにPSGIの生インタフェースを利用して書かれていますが、あなたがWebアプリケーションフレームワークの作者でない限り、実際にはこうしたコードを書く必要はありません。[PSGIをサポートしているフレームワーク](http://plackperl.org/#frameworks)を参照してください。

### Hello, World

"Hello World" を表示するための最小限のコードは以下のようになります。

    my $app = sub {
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello World' ] ];
    };

PSGIアプリケーションはPerlのサブルーチンリファレンス(コードリファレンス)を利用して記述し、ここでは`$app`という変数名に格納しています（が、名前はなんでも構いません）。このサブルーチンは1つの引数`$env`を受け取り（今回のコードでは省略されています）、ステータス、ヘッダとボディを格納した配列リファレンスを返します。

このコードを`hello.psgi`というファイルに保存し、plackupコマンドで起動しましょう:

    > plackup hello.psgi
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

plackup はアプリケーションをデフォルトのHTTPサーバ HTTP::Server::PSGI を利用して localhost の5000番ポートで起動します。http://127.0.0.1:5000/ をブラウザで開くと、Hello Worldが表示されましたか？

### 違うものを表示

Hello Worldはとてもシンプルなものですが、もう少し違ったことをやってみましょう。クライアント情報をPSGI environmentから取得し、表示します。

    my $app = sub {
        my $env = shift;
        return [
            200, 
            ['Content-Type' => 'text/plain'],
            [ "Hello stranger from $env->{REMOTE_ADDR}!"],
        ];
    };

このコードはクライアントのリモートアドレスをPSGIのenvironmentハッシュから表示します。ローカルホストで起動している場合、値は127.0.0.1 になるはずです。PSGI environmentにはHTTPの接続やクライアントに関する情報、たとえばHTTPヘッダやリクエストパスなどが格納されていて、CGIの環境変数によく似ています。

テキスト以外のデータをファイルから表示するには、以下のようにします。

    my $app = sub {
        my $env = shift;
        if ($env->{PATH_INFO} eq '/favicon.ico') {
            open my $fh, "<:raw", "/path/to/favicon.ico" or die $!;
            return [ 200, ['Content-Type' => 'image/x-icon'], $fh ];
        } elsif ($env->{PATH_INFO} eq '/') {
            return [ 200, ['Content-Type' => 'text/plain'], [ "Hello again" ] ];
        } else {
            return [ 404, ['Content-Type' => 'text/html'], [ '404 Not Found' ] ];
        }
    };

このアプリケーションはリクエストパスが`/favicon.ico`となっている場合に`favicon.ico`を表示し、ルート(/)については"Hello World"、その他のパスには404を返します。Perlの標準ファイルハンドルである`$fh`はPSGIのボディにそのまま設定することができますし、ステータスコードについても妥当な数字をいれることができます。
