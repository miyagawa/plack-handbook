## Day 17: 静的ファイルを配信する

Day 5 ではplackupでカレントディレクトリからファイルを配信する方法を紹介しました。ミドルウェアの利用方法や、URLMapを使ったアプリケーションの合成方法を学んだので、Webアプリケーション開発に必須の機能を追加するのもとても簡単です。静的ファイルの配信です。

### あるパスから静的ファイルを配信する

ほとんどのフレームワークが静的ファイルを配信する機能を備えています。PSGIに対応したフレームワークであれば、この機能をつける必要はもうありません。Staticミドルウェアを利用します。

    use Plack::Builder;
    
    my $app = sub { ... };
    
    builder {
        enable "Static", path => qr!^/static!, root => './htdocs';
        $app;
    }

/staticではじまるリクエストにマッチすると、そのパスを"htdocs"にマップします。つまり、"/static/images/foo.jpg" は "./htdocs/static/images/foo.jpg" のファイルをレスポンスとして返します。

多くの場合、ディレクトリ名を変更したり、ローカルのパス名とオーバーラップしている場合があります。たとえば、/static/index.css へのリクエストを "./static-files/index.css" にマッピングするといった具合です。以下のようにします。

    builder {
        enable "Static", path => sub { s!^/static/!! }, root => './static-files';
        $app;
    }

重要なのは、pathに正規表現 (`qr`) ではなく、コールバックを利用し、`sub { s/// }`で文字列を置換しています。コールバックはリクエストパスに対して実行され、その値は `$_` に保存されています。この例では、リクエストパスが "/static/" で始まるかテスト、その場合パスから削除し、残りのパスを "./static-files/" 以下に追加しています。

結果として、"/static/foo.jpg" は "./static-files/foo.jpg" となります。このパターンマッチに失敗したリクエストはそのまま元の `$app`にパススルーされます。

### URLMap と App::File でDIY

Perlですから、やり方は一つではありません。Day 12で紹介したmountやURLMapの使い方を覚えていれば、App::Fileと`mount`を使う方法はより直感的に書けます。前の例は、以下のように書けます。

    use Plack::Builder;
    
    builder {
        mount "/static" => Plack::App::File->new(root => "./static-files");
        mount "/" => $app;
    };

これをどう見るかは個人の主観でしょうが、個人的にはこちらのほうが簡潔だと思います。Staticミドルウェアのコールバックでは、リクエストパスのマッチングや置換がより柔軟に行えるため、こちらを使う方がよい場合もあるでしょう。どちらでも好きな方法を使ってください。
