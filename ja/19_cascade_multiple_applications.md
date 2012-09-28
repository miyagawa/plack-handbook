## Day 19: 複数のアプリケーションをカスケードする

Conditionalミドルウェア(Day 18)とURLMapアプリケーション(Day 12)には共通点があります。これら自体がPSGIアプリケーションですが、既存のPSGIアプリケーションやミドルウェアを受け取ってそれらにディスパッチするものです。これがPSGIのアプリケーションやミドルウェアの美しい点で、今日紹介するのもその一例です。

### 複数のアプリケーションをカスケードする

複数のアプリケーションを順番に実行し、成功が返ってくるまでカスケードするのは便利なことがあります。デザインパターンではChain of responsibilityと呼ばれ、mod_perlハンドラなどのWebアプリケーションでも応用されています。

### Cascade Application

Plack::App::Cascade は複数のPSGIアプリケーションを合成し、順番に実行して404以外のレスポンスが返ってくるまでトライします。

    use Plack::App::Cascade;
    use Plack::App::File;
    use Plack::App::URLMap;
    
    my @paths = qw(
        /home/www/static
        /virtualhost/example.com/htdocs/static
        /users/miyagawa/public_html/images
    );
    
    my $app = Plack::App::Cascade->new;
    for my $path (@paths) {
        my $file = Plack::App::File->new(root => $path);
        $app->add($file);
    }
    
    my $map = Plack::App::URLMap->new;
    $map->mount("/static" => $app);
    $map->to_app;

このアプリケーションを URLMap を使って /static にマップしています。すべてのリクエストは`@paths`に設定された3つのディレクトリをApp::Fileで順番にトライし、ファイルが見つかったらそれをレスポンスとして返します。スタティックファイルを複数のディレクトリからカスケードして返すのに便利です。

### アプリケーションをカスケード

    use CatalystApp;
    my $app1 = CatalystApp->psgi_app;
    
    use CGI::Application::PSGI;
    use CGIApp;
    my $app2 = sub {
        my $app = CGIApp->new({
            QUERY => CGI::PSGI->new($_[0]),
        });
        CGI::Application::PSGI->run($app);
    };
    
    use Plack::App::Cascade;
    Plack::App::Cascade->new(apps => [ $app1, $app2 ])->to_app;

この例では2つのアプリケーション、1つはCatalyst もう1つはCGI::Applicationを用意し、順番に実行します。/what/ever.cat をCatalystアプリケーション、/what/ever.cgiapp をCGI::Application側で処理する、といった際にこのようにカスケードさせることができます。

とはいえ、クレイジーなアイデアのように聞こえるかもしれません。実際にはURLMapで違うパスにmountするほうが現実的でしょうが、こういうこともできるということで :)
