## Day 20: ローカルアプリケーションにインターネットからアクセスする

(**注意**: reverseHTTP サービスは2012年現在停止しています)

最近では、ノートPC上でアプリケーションを開発し、ローカルのIPアドレスを使ってテストをするのが簡単です。こうして開発してローカルで動いているアプリケーションに対して、リモートで仕事をしている同僚や、webhookなどのテストをするために、インターネットからアクセスしたいことがあります。

### Reverse HTTP

この問題を解決するにはいくつかのソリューションがありますが、一つ面白いやりかたが[ReverseHTTP](http://www.reversehttp.net/)を使った方法です。ReverseHTTPはクライアント・サーバ・ゲートウェイ間のシンプルなプロトコルで、HTTP/1.1の拡張を用いています。便利なことに、reversehttp.netでデモゲートウェイが動作しているため、自分でサーバを立てたりすることなく、デモに利用することができます。

これが実際どのように動作するのか興味が有る人は、[仕様書](http://www.reversehttp.net/specs.html)に目を通してみるとよいでしょう。*Reverse* HTTP という名前の通り、動作させるアプリケーション・サーバがロングポールのHTTPクライアントになり、ゲートウェイ・サーバがインターネット経由でアクセスされたリクエストをレスポンスとして返します。

### Plack::Server::ReverseHTTP

[Plack::Server::ReverseHTTP](http://search.cpan.org/~miyagawa/Plack-Server-ReverseHTTP-0.01/) はPlackのバックエンドサーバ実装で、ReverseHTTPプロトコル上でPSGIアプリケーションを実行し、外部インターネットから、ローカルで動作しているPSGIアプリケーションへのアクセスを可能にします。

ReverseHTTPを利用するには、必要なモジュールをCPANからインストールし、以下のコマンドを実行します。

    > plackup -s ReverseHTTP -o yourhostname --token password \
      -e 'sub { [200, ["Content-Type","text/plain"], ["Hello"]] }'
    Public Application URL: http://yourhostname.www.reversehttp.net/

`-o` は`--host`のエイリアスで、利用するサブドメイン(ラベル)を指定します。`--token`は登録したラベルを使うためのパスワードとして利用します。指定しないこともできますが、この場合、登録したラベルを後から誰でも利用可能になります。

コンソールに出力されたアドレス(URL)をブラウザで開くと、Helloが表示されます。

### フレームワークからの利用

もちろんPSGIサーバのバックエンドですから、どんなフレームワークでも利用することができます。Catalystアプリに対して実行するには、

    > catalyst.pl MyApp
    > cd MyApp
    > plackup -o yourhost --token password myapp.psgi

たったこれだけです。 デフォルトのCatalystアプリケーションが http://yourhost.reversehttp.net/ というURLで、インターネット経由でどこからでもアクセス可能です。

### 注意

ReverseHTTP.netのゲートウェイサービスは実験的なものであり、SLAのような保証はありません。プロダクション環境などでの利用は避けたほうが良いでしょう。ちょっとしたアプリを友達に見せるときなどに、SSHやVPNトンネリングなどを必要とせず利用できるのは便利ですね。
