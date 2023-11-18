defmodule WiseGPTEx.AnthropicHTTPClient do
  @moduledoc """
  Documentation for `WiseGPTEx.AnthropicHTTPClient`.

  This module provides functionalities to interact with the Anthropic API, specifically to utilize the Claude model for generating responses. It is designed to be used internally within the `WiseGPTEx` module and is not intended for direct usage.

  Key functions include:

    * `complete/2` - Sends a prompt to the Anthropic API and receives a completion using the Claude model. It allows customization of various parameters such as model, temperature, and maximum tokens.

    **NOTE:** This module is designed to offer a straightforward interface to the Anthropic API, focusing on raw API calls with minimal additional processing. It provides direct and flexible access to the Claude model's capabilities.

  Refer to the Claude API documentation for more details: https://docs.anthropic.com/claude/reference/complete_post
  """
  alias WiseGPTEx.AnthropicUtils, as: Utils

  @anthropic_complete_api_url "https://api.anthropic.com/v1/complete"
  @anthropic_version "2023-06-01"
  @default_model "claude-2"
  @default_temperature 0.1
  @default_max_tokens_to_sample 100_000
  # 60 minutes
  @default_timeout_ms 3_600_000

  @doc """
  Completes a prompt using Claude.
  Claude API docs: https://docs.anthropic.com/claude/reference/complete_post

  model - string | required
  The model that will complete your prompt.
  As we improve Claude, we develop new versions of it that you can query.
  This parameter controls which version of Claude answers your request.
  Right now we are offering two model families: Claude, and Claude Instant.
  You can use them by setting model to "claude-2" or "claude-instant-1", respectively.

  prompt - blob | required
  The prompt that you want Claude to complete.
  For proper response generation you will need to format your prompt as follows:
  ```JavaScript
  const userQuestion = r"Why is the sky blue?";
  const prompt = `\n\nHuman: ${userQuestion}\n\nAssistant:`;
  ```

  max_tokens_to_sample - integer | required
  The maximum number of tokens to generate before stopping.
  Note that our models may stop before reaching this maximum.
  This parameter only specifies the absolute maximum number of tokens to generate.

  stop_sequences - array of strings
  Sequences that will cause the model to stop generating completion text.
  Our models stop on "\n\nHuman:", and may include additional built-in stop sequences in the future.
  By providing the stop_sequences parameter, you may include additional strings that will cause the model to stop generating.

  temperature - number
  Amount of randomness injected into the response.
  Defaults to 1. Ranges from 0 to 1.
  Use temp closer to 0 for analytical / multiple choice, and closer to 1 for creative and generative tasks.

  top_p - number
  Use nucleus sampling.
  In nucleus sampling, we compute the cumulative distribution over all the options for each subsequent token
   in decreasing probability order and cut it off once it reaches a particular probability specified by top_p.
  You should either alter temperature or top_p, but not both.

  top_k - integer
  Only sample from the top K options for each subsequent token.
  Used to remove "long tail" low probability responses.

  metadata - object
  An object describing metadata about the request.
    user_id - string
    An external identifier for the user who is associated with the request.
    This should be a uuid, hash value, or other opaque identifier.
    Anthropic may use this id to help detect abuse.
    Do not include any identifying information such as name, email address, or phone number.

  stream - boolean
  Whether to incrementally stream the response using server-sent events.
  """
  @spec complete(binary(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def complete(message, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    max_tokens_to_sample = Keyword.get(opts, :max_tokens_to_sample, @default_max_tokens_to_sample)
    stream = Keyword.get(opts, :stream, false)
    extract_fn = Keyword.get(opts, :extract_fn, &Utils.extract_complete/1)

    payload =
      %{
        "model" => model,
        "prompt" => "#{message}",
        "max_tokens_to_sample" => max_tokens_to_sample,
        "temperature" => temperature,
        "stream" => stream
      }
      |> Jason.encode!()

    post_complete(payload, timeout, extract_fn)
  end

  defp post_complete(payload, timeout, extract_fn) do
    case http_client().post!(@anthropic_complete_api_url, payload, headers(),
           recv_timeout: timeout
         ) do
      %{status_code: 200, body: body} -> {:ok, body |> Jason.decode!() |> extract_fn.()}
      %{body: body} -> {:error, Jason.decode!(body)}
    end
  end

  defp headers do
    [
      {"x-api-key", anthropic_api_key()},
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"anthropic-version", @anthropic_version}
    ]
  end

  defp http_client do
    Application.get_env(:wise_gpt_ex, :http_client, HTTPoison)
  end

  defp anthropic_api_key do
    Application.fetch_env!(:wise_gpt_ex, :anthropic_api_key)
  end
end
