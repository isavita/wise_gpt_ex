defmodule WiseGPTEx.GroqUtils do
  @moduledoc """
  Provides utility functions for processing responses from the Groq API.
  """

  @doc ~S"""
  Extracts the completion from the response body of the Groq API.

  This function parses the response from the API, focusing on extracting the 'content' field from the first choice. It handles both successful and error responses, returning a string that represents the completion or an error message.

  In the case of successful responses, it returns the 'content' field's content. For error responses, it returns a formatted error message.

  ## Examples

  Successful response:
      iex> response = %{
      ...>   "choices" => [
      ...>     %{
      ...>       "message" => %{
      ...>         "content" => "Low latency Large Language Models (LLMs) are important in the field of artificial intelligence and natural language processing (NLP) for several reasons: ..."
      ...>       }
      ...>     }
      ...>   ]
      ...> }
      ...> WiseGPTEx.GroqUtils.extract_completion(response)
      "Low latency Large Language Models (LLMs) are important in the field of artificial intelligence and natural language processing (NLP) for several reasons: ..."

  Error response:
      iex> error_response = %{
      ...>   "error" => %{
      ...>     "message" => "Invalid API key",
      ...>     "type" => "invalid_request_error",
      ...>     "param" => nil,
      ...>     "code" => nil
      ...>   }
      ...> }
      ...> WiseGPTEx.GroqUtils.extract_completion(error_response)
      "Error: %{\"error\" => %{\"code\" => nil, \"message\" => \"Invalid API key\", \"param\" => nil, \"type\" => \"invalid_request_error\"}}"
  """
  @spec extract_completion(map()) :: binary()
  def extract_completion(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    content
  end

  def extract_completion(error), do: "Error: #{inspect(error)}"
end
