defmodule WiseGPTEx do
  @moduledoc """
  Documentation for `WiseGPTEx`.
  """

  alias WiseGPTEx.OpenAIHTTPClient

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
end
