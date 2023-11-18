defmodule WiseGPTEx.AnthropicUtils do
  @moduledoc """
  Provides utility functions for processing responses from the Anthropic API.
  """

  @doc ~S"""
  Extracts the completion from the response body of the Anthropic API.

  This function parses the response from the API, focusing on extracting the 'completion' field. It handles both successful and error responses, returning a string that represents the completion or an error message.

  In the case of successful responses, it returns the 'completion' field's content. For error responses, it returns a formatted error message.

  ## Examples

  Successful response:
      iex> response = %{
      ...>   "completion" => " Okay, let's solve this step-by-step:\n42 * 38\n= 42 * (30 + 8) \n= 42 * 30 + 42 * 8\n= 1260 + 336\n= 1596.",
      ...>   "stop_reason" => "stop_sequence",
      ...>   "model" => "claude-2.0",
      ...>   "stop" => "\n\nHuman:",
      ...>   "log_id" => "00c6b4ba97de04c5329dc50c0124e4814dfc3252d751afd55bcfaad44023be6d"
      ...> }
      ...> WiseGPTEx.AnthropicUtils.extract_complete(response)
      " Okay, let's solve this step-by-step:\n42 * 38\n= 42 * (30 + 8) \n= 42 * 30 + 42 * 8\n= 1260 + 336\n= 1596."

  Error response:
      iex> error_response = %{
      ...>   "error" => %{
      ...>     "type" => "not_found_error",
      ...>     "message" => "Not found"
      ...>   }
      ...> }
      ...> WiseGPTEx.AnthropicUtils.extract_complete(error_response)
      "Error: %{\"message\" => \"Not found\", \"type\" => \"not_found_error\"}"
  """
  @spec extract_complete(map()) :: binary()
  def extract_complete(%{"error" => error}), do: "Error: #{inspect(error)}"

  def extract_complete(body) do
    if body["stop"] == "\n\nHuman:" do
      body["completion"]
    else
      "NOT COMPLETED"
    end
  end
end
