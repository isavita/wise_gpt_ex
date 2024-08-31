defmodule WiseGPTEx.GroqHTTPClient do
  @moduledoc """
  Provides functionalities to interact with the Groq API for chat completions.
  """

  alias WiseGPTEx.GroqUtils, as: Utils

  @groq_complete_api_url "https://api.groq.com/openai/v1/chat/completions"
  @default_model "mixtral-8x7b-32768"
  @default_temperature 0.7
  @default_max_tokens 32000
  @default_timeout_ms 600_000

  @doc """
  Completes a chat prompt using Groq.

  ## Parameters

    * `messages` - A string or an array of objects representing the chat prompts.
    * `opts` - Optional parameters for the request.

  ## Returns

    * `{:ok, completion}` on successful generation of completion.
    * `{:error, reason}` on failure, with details of the error.

  ## Examples

      iex> WiseGPTEx.GroqHTTPClient.complete("Hi")
      {:ok, "Hello! How can I assist you today?"}

      iex> WiseGPTEx.GroqHTTPClient.complete([%{"role" => "user", "content" => "Hi"}])
      {:ok, "Hello! How can I assist you today?"}
  """
  def complete(messages, opts \\ [])

  def complete(message, opts) when is_binary(message) do
    complete([%{"role" => "user", "content" => message}], opts)
  end

  def complete(messages, opts) when is_list(messages) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    max_tokens = Keyword.get(opts, :max_tokens, @default_max_tokens)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    extract_fn = Keyword.get(opts, :extract_fn, &Utils.extract_completion/1)

    payload = %{
      "model" => model,
      "messages" => messages,
      "temperature" => temperature,
      "max_tokens" => max_tokens
    }

    post_complete(Jason.encode!(payload), timeout, extract_fn)
  end

  defp post_complete(payload, timeout, extract_fn) do
    case http_client().post(@groq_complete_api_url, payload, headers(), recv_timeout: timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Jason.decode!() |> extract_fn.()}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status: status_code, message: Jason.decode!(body)["error"]["message"]}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp headers do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Authorization", "Bearer " <> groq_api_key()}
    ]
  end

  defp http_client do
    Application.get_env(:wise_gpt_ex, :http_client, HTTPoison)
  end

  defp groq_api_key do
    Application.fetch_env!(:wise_gpt_ex, :groq_api_key)
  end
end
