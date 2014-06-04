## Day 15: ミドルウェアでアプリケーションの認証

Plackのミドルウェアは数多くリリースされていて、Plackに含まれているものや、CPANに単独でリリースされているものもあります。このAdvent Calendarをアップデートしている最中にも、多くのデベロッパーがミドルウェアを開発してCPANにアップロードしていました。

今日から、PSGI対応のアプリケーションにすぐ適用可能な、いくつかのおすすめミドルウェアを紹介します。

### Basic認証

Plackミドルウェアはアプリケーションをラップするため、真価を発揮するのはHTTPレイヤでの前処理、後処理です。今日紹介するのはBasic認証を行うミドルウェアです。

アプリケーションへのBasic認証の追加はいくつかの方法があります。フレームワークが対応していれば、提供されている機能で可能でしょう。例えばCatalystではCatalyst::Authentication::Credential::HTTPで対応がされています。多くのCatalyst拡張と同様、認証方法やユーザのストレージなど、様々な設定が可能になっています。

また、認証をウェブサーバレイヤーで行うこともできます。たとえば、Apacheとmod\_perlでアプリケーションを動かしている場合、Apacheデフォルトのmod_authモジュールで認証を追加するのはとても簡単ですが、「ユーザをどのように認証するか」の設定は、カスタムのApacheモジュールを書くなどしない限り、限界があります。

Plackミドルウェアでは、Webアプリケーションフレームワークがこうした機能を共有し、多くの場合シンプルなPerlコールバックで拡張することが可能です。Plack::Middleware::Auth::BasicはBasic認証に対してこうしたインターフェースを提供します。

### Plack::Middleware::Auth::Basic

その他のミドルウェアと同様、Auth::Basicミドルウェアの利用はとても簡単です。

    use Plack::Builder;
    
    my $app = sub { ... };
    
    builder {
        enable "Auth::Basic", authenticator => sub {
            my($username, $password) = @_;
            return $username eq 'admin' && $password eq 'foobar';
        };
        $app;
    };


このコードでアプリケーション`$app`にBaisic認証機能が提供されます。ユーザ名*admin*がパスワード*foobar*でサインインすることができます。認証に成功したユーザはPSGI環境変数`REMOTE_USER`にセットされ、アプリケーションから利用したりAccessLogミドルウェアからログに追加されます。

コールバックベースの設定になるため、Kerberosのような認証システムと連携するのはAuthen::Simpleモジュールを使うと簡単にできます。

    use Plack::Builder;
    use Authen::Simple;
    use Authen::Simple::Kerberos;

    my $auth = Authen::Simple->new(
        Authen::Simple::Kerberos->new(realm => ...),
    );
    
    builder {
        enable "Auth::Basic", authenticator => sub {
            $auth->authenticate(@_):
        };
        $app;
    };

同様に [Authen::Simpleバックエンド](http://search.cpan.org/search?query=authen+simple&mode=all) を使ってLDAPなどと連携することも可能です。

### URLMap

URLMap は複数のアプリケーションを1つのアプリケーションに合成することができます。Authミドルウェアと組み合わせると、同一のアプリを認証モードと非認証モードで走らせることもできます。

    use Plack::Builder;
    my $app = sub {
        my $env = shift;
        if ($env->{REMOTE_USER}) { 
            # Authenticated
        } else {
            # Unauthenticated
        }
    };
    
    builder {
        mount "/private" => builder {
            enable "Auth::Basic", authenticator => ...;
            $app;
        };
        mount "/public" => $app;
    };

このようにして同一の`$app`を/publicと/privateにマップし、/privateではBasic認証を必須とします。アプリケーションでは`$env->{REMOTE_USER}`をチェックすることで認証済みアクセスかどうか判別します。
