## Day 20: Access your local app from the internet

(**EDIT**: The ReverseHTTP service we mention here is not available as of 2012)

These days laptops with modern operation systems allows you to quickly develop a web application and test it locally with its local IP address. Often you want to test your application with a global access, to show off your work to friends who don't have an access to your local network, or you're writing a web application that works as a [webhooks](http://www.webhooks.org/) callback.

### Reverse HTTP to the rescue

There are many solutions to this problem, but one notable solution is [ReverseHTTP](http://www.reversehttp.net/). It is a very simple specification of client-server-gateway protocol that uses pure HTTP/1.1 payloads, and what's nice about it is that there's a demo gateway service running on reversehttp.net, so you can actually use it for demo or testing purpose pretty quickly without setting up servers etc.

If you're curious how this really works, take a look at [the spec](http://www.reversehttp.net/specs.html). The reason why it's called *Reverse* HTTP is that your application (server) acts as a long-poll HTTP client and the gateway server sends back an HTTP request as a response. This might sound complex but well, it's really simple :)

### Plack::Server::ReverseHTTP

[Plack::Server::ReverseHTTP](http://search.cpan.org/~miyagawa/Plack-Server-ReverseHTTP-0.01/) is a Plack server backend that implements this ReverseHTTP protocol, so your PSGI based application can be accessed from the outside world via this reversehttp.net gateway service.

To use ReverseHTTP, install the required modules and run this:

    > plackup -s ReverseHTTP -o yourhostname --token password \
      -e 'sub { [200, ["Content-Type","text/plain"], ["Hello"]] }'
    Public Application URL: http://yourhostname.www.reversehttp.net/

`-o` is an alias for `--host` for plackup (because `-h` is taken for `--help` :)), and you should specify the subdomain (label) you're going to use. You should also supply `--token` which is like a generic password so nobody else can use your label once registered. You can omit this option if you *really* want anyone else to take that subdomain over.

The console will display the address (URL) like seen, and open the URL from the browser and viola! You see the "Hello" page, right?

### Use with frameworks

Of course because this is a PSGI server backend, you can use with *any* frameworks. Want to use it with Catalyst application?

    > catalyst.pl MyApp
    > cd MyApp
    > ./scripts/myapp_create.pl PSGI
    > plackup -o yourhost --token password ./scripts/myapp.psgi

That's it! The default Catalyst application will now be accessible with the URL http://yourhost.reversehttp.net/ from anywhere in the world.

### Notes

ReverseHTTP.net gateway service is an experimental service and there's no SLA or whatever, so I don't really think it's usable for production environment and such. But it's really handy and useful to quickly test your application that needs a global access, or show off your work to friends that don't have an internal access. Much easier than other solutions that require other software like SSH or VPN tunneling.
