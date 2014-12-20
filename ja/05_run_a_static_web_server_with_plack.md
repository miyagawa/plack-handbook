## Day 5: Plackで静的サーバを起動する

Plackディストリビューションにはすぐに使えるPSGIアプリケーションがPlack::Appネームスペースの下に用意されています。いくつかはとても便利で、一例がここで紹介するPlack::App::FileとPlack::App::Directoryです。

Plack::App::Fileは`/foo/bar.html`といったリクエストパスを、`/path/to/htdocs/foo/bar.html`といったローカルのファイルにマップし、ファイルを開いてファイルハンドルをPSGIのレスポンスとして返します。lighttpd, nginx やApacheといった既成のWebサーバと同様です。

Plack::App::DirectoryはPlack::App::Fileのラッパーで、Apacheのmod_autoindexのようなディレクトリインデックスを表示します。

これらのアプリケーションの利用はとても簡単です。以下のような`.psgi`ファイルを記述します。

    use Plack::App::File;
    my $app = Plack::App::File->new(root => "$ENV{HOME}/public_html");

これをplackupで起動します。

    > plackup file.psgi

これで`~/public_html`以下のファイルはURL http://localhost:5000/somefile.html でアクセスできるようになります。

Plack::App::Directory についても同様ですが、plackupのコマンドラインから直接起動する例を紹介します。

    > plackup -MPlack::App::Directory \
     -e 'Plack::App::Directory->new(root => "$ENV{HOME}/Sites")'
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

plackupコマンドは、perlコマンド同様、`-I`(インクルードパス), `-M`(ロードするモジュール)や`-e`(実行するコード)を指定できるため、ワンライナーでPSGIアプリを書くことができます。

他にもPlack::Appにはいくつかアプリケーションが用意されていますが、それはまた別の日に。
