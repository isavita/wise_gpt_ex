Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
Application.put_env(:wise_gpt_ex, :http_client, HTTPoison.BaseMock)
Application.put_env(:wise_gpt_ex, :openai_api_key, "sk-XXX")
ExUnit.start()
