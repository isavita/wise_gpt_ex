defmodule WiseGPTEx.MistralHTTPClient do
  @moduledoc """
  Provides functionalities to interact with the Mistral API for chat completions. Sends prompts to the API and receives responses, with various customizable parameters.
  """

  alias WiseGPTEx.MistralUtils, as: Utils

  @mistral_complete_api_url "https://api.mistral.ai/v1/chat/completions"
  @default_model "mistral-small"
  @default_temperature 0.5
  @default_top_p 1
  @default_max_tokens 32000
  @default_stream false
  @default_safe_mode false
  @default_random_seed nil
  # 10 minutes
  @default_timeout_ms 600_000

  @doc """
  Completes a chat prompt using Mistral.

  ## Parameters

    * `messages` - An array of objects representing the chat prompts. Each object should have a `role` (either 'user' or 'system') and `content` which is the actual text of the prompt. This is the input for the Mistral model to generate completions.

    * `opts` - Optional parameters for the request, which allow customization of the API call. These include:
      - `:model` - A string representing the ID of the model to use. Different models might have different capabilities or performance characteristics.
      - `:temperature` - A number between 0.0 and 1.0 that controls the randomness of the completion. Higher values increase randomness, while lower values produce more deterministic outputs.
      - `:top_p` - Nucleus sampling parameter, a number between 0 and 1, representing the cumulative probability of the considered tokens for completion. Lower values focus on more likely tokens.
      - `:max_tokens` - The maximum number of tokens to generate for the completion. This limits the length of the response.
      - `:stream` - A boolean that, if set to true, streams back partial progress of the completion. Otherwise, the server waits until the completion is fully generated before responding.
      - `:safe_mode` - A boolean to decide whether to inject a safety prompt before all conversations for content moderation.
      - `:random_seed` - An integer that sets the seed for random sampling, allowing for deterministic results if set.
      - `:timeout` - The timeout for the HTTP request in milliseconds.
      - `:extract_fn` - A function for extracting the desired data from the API response. By default, it uses `Utils.extract_complete/1`.

  ## Returns

    * `{:ok, completion}` on successful generation of completion.
    * `{:error, reason}` on failure, with details of the error.
  """
  def complete(message, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    top_p = Keyword.get(opts, :top_p, @default_top_p)
    max_tokens = Keyword.get(opts, :max_tokens, @default_max_tokens)
    stream = Keyword.get(opts, :stream, @default_stream)
    safe_mode = Keyword.get(opts, :safe_mode, @default_safe_mode)
    random_seed = Keyword.get(opts, :random_seed, @default_random_seed)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    extract_fn = Keyword.get(opts, :extract_fn, &Utils.extract_completion/1)

    payload = %{
      "model" => model,
      "messages" => [
        %{"role" => "user", "content" => message}
      ],
      "temperature" => temperature,
      "top_p" => top_p,
      "max_tokens" => max_tokens,
      "stream" => stream,
      "safe_mode" => safe_mode
    }

    payload =
      if random_seed do
        Map.put(payload, "random_seed", random_seed)
      else
        payload
      end

    post_complete(Jason.encode!(payload), timeout, extract_fn)
  end

  defp post_complete(payload, timeout, extract_fn) do
    case http_client().post(@mistral_complete_api_url, payload, headers(), recv_timeout: timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Jason.decode!() |> extract_fn.()}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status: status_code, message: Jason.decode!(body)["message"]}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", "Bearer " <> mistral_api_key()}
    ]
  end

  defp http_client do
    Application.get_env(:wise_gpt_ex, :http_client, HTTPoison)
  end

  defp mistral_api_key do
    Application.fetch_env!(:wise_gpt_ex, :mistral_api_key)
  end
end
