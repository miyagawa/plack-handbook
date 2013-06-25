## Day 14: Plack::Requestを利用する

Plack自身はWebフレームワークではありません。むしろ、PSGIサーバとミドルウェアの実装にplackup, Plack::Testなどのユーティリティが入ったツールキットのようなものです。

Plackプロジェクトは[HTTP::Engine](http://search.cpan.org/perldoc?HTTP::Engine)プロジェクトから派生した側面もあり、リクエスト・レスポンススタイルのAPIを使ってウェブアプリケーションを開発する需要はあるようです。Plack::Requestは、PSGI環境変数やレスポンス配列に対して、簡単なオブジェクト指向APIを提供します。新しいミドルウェアを記述する際のライブラリとしても利用できますし、PlackをベースにしたWebフレームワークを記述する際のリクエスト/レスポンスのベースクラスとしても使えます。

### Plack::Request と Response を使う

Plack::Request はPSGI環境変数へのラッパーであり、コードは以下のようになります。

    use Plack::Request;
    
    my $app = sub {
        my $req = Plack::Request->new(shift);
        
        my $name = $req->param('name');
        my $res  = $req->new_response(200);
        $res->content_type('text/html');
        $res->content("<html><body>Hello World</body></html>");
        
        return $res->finalize;
    };

HTTP::Engineからマイグレートする場合、変更する箇所は`shift`で取得したPSGI環境変数をPlack::Requestに渡し、最後に`finalize`を読んでPSGIレスポンスを取得することだけです。

その他、`path_info`, `uri`, `param` などはHTTP::Engine::RequestやResponseとほぼ同等に動作します。

### Plack::Request と Plack

Plack::Request はPlackディストリビューションに同梱されCPANから入手可能です。Plack::Requestをフレームワークで利用した場合、Plack標準のサーバ以外でも、PSGIに対応したサーバ実装であれば、どのサーバでも動作させることができます。

### Plack::Request を使うか否か

Plack::Requestを利用したコードを`.psgi`に直接記述するのは、簡単なプロトタイピングやテストには便利ですが、ある程度の規模アプリケーション開発にはおすすめしません。1000行のコードをCGIスクリプトに直接書くようなもので、多くの場合はモジュールに分割していくのが正しい方法です。PSGIでも同様で、アプリケーションをクラスにまとめ、リクエストクラスとしてPlack::Requestをサブクラスするなどして、`.psgi`ファイルにはPlack::BuilderのDSLでミドルウェアを設定するようなコードとエントリポイントだけが含まれるようになるはずです。

Plack::Request を利用して既存のフレームワークをPSGIインタフェースに対応させるためのライブラリとして使うのもよいでしょう。
