# heroku-nodejs-metrics-buildpack

This buildpack sets up the necessary machinery to utilize
[Heroku's Language Metrics](https://devcenter.heroku.com/articles/language-runtime-metrics) feature
for Node.js applications.

# What Node versions does it support

This buildpack supports all Node versions greater than `8.0.0`. All `8.x`, `9.x`, and `10.x` releases are supported.

Including this buildpack with an earlier version of Node will not break the application. It will simply become a no-op.

## How does it affect my slug?

This buildpack does two things.

1. Copies a Node.js module into the slug
2. Copies a [.profile.d/](https://devcenter.heroku.com/articles/dynos#the-profile-file) script into your slug

When `$HEROKU_METRICS_URL` is set as a result of the
`runtime-heroku-metrics` labs flag, the Node module will be automatically required by your
Node app at runtime using [the `NODE_OPTIONS` env var introduced in 8.0.0](https://medium.com/the-node-js-collection/node-options-has-landed-in-8-x-5fba57af703d).

The Node module monitors your application's event loop and garbage collector and forwards
metrics to `$HEROKU_METRICS_URL` for processing.

## Future Plans

This buildpack is expected to be rolled into the [official Node buildpack](https://github.com/heroku/heroku-buildpack-nodejs) before Node metrics are GA.

## Testing

This buildpack uses [Hatchet](https://github.com/heroku/hatchet) to run integration tests. To run them locally
make sure you have [Ruby](https://www.ruby-lang.org/) installed, then execute:

```
$ bundle install
$ bundle exec rspec
```

While it takes too long to run on Travis as part of CI, you can validate changes across every supported version of Node locally by running:

```
$ bundle install
$ TEST_ALL_NODE_VERSIONS=true bundle exec rspec
```
