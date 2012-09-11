# Day 24: Wrap up

24 days have passed so fast and this is the last entry for this Plack advent calendar.

### Best Practices

Plack and PSGI are still really young projects but we've already discovered a couple of suggestions and advices to write a new PSGI application or a framework.

When you write a new framework, be sure to have an access to the PSGI environment hash from end users applications or plugin developers, either directly or with an accessor method. This allows your framework to share and extend functionality with middleware components like Debug or Session.

Do not write your application logic in `.psgi` files using Plack::Request. It's like writing a 1000 lines of CGI script using CGI.pm, so if you think that's your favorite i won't give you any further advice, but usually you want to make your application [testable](http://advent.plackperl.org/2009/12/day-13-use-placktest-to-test-your-application.html) and reusable by making it a class or an object. Then your `.psgi` code is just a few lines of code to create a PSGI application out of it and apply some middleware components.

Think twice before using Plack::App::* namespace. Plack::App namespace is for middleware components that do not act as a *wrapper* but rather an *endpoint*. Proxy, File, Cascade and URLMap are the good examples. If you write a blog application using Plack, **Never** call it Plack::App::Blog, okay? Name your software by what it does, not how it's written.

### Explore more stuff

Most of the Plack gangs use [github](http://github.com/) for the source control and [searching for repositories with "Plack"](http://github.com/search?langOverride=&q=plack&repo=&start_value=1&type=Repositories) would give you a fresh look of what would look like an interesting idea. You can also search for modules on CPAN with [Plack](http://search.cpan.org/search?query=plack&mode=module) or [PSGI](http://search.cpan.org/search?query=psgi&mode=module). I keep track of good blog posts and stuff on delicious, so you can see them tagged with [psgi](http://delicious.com/miyagawa/psgi) or [Plack](http://delicious.com/miyagawa/plack).

### Getting in touch with the dev team

Again, Plack is a fairly young project. It's just been 3 months since we gave this project a birth. There are many things that could get more improvements, so if you come across one of them, don't stop there. Let us know what you think is a problem, give us an insight how it could be improved, or if you're impatient, fork the project on github and send us patches.

We're chatting on IRC channel #plack on irc.perl.org and there's a [mailing list](http://groups.google.com/group/psgi-plack) and [an issue tracker on github](http://github.com/miyagawa/Plack/issues) to communicate with us.

### On a final note...

It's been an interesting experiment of writing 24 articles for 24 days, and I'm glad that I finished this myself. Next year, i'm looking forward to having your own advent entries to make the community based advent calendar. 

I wish you a Very Merry Christmas and a Happy New Year.
