# rspec-queue

A parallel test runner specifically for rspec.

The main difference between this and similar gems is that it spawns entirely new worker processes instead of forking. This makes configuring the workers easier (especially when Rails is involved) as many things will "just work".

It's intended to work with RSpec >= 3.0. It may work with earlier versions, but I doubt it.

## Usage
Put it in your Gemfile, bundle, and you're away.

```ruby
gem 'rspec-queue'
```

If you need isolated databases, you'll need to ensure they are prepared before attempting to run any tests.

Add any configuration needed for each worker to your `spec_helper` file.

```ruby
RSpecQueue::Configuration.after_worker_spawn do |index|
  # Establish connection to an isolated database
  ActiveRecord::Base.configurations['test']['database'] << index.to_s
  ActiveRecord::Base.establish_connection(:test)
end
```

Running tests via rspec-queue is the same as running them via rspec.

```sh
bundle exec rspec-queue spec
```

By default, rspec-queue will spawn a number of workers equal to one less than the count of your total cpus. You can override this behaviour by setting the `RSPEC_QUEUE_WORKERS` environment variable.

```sh
RSPEC_QUEUE_WORKERS=6 bundle exec rspec-queue spec
```

## Potential Issues

If you're doing some form of acceptance testing you'll probably want to use xvfb to isolate the browsers for each worker so they don't do annoying things like steal focus from each other. This can cause many headaches trying to debug strange failures!

Fortunately, there's a gem for that: https://github.com/leonid-shevtsov/headless

You can then add some extra configuration in the `after_worker_spawn` block to use a different display for each worker:

```ruby
RSpecQueue::Configuration.after_worker_spawn do |index|
  # ...
  Headless.new(display: 100 + index.to_i, reuse: true, destroy_at_exit: true).start
end
```

If you're using Rails with page caching in test, you probably want to isolate the public folders for each worker. This should probably be done in your test environment configuration. It should be as easy as making a copy of your public folder for each worker.

```ruby
# test.rb
Rails.application.configure do
  # ...

  # RSPEC_QUEUE_WORKER_ID is a unique identifier for the current worker
  if ENV["RSPEC_QUEUE_WORKER_ID"]
    # copy the public directory to a distinct folder
    master_public_path = Rails.root.join("public")
    worker_root_path = Rails.root.join("tmp", "rspec-queue", ENV["RSPEC_QUEUE_WORKER_ID"])
    FileUtils.mkdir_p worker_root_path
    FileUtils.cp_r master_public_path, worker_root_path
    worker_public_path = worker_root_path.join("public")

    # point rails to the new directory
    config.paths["public"] = worker_public_path
    config.action_controller.page_cache_directory = worker_public_path
  end
end
```

Setting a distinct public folder can also assist with issues that arise when uploading files in acceptance tests.

## Things that aren't great

The way the formatting works isn't great. It was hacked together in a rush and extracted from an existing codebase as is. It unfortunately means that this gem won't work with any formatter that isn't it's own. The way the formatter is set in the rspec-queue binary is also not ideal and will likely cause issues with certain setups.

The plan is to fix that so it will work just fine with any formatter and make the configuration more sensible, but right now, it is how it is.

---

MIT license.
