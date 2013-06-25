## Day 9: CGIスクリプトをPlackで走らせる

既存のCGIベースのアプリケーションをPSGIに変換する方法を幾つか紹介してきました。今日のエントリでは、すべてのCGIスクリプトを、多くの場合なにも変更せずに、PSGIアプリケーションとして実行する究極の方法を紹介します。

[CGI::PSGI](http://search.cpan.org/perldoc?CGI::PSGI)はCGI.pmのサブクラスとして実装されていて、CGI.pmからのマイグレーションは、多くの場合数行の変更だけで可能ですが、これは元のコードがある程度エントリポイントが整理されているなどの前提が必要です。レガシーなCGIスクリプトで、いろんな箇所で環境変数を直接参照したり、STDOUTに出力がされていて変更が難しい場合はどうでしょうか。

[CGI::Emulate::PSGI](http://search.cpan.org/perldoc?CGI::Emulate::PSGI) はCGIベースのPerlプログラムをPSGI環境で実行するモジュールです。CGI::Emulate::PSGIでは環境変数やSTDIN/STODOUTをCGI向けにエミュレートしてから実行するため、上で書いたようなレガシーなCGIスクリプトでSTDOUTにいろいろな箇所で出力をしていても問題ありません。

    use CGI::Emulate::PSGI;
    CGI::Emulate::PSGI->handler(sub {
        do "/path/to/foo.cgi";
        CGI::initialize_globals() if &CGI::initialize_globals;
    });

このコードで既存のCGIスクリプトをPSGIとして実行できます。CGI.pm を使っている場合、CGI.pmは多くのグローバル変数にキャッシュをつくるため、`initialize_globals`をリクエストごとに手動で実行する必要があります。

San FranciscoからLondon Perl Workshopに向かうフライトの途中で、これよりもさらにスマートな方法を思いついてハックしていました。`do`でスクリプトを都度実行するのではなく、CGIスクリプトをサブルーチンにコンパイルしてしまうものです。このモジュールは[CGI::Compile](http://search.cpan.org/perldoc?CGI::Compile) として公開されていて、CGI::Emulate::PSGIと組み合わせて使うと最適です。

    my $sub = CGI::Compile->compile("/path/to/script.cgi");
    my $app = CGI::Emulate::PSGI->handler($sub);

[Plack::App::CGIBin](http://search.cpan.org/perldoc?Plack::App::CGIBin) がPlackに付属していて、このアプリケーションは`/pat/to/cgi-bin`といったディレクトリにあるCGIスクリプトをそのままPSGIアプリケーションとして起動することができます。

    > plackup -MPlack::App::CGIBin -e 'Plack::App::CGIBin->new(root => "/path/to/cgi-bin"))'

こうして`/path/to/cgi-bin`にあるCGIスクリプトをマウントします。cgi-binディレクトリにある`foo.pl`は http://localhost:5000/foo.pl でアクセスできます。最初の実行時にコンパイルされるため、mod_perlのApache::Registryと似たような感じで動作します。
