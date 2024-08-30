# extreme_overclocking_client

Ruby client for [Extreme Overclocking's Folding@home Data Export](https://folding.extremeoverclocking.com/?nav=XML)

Need more data on projects and GPUs? Try out [`folding_at_home_client`](https://github.com/blakegearin/extreme_overclocking_client)

## Getting Started

Install and add to Gemfile:

```bash
bundle add extreme_overclocking_client
```

Install without bundler:

```bash
gem install extreme_overclocking_client
```

## Usage

Please read the full [usage statement](https://folding.extremeoverclocking.com/?nav=XML) from Extreme Overclocking before using. This client has some simplistic rate limiting built-in, but ultimately it's up to consumers of the gem to prevent excessive queries and abuse. Neglecting to do so may result in your IP being blocked.

- [Service](#service)
- [Config](#config)
- [User](#user)
- [Team](#team)

Data can be retrieved via the `Service` class or individual classes with a configuration parameter.

### Service

```ruby
service = ExtremeOverclockingClient::Service.new(
  project_url: 'https://github.com/blakegearin/extreme_overclocking_client',
  project_name: 'ExtremeOverclockingClientTesting',
  project_version: '0.0.1',
)

user_id = 32334
name = 'EOC_Jason'
team_id = 11314

# User

user = service.user(id: user_id)
user = service.user(name: name, team_id: team_id)

# Users

users = service.users(ids: [32334, 811139])
hashes = [
  { name: name, team_id: team_id},
  { name: name, team_id: team_id},
]
users = service.users(hashes: hashes)

# Team

team = service.team(id: team_id)

# Teams

teams = service.teams(ids: [11314, 223518])
```

### Config

Provide a `project_url` and `project_name` to let Extreme Overclocking know what your project is. These values populate referer and user-agent metadata sent with each request.

```ruby
config = ExtremeOverclockingClient::Config.new(
  project_url: 'https://github.com/blakegearin/extreme_overclocking_client',
  project_name: 'ExtremeOverclockingClientTesting',
  project_version: '0.0.1',
)
```

### User

```ruby
user_id = 32334
name = 'EOC_Jason'
team_id = 11314
config = ExtremeOverclockingClient::Config.new(
  project_url: 'https://github.com/blakegearin/extreme_overclocking_client',
  project_name: 'ExtremeOverclockingClientTesting',
  project_version: '0.0.1',
)

# Fetch a user by id
# Required: config, id
user = ExtremeOverclockingClient::User.new(config: config, id: user_id)

# Fetch a user with a name and team_id
# Required: config, name, team_id
user = ExtremeOverclockingClient::User.new(config: config, name: name, team_id: team_id)

## Update a user with the latest stats
user.refresh
```

### Team

```ruby
id = 11314
config = ExtremeOverclockingClient::Config.new(
  project_url: 'https://github.com/blakegearin/extreme_overclocking_client',
  project_name: 'ExtremeOverclockingClientTesting',
  project_version: '0.0.1',
)

# Fetch a team by id
team = ExtremeOverclockingClient::Team.new(config: config, id: id)

## Update a team with the latest stats
team.refresh
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports, feature requests, and pull requests are welcome.

## Links

- [Folding@home](https://foldingathome.org)

- [Folding@home Download](https://foldingathome.org/start-folding)

- [Folding@home Stats](https://stats.foldingathome.org)

- [EXTREME Overclocking (EOC) Stats](https://folding.extremeoverclocking.com/aggregate_summary.php)

- [EXTREME Overclocking (EOC) Stats Export Info](https://folding.extremeoverclocking.com/?nav=XML)
