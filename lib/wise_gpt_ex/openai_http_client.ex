defmodule WiseGPTEx.OpenAIHTTPClient do
  @moduledoc """
  Documentation for `WiseGPTEx.OpenAIHTTPClient`.

  This module contains functions to interact with the OpenAI API to get completions with reasoning and determine the best completion. It is used internally by the `WiseGPTEx` module and is not intended to be called directly by users.

  The main functions in this module are:

    * `get_completions_with_reasoning/2` - Retrieves completions with reasoning from the OpenAI API based on a given message and an optional list of options.
    * `get_best_completion/3` - Determines the best completion from a list of completions and an optional list of options.

  """
  alias WiseGPTEx.OpenAIUtils, as: Utils

  @openai_completions_api_url "https://api.openai.com/v1/chat/completions"
  @default_model "gpt-3.5-turbo"
  @default_temperature 0.5
  @default_num_completions 3
  # 60 minutes
  @default_timeout_ms 3_600_000

  @spec get_completions_with_reasoning(binary(), Keyword.t()) :: {:ok, list()} | {:error, map()}
  def get_completions_with_reasoning(message, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    n = Keyword.get(opts, :num_completions, @default_num_completions)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    content = Utils.reasoning_prompt(message)

    payload =
      %{
        "model" => model,
        "temperature" => temperature,
        "n" => n,
        "messages" => [
          %{"role" => "user", "content" => content}
        ]
      }
      |> Jason.encode!()

    post_completions(payload, timeout, &Utils.extract_completions/1)
  end

  @spec get_best_completion(binary(), list(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def get_best_completion(message, completions, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    reasoning_prompt = Utils.reasoning_prompt(message)
    completions_options = Utils.prepare_completion_options(completions)
    researcher_prompt = Utils.researcher_prompt(message, completions_options)

    payload =
      %{
        "model" => model,
        "temperature" => temperature,
        "messages" => [
          %{"role" => "user", "content" => reasoning_prompt},
          %{"role" => "assistant", "content" => completions_options},
          %{"role" => "user", "content" => researcher_prompt}
        ]
      }
      |> Jason.encode!()

    post_completions(payload, timeout, &Utils.extract_completion/1)
  end

  @spec get_resolver_completion(binary(), list(), binary(), Keyword.t()) ::
          {:ok, binary()} | {:error, any()}
  def get_resolver_completion(message, completions, best_completion, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    reasoning_prompt = Utils.reasoning_prompt(message)
    completions_options = Utils.prepare_completion_options(completions)
    researcher_prompt = Utils.researcher_prompt(message, completions_options)
    resolver_prompt = Utils.resolver_prompt()

    payload =
      %{
        "model" => model,
        "temperature" => temperature,
        "messages" => [
          %{"role" => "user", "content" => reasoning_prompt},
          %{"role" => "assistant", "content" => completions_options},
          %{"role" => "user", "content" => researcher_prompt},
          %{"role" => "assistant", "content" => best_completion},
          %{"role" => "user", "content" => resolver_prompt}
        ]
      }
      |> Jason.encode!()

    post_completions(payload, timeout, &Utils.extract_completion/1)
  end

  defp post_completions(payload, timeout, extract_fn) do
    case http_client().post!(@openai_completions_api_url, payload, headers(),
           recv_timeout: timeout
         ) do
      %{status_code: 200, body: body} -> {:ok, body |> Jason.decode!() |> extract_fn.()}
      %{body: body} -> {:error, Jason.decode!(body)}
    end
  end

  defp headers do
    [
      {"authorization", "Bearer #{openai_api_key()}"},
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  defp http_client do
    Application.get_env(:wise_gpt_ex, :http_client, HTTPoison)
  end

  defp openai_api_key do
    Application.fetch_env!(:wise_gpt_ex, :openai_api_key)
  end
end
