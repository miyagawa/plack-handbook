## Day 8: WebフレームワークをPSGIに対応させる

Webアプリケーションフレームワーク作者にとって、PSGIの最大のメリットは、一度PSGIに対応すれば、FastCGI、CGIといったWebサーバ固有の環境の差異といった問題に対応する必要がなくなるということです。

オープンソースあるいはプロプライエタリの大規模なWebアプリケーションを開発している場合、自家製のフレームワークを作っているという場合も多いでしょう。

今日のエントリではこうしたフレームワークをどのようにPSGIインタフェースに対応させるかを紹介します。

### CGI.pm ベースのフレームワーク

Day 7ではCGI::ApplicationベースのアプリケーションをCGI::Application::PSGI経由で、PSGIで起動させる方法を紹介しました。CGI::Applicationはその名前からわかるようにCGI.pmを利用していますので、ここをCGI::PSGIにすり替えてしまうのがもっとも手っ取り早い方法です。

    package CGI::Application::PSGI;
    use strict;
    use CGI::PSGI;

    sub run {
        my($class, $app) = @_;

        # HACK: deprecate HTTP header generation
        # -- CGI::Application should support some flag to turn this off cleanly
        my $body = do {
            no warnings 'redefine';
            local *CGI::Application::_send_headers = sub { '' };
            local $ENV{CGI_APP_RETURN_ONLY} = 1;
            $app->run;
        };
    
        my $q    = $app->query;
        my $type = $app->header_type;

        my @headers = $q->psgi_header($app->header_props);
        return [ @headers, [ $body ] ];
    }

メインとなる実装はたったこれだけです。CGI::Applicationの`run`メソッドは通常、HTTPヘッダとボディを含む全体の出力を文字列で返します。ご覧のとおり、このモジュールはちょっと行儀の悪いハックでHTTPヘッダ生成をオーバーライドして、CGI::PSGIモジュールの`psgi_header`メソッドを使ってPSGIのレスポンスを返しています。

[Mason](http://search.cpan.org/perldoc?HTML::Mason) や [Maypole](http://search.cpan.org/perldoc?Maypole) 用のPSGIアダプターも実装してみましたが、おおむねコードは同様です。

* `$env`からCGI::PSGIインスタンスを作り、それをCGI.pmインスタンスの代わりにセットする
* 必要ならHTTPヘッダ出力を抑制
* アプリのメインディスパッチャーを実行
* 送信するHTTPヘッダを抽出、`psgi_header` を使ってステータスとヘッダを生成
* レスポンスボディを抽出

### アダプターベースのフレームワーク

フレームワークがすでにアダプターベースのアプローチでWebサーバ環境の差異を吸収している場合、PSGIサポートを追加するのはさらに簡単になります。CGI用のコードを少し変更するだけですみます。以下のコードは[Squatting](http://search.cpan.org/perldoc?Squatting) をPSGI対応させるためのコードです。SquattingはSquatting::On::* ネームスペースでmod_perl, FastCGIやその他のフレームワーク(Catalyst, HTTP::Engine)などへのアダプターを記述します。[Squatting::On::PSGI](http://search.cpan.org/perldoc?Squatting::On::PSGI) でPSGI対応のコードを書くのはとても簡単でした。

    package Squatting::On::PSGI;
    use strict;
    use CGI::Cookie;
    use Plack::Request;
    use Squatting::H;
    
    my %p;
    $p{init_cc} = sub {
      my ($c, $env)  = @_;
      my $cc       = $c->clone;
      $cc->env     = $env;
      $cc->cookies = $p{c}->($env->{HTTP_COOKIE} || '');
      $cc->input   = $p{i}->($env);
      $cc->headers = { 'Content-Type' => 'text/html' };
      $cc->v       = { };
      $cc->status  = 200;
      $cc;
    };
    
    # \%input = i($env)  # Extract CGI parameters from an env object
    $p{i} = sub {
      my $r = Plack::Request->new($_[0]);
      my $p = $r->params;
      +{%$p};
    };
    
    # \%cookies = $p{c}->($cookie_header)  # Parse Cookie header(s).
    $p{c} = sub {
      +{ map { ref($_) ? $_->value : $_ } CGI::Cookie->parse($_[0]) };
    };
    
    sub psgi {
      my ($app, $env) = @_;
    
      $env->{PATH_INFO} ||= "/";
      $env->{REQUEST_PATH} ||= do {
          my $script_name = $env->{SCRIPT_NAME};
          $script_name =~ s{/$}{};
          $script_name . $env->{PATH_INFO};
      };
      $env->{REQUEST_URI} ||= do {
        ($env->{QUERY_STRING})
          ? "$env->{REQUEST_PATH}?$env->{QUERY_STRING}"
          : $env->{REQUEST_PATH};
      };
    
      my $res;
      eval {
          no strict 'refs';
          my ($c, $args) = &{ $app . "::D" }($env->{REQUEST_PATH});
          my $cc = $p{init_cc}->($c, $env);
          my $content = $app->service($cc, @$args);
    
          $res = [
              $cc->status,
              [ %{ $cc->{headers} } ],
              [ $content ],
          ];
      };
    
      if ($@) {
          $res = [ 500, [ 'Content-Type' => 'text/plain' ], [ "<pre>$@</pre>" ] ];
      }
    
      return $res;
    }

多少のコード量がありますが、ほとんどは [Squatting::On::CGI](http://cpansearch.perl.org/src/BEPPU/Squatting-0.70/lib/Squatting/On/CGI.pm) と共通で、CGI.pmを利用している箇所をPlack::Requestに置き換えただけの単純なコードです。

昨日紹介した[Catalyst::Engine::PSGI](http://search.cpan.org/perldoc?Catalyst::Engine::PSGI) もほとんどがCGI用と共通です。

### mod_perl 中心のフレームワーク

いくつかのフレームワークは mod\_perl のAPIを多用して実装されていることがあり、こうした場合はCGI.pmを置き換えるといったアプローチは利用できません。Apache::RequestのAPIをfake/mock objectなどでモックする必要があるでしょう。WebGUIデベロッパーであるPatric Donelanが mod_perl ライクなAPIからPSGIへポートした際の事例を[ブログ記事](http://blog.patspam.com/2009/plack-roundup-at-sf-pm)で紹介しています。実際にリンクされている[モッククラス](http://github.com/pdonelan/webgui/blob/plebgui/lib/WebGUI/Session/Plack.pm) を見てみるのもよいでしょう。
