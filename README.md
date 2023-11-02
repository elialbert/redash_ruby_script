# redash_ruby_script
a quick sample of how to get redash api connected through ruby and HTTParty

You will need to provide your redash URL and api key as environment variables.
Documentation here: https://redash.io/help/user-guide/integrations-and-api/api

Use:
```
r = RedashApi.new
result = r.get_results(YOUR_QUERY_ID, YOUR_QUERY_PARAMS)
```