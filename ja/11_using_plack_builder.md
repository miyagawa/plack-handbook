## Day 11: Plack::Builderを使う

昨日のエントリではPlackミドルウェアを.psgiで利用する方法を紹介しました。ミドルウェアを`use`して、そのあと`$app`を`wrap`メソッドでラップしていくのは退屈ですし、直感的ではありません。そこで、それをより簡単にするDSL (Domain Specific Language) 風シンタックスを用意しています。それが、Plack::Builderです。

Plack::Builderの利用はとても簡単です。`builder`と`enable`キーワードを使います。

    my $app = sub { 
        return [ 200, [], [ "Hello World" ] ];
    };
    
    use Plack::Builder;
    builder {
        enable "JSONP";
        enable "Auth::Basic", authenticator => sub { ... };
        enable "Deflater";
        $app;
    };

このコードは元のアプリケーション`$app`に対して、Deflater, Auth::Basic と JSONP ミドルウェアを内側から外側に向けてラップしていきます。つまり、以下のコードと同様です。

    $app = Plack::Middleware::Deflater->wrap($app);
    $app = Plack::Middleware::Auth::Basic->wrap($app, authenticator => sub { });
    $app = Plack::Middleware::JSONP->wrap($app);

ただし、各モジュールを先に`use`する必要がないので、よりDRYになっています。

### 外側から内側へ、上から下へ

ラップされるミドルウェアの順番が逆であることにきづいたでしょうか？builder/enableのDSLでは、ラップされる`$app`に近い行が、*内側*で、最初の行が*外側*にくるようにラップされます。昨日紹介した玉ねぎの図と比較するとよりわかりやすくなります。アプリケーションに近い行ほど、レイヤーの内側になるということです。

`enable`を使うばあいPlack::Middleware::をミドルウェアの名前から省略できます。Plack::Middleware以外の名前空間を使う場合、たとえば MyFramework::PSGI::MW::Foo であれば、

    enable "+MyFramework::PSGI::MW::Foo";

とすることができます。重要なのはプラス(+)でモジュール名がFully Qualified であることを指定できます。

### 裏でおこっていること

もしPlack::Builderの実装に興味があれば、コードを見て何をしているか追ってみてください。`builder`はコードブロックを受け取り、それを実行した結果のコードリファレンスを元のアプリケーション(`$app`)として受け取り、そしてenableされたミドルウェアを逆順にラップしていきます。つまり、`builder`ブロックの最後に`$app`またはPSGIアプリケーションを配置することが重要で、また`builder`ブロックは.psgiファイルの最後になければなりません。

### Thanks, Rack

Plack::BuilderはRubyのRack::Builderにインスパイアされています。Rack::Builderでは`use`キーワードを使っていますが、Perlではこれは使えないため、`enable`で代用しています:) Rackには`map`キーワードでアプリケーションをパスにマップする機能がありますが、Plackでこれをどうするかは明日解説します。
