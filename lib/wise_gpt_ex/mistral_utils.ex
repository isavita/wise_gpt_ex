defmodule WiseGPTEx.MistralUtils do
  @moduledoc """
  Provides utility functions for processing responses from the Mistral API.
  """

  @doc ~S"""
  Extracts the completion from the response body of the Mistral API.

  This function parses the response from the API, focusing on extracting the 'content' field. It handles both successful and error responses, returning a string that represents the completion or an error message.

  In the case of successful responses, it returns the 'content' field's content. For error responses, it returns a formatted error message.

  ## Examples

  Successful response:
      iex> response = %{
      ...> "choices" => [
      ...>   %{
      ...>      "finish_reason" => "stop",
      ...>      "index" => 0,
      ...>      "message" => %{
      ...>         "content" => "As CO2eFoodGPT, I help you understand the carbon footprint of your recipes and food items. I analyze major contributors to greenhouse gas emissions and provide estimates for missing data. My goal is to offer transparency, enabling you to make informed decisions about your food choices and their environmental impact. I provide clear explanations, highlight key emission sources, and ensure honesty when uncertainty arises. Trust me to be your guide in exploring the carbon footprint of your meals.",
      ...>         "role" => "assistant"
      ...>      }
      ...>   }
      ...> ],
      ...> "created" => 1702812391,
      ...> "id" => "cmpl-63a74b88dca34452be729117c9304948",
      ...> "model" => "mistral-small",
      ...> "object" => "chat.completion",
      ...> "usage" => %{"completion_tokens" => 99, "prompt_tokens" => 291, "total_tokens" => 390}
      ...> }
      ...> WiseGPTEx.MistralUtils.extract_completion(response)
      "As CO2eFoodGPT, I help you understand the carbon footprint of your recipes and food items. I analyze major contributors to greenhouse gas emissions and provide estimates for missing data. My goal is to offer transparency, enabling you to make informed decisions about your food choices and their environmental impact. I provide clear explanations, highlight key emission sources, and ensure honesty when uncertainty arises. Trust me to be your guide in exploring the carbon footprint of your meals."

  Error response:
      iex> error_response = %{
      ...>   "message" => "No API key found in request",
      ...>   "request_id" => "63798e646813837a34d2f523f145bc10"
      ...> }
      ...> WiseGPTEx.MistralUtils.extract_completion(error_response)
      "Error: %{\"message\" => \"No API key found in request\", \"request_id\" => \"63798e646813837a34d2f523f145bc10\"}"
  """
  @spec extract_completion(map()) :: binary()
  def extract_completion(%{"choices" => choices}) do
    choice =
      Enum.find(choices || [], %{}, fn completion ->
        completion["finish_reason"] == "stop"
      end)

    get_in(choice, ["message", "content"])
  end

  def extract_completion(error), do: "Error: #{inspect(error)}"
end
