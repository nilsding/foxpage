# ![](./misc/foxpage.png) FoxPage™

The hopelessly over-engineered static page generator.

## Installation

    $ gem install foxpage

## Usage

### Creating a new site

It's as easy as

    $ foxpage new my_cool_website
    $ cd my_cool_website
    
Adapt the site config in `./config/site.yml`, and edit some files in `./app`.
If you know Rails, you might feel right at home ;-)

### Building the web site

You can build your web site to `./_site` by running

    $ ./bin/foxpage build
    
or
    
    $ bundle exec foxpage build
    
### Running a development server

To run a local web server for development, you can do the following:

    $ ./bin/foxpage server

This server looks for changes in `./app` and rebuilds the site if something has
changed.  Changes in routes are also considered.

To make the server run on a different port, you can export the `APP_PORT`
environment variable.

## But... why?

I wanted to rebuild my website, so I built this on a Sunday afternoon.
¯\\\_(ツ)\_/¯

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/nilsding/foxpage. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FoxPage project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/nilsding/foxpage/blob/master/CODE_OF_CONDUCT.md).
