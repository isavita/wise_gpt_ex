defmodule WiseGPTEx do
  @moduledoc """
  Documentation for `WiseGPTEx`.

  This module provides functions to obtain the best completion from various language models including OpenAI (default: "gpt-4o-mini"), Anthropic, and Mistral, using their respective API endpoints.

  Key functions include `get_best_completion/2`, `get_best_completion_with_resolver/2`, `openai_completion/2`, `anthropic_completion/2`, and `mistral_completion/2`. Each function is tailored to interact with a specific API, offering a range of options for customizing the request and handling the response.

  ## Examples

  Basic usage:

      iex> WiseGPTEx.get_best_completion("What is the capital of France?")
      {:ok, "Paris"}

      iex> WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?")
      {:ok, "Paris"}

  Using a raw completion:

      iex> messages = [
      ...>   %{"role" => "system", "content" => "You are High School Geography Teacher"},
      ...>   %{"role" => "user", "content" => "What was the capital of France in 15th century?"}
      ...> ]
      ...> WiseGPTEx.openai_completion(messages)
      {:ok, "The capital of France in the 15th century was Paris."}

  Using all available options:

      iex> opts = [model: "gpt-4", temperature: 0.7, num_completions: 5, timeout: 3_600_000]
      iex> WiseGPTEx.get_best_completion("What is the capital of France?", opts)
      {:ok, "Paris"}

      iex> WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?", opts)
      {:ok, "Paris"}

  Note that the examples for the `get_best_completion_with_resolver/2` function are similar to `get_best_completion/2`.
  This is because the difference between these two functions is in the method of how they select the best completion, not in their usage or the nature of their inputs or outputs.
  The `get_best_completion_with_resolver/2` function will perform an additional API call to get a more accurate completion, which can be beneficial for complex or ambiguous queries.

  Anthropic API usage:

      iex> WiseGPTEx.anthropic_completion("Why is the sky blue?")
      {:ok, "The sky is blue because... [detailed explanation]"}

  Mistral API usage:
      iex> messages = "What is the best French cheese?"
      iex> WiseGPTEx.mistral_completion(messages)
      {:ok, "The best French cheese is..."}

  Groq API usage:
      iex> messages = [%{"role" => "user", "content" => "Hello, Groq!"}]
      iex> WiseGPTEx.groq_completion(messages)
      {:ok, "This is a test response from Groq."}

  For more detailed examples and options for each function, refer to the individual function documentation.

  ## Options

  The following options can be passed to the `get_best_completion/2` and `get_best_completion_with_resolver/2` functions:

    * `:model` - The name of the model to use (default: "gpt-4o-mini"). All OpenAI models are supported.
    * `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
    * `:num_completions` - The number of completions to generate (default: 3).
    * `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 3_600_000 ms, or 60 minutes).

  For `anthropic_completion/2`, the following options can be passed:

    * `:model` - The version of the Claude model to use (default: "claude-2").
    * `:temperature` - Controls the randomness of the model's output (default: 0.1).
    * `:max_tokens_to_sample` - Maximum number of tokens to generate (default: 100,000).
    * `:timeout` - Maximum time in milliseconds to wait for a response (default: 3,600,000 ms, or 60 minutes).

  """
  alias WiseGPTEx.AnthropicHTTPClient
  alias WiseGPTEx.MistralHTTPClient
  alias WiseGPTEx.OpenAIHTTPClient
  alias WiseGPTEx.OpenAIUtils
  alias WiseGPTEx.GroqHTTPClient

  @doc """
  Gets a raw completion from the OpenAI API without additional prompting.

  ## Params:
  - `messages`: A list of messages to send to the API. Each message should be a map with keys "role" and "content", for example:
  ```elixir
      iex> messages = [
      ...>   %{"role" => "system", "content" => "You are High School Geography Teacher"},
      ...>   %{"role" => "user", "content" => "What was the capital of France in 15th century?"}
      ...> ]
  ```
  - `opts`: a keyword list of options to configure the API request

  ## Returns:
  - `{:ok, binary()}`: the completion for the given question
  - `{:error, any()}`: an error message in the case of failure

  This allows you to customize the conversation sent to the API without any additional prompting added.

  ## Example:

  ```elixir
      iex> messages = [
      ...>   %{"role" => "system", "content" => "You are High School Geography Teacher"},
      ...>   %{"role" => "user", "content" => "What was the capital of France in 15th century?"}
      ...> ]
      ...> WiseGPTEx.openai_completion(messages)
      {:ok, "The capital of France in the 15th century was Paris."}
  ```
  """
  @spec openai_completion(list(map()), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def openai_completion(messages, opts \\ []) do
    OpenAIHTTPClient.completion(messages, opts)
  end

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

  - `:model` - The name of the model to use (default: "gpt-4o-mini"). All OpenAI models are supported.
  - `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
  - `:num_completions` - The number of completions to generate (default: 3).
  - `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 3_600_000 ms, or 60 minutes).
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

  - `:model` - The name of the model to use (default: "gpt-4o-mini"). All OpenAI models are supported.
  - `:temperature - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
  - `:num_completions` - The number of completions to generate (default: 3).
  - `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 3_600_000 ms, or 60 minutes).
  """
  @spec get_best_completion_with_resolver(binary(), Keyword.t()) ::
          {:ok, binary()} | {:error, any()}
  def get_best_completion_with_resolver(_question, _opts \\ [])

  def get_best_completion_with_resolver(question, opts) when is_binary(question) do
    with {:ok, completions} <-
           OpenAIHTTPClient.get_completions_with_reasoning(question, opts),
         {:ok, best_completion_info} <-
           OpenAIHTTPClient.get_best_completion(question, completions, opts),
         {:ok, best_completion} <-
           OpenAIHTTPClient.get_resolver_completion(
             question,
             completions,
             best_completion_info,
             opts
           ),
         best_completion_trimmed <- OpenAIUtils.trim_resolver_answer(best_completion) do
      {:ok, best_completion_trimmed}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_best_completion_with_resolver(_question, _opts),
    do: {:error, "the input must be a string"}

  @doc """
  Retrieves a completion from the Anthropic API using the Claude model.

  ## Params:
  - `message`: A string containing the prompt or question.
  - `opts`: A keyword list of options to configure the API request.

  ## Returns:
  - `{:ok, binary()}`: The completion for the given prompt.
  - `{:error, any()}`: An error message in case of failure.

  This function provides a direct way to interact with the Anthropic API, allowing for detailed control over the completion request.

  ## Example:

  ```elixir
  iex> WiseGPTEx.anthropic_completion("Why is the sky blue?")
  {:ok, "The sky is blue because... [detailed explanation]"}
  ```
  """
  @spec anthropic_completion(binary(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def anthropic_completion(message, opts \\ []) do
    AnthropicHTTPClient.complete(message, opts)
  end

  @doc """
  Retrieves a completion from the Mistral API.

  ## Params
  - `messages`: A list of messages forming the conversation context for the completion. Each message should be a map with keys "role" (either 'user' or 'system') and "content" for the text.
  - `opts`: A keyword list of options to configure the API request. Options include `:model`, `:temperature`, `:top_p`, `:max_tokens`, `:stream`, `:safe_mode`, and `:random_seed`.

  ## Returns
  - `{:ok, binary()}`: The completion for the given context.
  - `{:error, any()}`: An error message in case of failure.

  ## Example
  ```elixir
  iex> message = "What is the best French cheese?"
  iex> WiseGPTEx.mistral_completion(message)
  {:ok,"It's difficult to declare one type of French cheese as the \"best\" since preferences for cheese can vary greatly from person to person. However, some of the most well-known and highly regarded French cheeses include Brie, Camembert, Comté, Roquefort, and Époisses. Ultimately, the best French cheese is a matter of personal taste."}
  """
  @spec mistral_completion(binary(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def mistral_completion(message, opts \\ []) do
    MistralHTTPClient.complete(message, opts)
  end

  @doc """
  Retrieves a completion from the Groq API.

  ## Params
  - `messages`: A list of messages forming the conversation context for the completion.
  - `opts`: A keyword list of options to configure the API request.

  ## Returns
  - `{:ok, binary()}`: The completion for the given context.
  - `{:error, any()}`: An error message in case of failure.

  ## Example
  ```elixir
  iex> messages = [%{"role" => "user", "content" => "Hello, Groq!"}]
  iex> WiseGPTEx.groq_completion(messages)
  {:ok, "This is a test response from Groq."}
  """
  @spec groq_completion(list(map()), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def groq_completion(messages, opts \\ []) do
    GroqHTTPClient.complete(messages, opts)
  end
end
