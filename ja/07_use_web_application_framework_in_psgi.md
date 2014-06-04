## Day 7: WebアプリケーションフレームワークをPSGIで利用する

PlackとPSGIプロジェクトを2009年9月にはじめて以来、Catalyst, Jifty やCGI::Applicationといった人気のあるフレームワークのデベロッパーから多くのフィードバックをもらいました。

[CGI::Application](http://cgi-app.org/) はもっとも「伝統的」なCGIベースのWebアプリケーションフレームワークで、昨日も紹介したようにCGI.pmを利用して様々な環境の差異を吸収しています。

CGI::Applicationの現在のメンテナであるMark Stosbergと、CGI::ApplicationにおけるPSGIサポートについて検討してきました。いくつかのアプローチを検討し、その中にはPSGIサポートを直接CGI::Applicationに記述するものも含まれましたが、昨日も紹介したCGI::PSGIをラッパーとして開発し、[CGI::Application::PSGI](http://search.cpan.org/perldoc?CGI::Application::PSGI)を既存のCGI::Applicationを変更することなくPSGI互換モードで起動させるように実装しました。

CGI::Application::PSGIをCPANからインストールして、`.psgi`ファイルを以下のように記述します。

    use CGI::Application::PSGI;
    use WebApp;

    my $app = sub {
        my $env = shift;
        my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
        CGI::Application::PSGI->run($app);
    };

そして[plackup](http://advent.plackperl.org/2009/12/day-3-using-plackup.html)を使ってスタンドアロンや各種バックエンドのサーバ上で起動することができます。

同様に、多くのWebフレームワークではPSGIサポートをするためのプラグイン、エンジンやアダプターを提供し、PSGIモードで起動するための機能が用意されています。たとえば[Catalyst](http://www.catalystframework.org/)ではCatalyst::EngineというレイヤーでWebサーバエンジンの抽象化を行っていて、[Catalyst::Engine::PSGI](http://search.cpan.org/perldoc?Catalyst::Engine::PSGI) でCatalystをPSGI上で起動することができます。(**注**: 2011年にCatalyst 5.8 がリリースされ、PSGIサポートはCatalyst本体に組み込まれており、エンジンを別途インストールする必要はありません)

重要なのは、"PSGIサポート"しているフレームワークを利用する場合、利用者のアプリケーションをPSGI用に書き換える必要はないということです。多くの場合、1行のコードの変更も必要ありません。かつ、PSGIを利用することでplackup, Plack::Testやミドルウェアなど多くのエコシステムを利用することができます。これらについては、のちほど紹介していきます。
