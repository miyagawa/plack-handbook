## Day 24: まとめ

これが最後のカレンダーエントリになります。

### Best Practices

PlackとPSGIはまだ始まって間もないプロジェクトですが、新しくPSGI対応のアプリケーションやフレームワークを書く際のベストプラクティスがまとまってきています。

新しくフレームワークを書く際には、ユーザアプリケーションからPSGI環境変数へアクセス出来る方法を提供してください。直接アクセスできるのでも、アクセサ経由でもかまいません。DebugやSessionなど、PSGI環境変数を利用するミドルウェアを利用できるようになります。

`.psgi`ファイルでPlack::Requestを使ってアプリケーションを記述することは避けてください。スタイルの問題もありますが、アプリケーションは適切なクラスやオブジェクトに分割し、再利用やテスト(Day 13)可能にするのがよい開発手法です。`.psgi`ファイルは数行のブートストラップコードと、Builderによるミドルウェア設定のみになるでしょう。

Plack::App名前空間を使用することは避けてください。Plack::App名前空間はラッパーとして動作しないミドルウェア用に予約されたもので、Proxy, File, CascadeやURLMapなどが良い例です。Plackを使ってブログアプリを書いたからといって、Plack::App::Blogのようなものは**決して**使わないでください。ソフトウェアの名前は何をするかによって決められるべきで、何を使って書かれたかは関係ないはずです。

### 探索

Plackデベロッパーは[github](http://github.com/)でコードを開発しています。[github レポジトリを"Plack"で検索](http://github.com/search?langOverride=&q=plack&repo=&start_value=1&type=Repositories)すると面白いものが見つかるかもしれません。CPANをPlackやPSGIで検索しても、ミドルウェアやPSGIに対応しているツールを見つけることができるでしょう。

### 開発チームにコンタクトする

Plackはまだまだ若いプロジェクトで、まだまだ改善の余地があります。改善したい点、要望、バグをみつけたら、開発チームにコンタクトするなり、githubでforkしてpull requestを送ってください！

IRCチャンネル irc.perl.org の #plack でチャットをしていますし、[メーリングリスト](http://groups.google.com/group/psgi-plack) や[githubのissue tracker](http://github.com/plack/Plack/issues)でコンタクトすることが可能です。
