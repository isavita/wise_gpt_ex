defmodule WiseGPTEx do
  @moduledoc """
  Documentation for `WiseGPTEx`.

  This module provides functions to obtain the best completion from the OpenAI models (default: "gpt-3.5-turbo") using the OpenAI API completions endpoint (`https://api.openai.com/v1/chat/completions`).
  The `get_best_completion/2` and `get_best_completion_with_resolver/2` functions take a question and an optional list of options to configure the API request. `get_best_completion_with_resolver/2` also involves a secondary step to resolve the best completion among the options, which leads to an additional API call for a more accurate response.

  ## Installation

  1. Add `wise_gpt_ex` to your list of dependencies in `mix.exs`:
  ```elixir
  def deps do
    [
      {:wise_gpt_ex, "~> 0.2.0"}
    ]
  end
  ```

  2. Add the OpenAI API key to your configuration file (e.g., config/config.exs):
  ```elixir
  config :wise_gpt_ex, :openai_api_key, "your_openai_api_key"
  ```

  ## Examples

  Basic usage:

      iex> WiseGPTEx.get_best_completion("What is the capital of France?")
      {:ok, "Paris"}

      iex> WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?")
      {:ok, "Paris"}

  Using all available options:

      iex> opts = [model: "gpt-4", temperature: 0.7, num_completions: 5, timeout: 300_000]
      iex> WiseGPTEx.get_best_completion("What is the capital of France?", opts)
      {:ok, "Paris"}

      iex> WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?", opts)
      {:ok, "Paris"}

  Note that the examples for the `get_best_completion_with_resolver/2` function are similar to `get_best_completion/2`.
  This is because the difference between these two functions is in the method of how they select the best completion, not in their usage or the nature of their inputs or outputs.
  The `get_best_completion_with_resolver/2` function will perform an additional API call to get a more accurate completion, which can be beneficial for complex or ambiguous queries.

  ## Options

  The following options can be passed to the `get_best_completion/2` and `get_best_completion_with_resolver/2` functions:

    * `:model` - The name of the model to use (default: "gpt-3.5-turbo"). All OpenAI models are supported.
    * `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
    * `:num_completions` - The number of completions to generate (default: 3).
    * `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 300_000 ms, or 5 minutes).

  """
  alias WiseGPTEx.OpenAIHTTPClient

  @doc """
  `get_best_completion/2` attempts to answer a given question using OpenAI's completion endpoint.

  ## Params:
  - `question`: a binary string containing the question to be answered
  - `opts`: a keyword list of options to configure the API request

  ## Returns:
  - `{:ok, binary()}`: the best completion for the given question
  - `{:error, any()}`: an error message in the case of failure

  ## Example:

  ```elixir
  iex> WiseGPTEx.get_best_completion("What is the capital of France?")
  {:ok, "Paris"}
  ```

  ## Options:
  The function accepts the following options:

  - `:model` - The name of the model to use (default: "gpt-3.5-turbo"). All OpenAI models are supported.
  - `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
  - `:num_completions` - The number of completions to generate (default: 3).
  - `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 300_000 ms, or 5 minutes).
  """
  @spec get_best_completion(binary(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def get_best_completion(_question, _opts \\ [])

  def get_best_completion(question, opts) when is_binary(question) do
    with {:ok, completions} <-
           OpenAIHTTPClient.get_completions_with_reasoning(question, opts),
         {:ok, best_completion_info} <-
           OpenAIHTTPClient.get_best_completion(question, completions, opts),
         {:ok, best_completion} <- pick_best_completion(completions, best_completion_info) do
      {:ok, best_completion}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_best_completion(_question, _opts), do: {:error, "the input must be a string"}

  defp pick_best_completion([first_completion | _] = completions, best_completion_info) do
    with %{"index" => index_str} <-
           Regex.named_captures(
             ~r/correct\s+answer:\s+(option\s+)?(?<index>\d+)/i,
             best_completion_info
           ),
         {index, _} <- Integer.parse(index_str),
         best_completion <- Enum.at(completions, index - 1, first_completion) do
      {:ok, best_completion}
    else
      _ ->
        # if we can't parse the index, just return the first completion
        {:ok, first_completion}
    end
  end

  @doc """
  `get_best_completion_with_resolver/2` is similar to `get_best_completion/2` but uses a secondary step to resolve the best completion among the options.

  This function will perform an additional API call to get a more accurate completion, which can be beneficial for complex or ambiguous queries.

  ## Params:
  - `question`: a binary string containing the question to be answered
  - `opts`: a keyword list of options to configure the API request

  ## Returns:
  - `{:ok, binary()}: the best completion for the given question
  - `{:error, any()}: an error message in the case of failure

  ## Example:
  ```elixir
  iex> WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?")
  {:ok, "Paris"}
  ```

  ## Options:
  The function accepts the following options:

  - `:model` - The name of the model to use (default: "gpt-3.5-turbo"). All OpenAI models are supported.
  - `:temperature - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
  - `:num_completions` - The number of completions to generate (default: 3).
  - `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 300_000 ms, or 5 minutes).
  """
  @spec get_best_completion_with_resolver(binary(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def get_best_completion_with_resolver(_question, _opts \\ [])

  def get_best_completion_with_resolver(question, opts) when is_binary(question) do
    with {:ok, completions} <-
           OpenAIHTTPClient.get_completions_with_reasoning(question, opts),
         {:ok, best_completion_info} <-
           OpenAIHTTPClient.get_best_completion(question, completions, opts),
         {:ok, best_completion} <- OpenAIHTTPClient.get_resolver_completion(question, completions, best_completion_info, opts) do
      {:ok, best_completion}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_best_completion_with_resolver(_question, _opts),
    do: {:error, "the input must be a string"}
end
