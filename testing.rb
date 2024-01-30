config = ExtremeOverclockingClient::Config.new(
  project_url: "https://github.com/blakegearin/extreme_overclocking_client",
  project_name: "ExtremeOverclockingClientTesting",
)

u = ExtremeOverclockingClient::User.new(config: config, id: 32334)
u = ExtremeOverclockingClient::User.new(config: config, name: "EOC_Jason", team_id: 11314)

t = ExtremeOverclockingClient::Team.new(config: config, id: 11314)
