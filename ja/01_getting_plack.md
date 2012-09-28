## Day 1: Plackを入手

まずはじめに、[Plack](http://search.cpan.org/dist/Plack)とその他ユーティリティをインストールしましょう。PSGIやPlackは通常のPerlモジュールとして配布されているので、インストールはCPANシェルをたちあげて以下のようにタイプするだけです。

```
cpan> install PSGI Plack
```

[PSGI](http://search.cpan.org/dist/PSGI) はPSGIインタフェースの仕様を記述したドキュメントをモジュール化したものです。インストールすることによってシェルから`perldoc PSGI` や `perldoc PSGI::FAQ`としてドキュメントを参照することができます。Plackは標準のサーバ実装、コアのミドルウェアやplackup, Plack::Testといったユーティリティが付属します。

PlackはコアではないXSモジュールに依存していないため、Perl 5.8.1 以上のバージョンであれば特に問題なくリリースできるはずですし、CコンパイラのないWin32やDeveloper ToolsのないMac OS X環境でも利用が可能です (*とはいえ、makeなどのツールがないとCPANからのインストールが実行できないかもしれません）。

Webアプリケーションやフレームワークのデベロッパーであれば、オプションのバンドル [Task::Plack](http://search.cpan.org/dist/Task-Plack)もインストールすることをおすすめします。こちらも、以下のコマンドでインストールが可能です。

```
cpan> install Task::Plack
```

CPANシェルを対話モードで起動している場合、いくつかの質問を聞かれるかもしれません。不明な場合はデフォルトを選択して問題ありません。オプションのXSモジュールについてはデフォルトでインストールされますが、非同期用のサーバなどは標準ではインストールされません。

`perldoc Plack` としてドキュメントの概観を読むことができます。

