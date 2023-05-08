defmodule WiseGPTEx.OpenAIHTTPClient do
  @moduledoc """
  Documentation for `WiseGPTEx.OpenAIHTTPClient`.

  This module contains functions to interact with the OpenAI API to get completions with reasoning and determine the best completion. It is used internally by the `WiseGPTEx` module and is not intended to be called directly by users.

  The main functions in this module are:

    * `get_completions_with_reasoning/2` - Retrieves completions with reasoning from the OpenAI API based on a given message and an optional list of options.
    * `get_best_completion/3` - Determines the best completion from a list of completions and an optional list of options.

  """
  @openai_completions_api_url "https://api.openai.com/v1/chat/completions"
  @default_model "gpt-3.5-turbo"
  @default_temperature 0.5
  @default_num_completions 3
  # 5 minutes
  @default_timeout_ms 300_000

  @spec get_completions_with_reasoning(binary(), Keyword.t()) :: {:ok, list()} | {:error, map()}
  def get_completions_with_reasoning(message, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    n = Keyword.get(opts, :num_completions, @default_num_completions)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    content = prepare_content_with_reasoning(message)

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

    case http_client().post!(@openai_completions_api_url, payload, headers(),
           recv_timeout: timeout
         ) do
      %{status_code: 200, body: body} -> {:ok, body |> Jason.decode!() |> extract_completions()}
      %{body: body} -> {:error, Jason.decode!(body)}
    end
  end

  defp prepare_content_with_reasoning(message) do
    ~s(Question: #{message}\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.)
  end

  defp extract_completions(body) do
    for completion <- body["choices"] || [], completion["finish_reason"] == "stop" do
      completion["message"]["content"]
    end
  end

  @spec get_best_completion(binary(), list(), Keyword.t()) :: {:ok, binary()} | {:error, any()}
  def get_best_completion(message, completions, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    temperature = Keyword.get(opts, :temperature, @default_temperature)
    timeout = Keyword.get(opts, :timeout, @default_timeout_ms)
    message_with_reasoning = prepare_content_with_reasoning(message)

    completions_with_reasoning =
      completions
      |> prepare_completion_options()
      |> Enum.join("\n")

    researcher_prompt = prepare_researcher_prompt(message, completions_with_reasoning)

    payload =
      %{
        "model" => model,
        "temperature" => temperature,
        "messages" => [
          %{"role" => "user", "content" => message_with_reasoning},
          %{"role" => "assistant", "content" => completions_with_reasoning},
          %{"role" => "user", "content" => researcher_prompt}
        ]
      }
      |> Jason.encode!()

    case http_client().post!(@openai_completions_api_url, payload, headers(),
           recv_timeout: timeout
         ) do
      %{status_code: 200, body: body} ->
        {:ok, body |> Jason.decode!() |> extract_best_completion()}

      %{body: body} ->
        {:error, Jason.decode!(body)}
    end
  end

  defp prepare_researcher_prompt(message, completions_with_reasoning) do
    ~s(#{message}\n\n#{completions_with_reasoning}\n\nYou are researcher tasked with investigating the answer options provided. List the flaws and faulty logic of each answer option. Let's work this out in a step by step way to be sure we have all the errors\n\n**Answer format:**\nCorrect Answer: <Option Number>\n**If there are multiple correct answers, pick the first one.**)
  end

  defp extract_best_completion(body) do
    choice =
      Enum.find(body["choices"] || [], %{}, fn completion ->
        completion["finish_reason"] == "stop"
      end)

    choice["message"]["content"]
  end

  defp prepare_completion_options(completions) do
    for {completion, i} <- Enum.with_index(completions, 1) do
      ~s(Answer Option #{i}: #{completion})
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
