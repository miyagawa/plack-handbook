## Day 6: CGIアプリケーションをPSGIに変換

Perlでウェブアプリケーションを書く方法として長い間もっとも人気があったのがCGI, FastCGIとmod_perlでした。CGI.pmはPerlに付属するコアモジュールで、この3つの環境で同時に動くコードを記述することが(少しの変更で)できます。これによって、多くのWebアプリケーションやフレームワークはCGI.pmを使って環境の差異を吸収してきました。

[CGI::PSGI](http://search.cpan.org/perldoc?CGI::PSGI) を使うと、既存のCGI.pmベースのアプリケーションをPSGIに簡単に変換できます。以下のようなCGIアプリケーションがあるとします:

    use CGI;
    
    my $q = CGI->new;
    print $q->header('text/plain'),
        "Hello ", $q->param('name');

とてもシンプルなCGIスクリプトですが、これをPSGIに変換するには以下のようにします:

    use CGI::PSGI;
    
    my $app = sub {
        my $env = shift;
        my $q = CGI::PSGI->new($env);
        return [ 
            $q->psgi_header('text/plain'),
            [ "Hello ", $q->param('name') ],
        ];
    };

`CGI::PSGI->new($env)` はPSGIの環境変数ハッシュを受け取り、CGI.pmのサブクラスであるCGI::PSGIのインスタンスをつくります。`param`, `query_string`といったメソッドは今までどおり動作しますが、CGIの環境変数ではなく、PSGI環境変数から値を取得します。

`psgi_header` はCGIの`header`メソッドのように動作するユーティリティで、ステータスコードとHTTPヘッダの配列リファレンスをリストで返します。

明日は既存のCGI.pmを利用したフレームワークをPSGIに変換します。
