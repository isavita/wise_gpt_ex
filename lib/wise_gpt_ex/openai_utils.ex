defmodule WiseGPTEx.OpenAIUtils do
  @moduledoc """
  Provides facilities for processing some of the responses from third party APIs.
  """

  @doc ~S"""
  A function that takes a message and returns a prompt with a reasoning template.

  ## Example

      iex> WiseGPTEx.OpenAIUtils.reasoning_prompt("What is 2+2?")
      "Question: What is 2+2?\nAnswer: Let's work this out in a step by step way to be sure we have the right answer."
  """
  @spec reasoning_prompt(binary()) :: binary()
  def reasoning_prompt(message) do
    ~s(Question: #{message}\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.)
  end

  @doc ~S"""
  A function that takes a message and completions with reasoning, and returns a string prompt for a researcher.

  The researcher is tasked with investigating the answer options provided, listing the flaws and faulty logic of each answer option.

  ## Example

      iex> message = "What is the capital of France?"
      ...> completions_with_reasoning = "Option 1: Paris - This is the correct answer. Paris is the capital of France.\nOption 2: London - This is incorrect. London is the capital of the United Kingdom, not France."
      ...> WiseGPTEx.OpenAIUtils.researcher_prompt(message, completions_with_reasoning)
      "What is the capital of France?\n\nOption 1: Paris - This is the correct answer. Paris is the capital of France.\nOption 2: London - This is incorrect. London is the capital of the United Kingdom, not France.\n\nYou are researcher tasked with investigating the answer options provided. List the flaws and faulty logic of each answer option. Let's work this out in a step by step way to be sure we have all the errors\n\n**Answer format:**\nCorrect Answer: <Option Number>\n**If there are multiple correct answers, pick the first one.**"
  """
  @spec researcher_prompt(binary(), binary()) :: binary()
  def researcher_prompt(message, completions_with_reasoning) do
    ~s(#{message}\n\n#{completions_with_reasoning}\n\nYou are researcher tasked with investigating the answer options provided. List the flaws and faulty logic of each answer option. Let's work this out in a step by step way to be sure we have all the errors\n\n**Answer format:**\nCorrect Answer: <Option Number>\n**If there are multiple correct answers, pick the first one.**)
  end

  @doc ~S"""
  A simple function that returns a static string.
  This string serves as an instruction for a "resolver" role,
  outlining the tasks it needs to perform.

  These tasks include:

    1. Identifying the best answer from a set of options.
    2. Improving the selected answer.
    3. Printing the improved answer in its entirety.
    4. Adding a special marker to the beginning of the improved answer.

  The string also includes a statement encouraging a step-by-step approach
  to ensure the correct answer is found. This function doesn't take any arguments
  and always returns the same string.

  ## Example

      iex> WiseGPTEx.OpenAIUtils.resolver_prompt()
      "You are a resolver tasked with 1) finding which of the X answer options was best 2) improving that answer, 3) printing the improved answer in full, and 4) adding to the begining of the improved answer special marker <|answerstart|>. Let's work this out in step by step way to be sure we have the right answer:"

  """
  @spec resolver_prompt() :: binary()
  def resolver_prompt do
    ~s{You are a resolver tasked with 1) finding which of the X answer options was best 2) improving that answer, 3) printing the improved answer in full, and 4) adding to the begining of the improved answer special marker <|answerstart|>. Let's work this out in step by step way to be sure we have the right answer:}
  end

  @doc ~S"""
  A function that takes a list of completions and prepares them as answer options.
  Each option is prefixed with "Answer Option" followed by its index in the list, and all options are joined together with newline.

  ## Example

      iex> completions = ["PHP", "Elixir", "Go"]
      ...> WiseGPTEx.OpenAIUtils.prepare_completion_options(completions)
      "Answer Option 1: PHP\nAnswer Option 2: Elixir\nAnswer Option 3: Go"
  """
  @spec prepare_completion_options(list(binary())) :: binary()
  def prepare_completion_options(completions) do
    for {completion, i} <- Enum.with_index(completions, 1) do
      ~s(Answer Option #{i}: #{completion})
    end
    |> Enum.join("\n")
  end

  @doc ~S"""
  A function that extracts the resolver's answer from a string.
  The answer is expected to start within the special marker `<|answerstart|>`.
  If these markers are not found, the function returns the original string.

  ## Example

      iex> answer = "Some text before<|answerstart|>Hello"
      ...> WiseGPTEx.OpenAIUtils.trim_resolver_answer(answer)
      "Hello"
  """
  @spec trim_resolver_answer(binary()) :: binary()
  def trim_resolver_answer(answer) do
    case Regex.run(~r{<\|answerstart\|>(.*)}, answer) do
      [_, answer] -> answer
      _ -> answer
    end
  end

  @doc ~S"""
  A function that takes a list of completions and returns the content of all that finished.

  ## Example

      iex> body = %{
      ...>   "choices" => [
      ...>     %{
      ...>       "finish_reason" => "stop",
      ...>       "index" => 0,
      ...>       "message" => %{
      ...>         "content" => "First, 456 * 23421 = 54,456.",
      ...>         "role" => "assistant"
      ...>       }
      ...>     },
      ...>     %{
      ...>       "finish_reason" => "stop",
      ...>       "index" => 1,
      ...>       "message" => %{
      ...>         "content" => "Second, we get the answer: 10,686,876.",
      ...>         "role" => "assistant"
      ...>       }
      ...>     }
      ...>   ]
      ...> }
      ...> WiseGPTEx.OpenAIUtils.extract_completions(body)
      ["First, 456 * 23421 = 54,456.", "Second, we get the answer: 10,686,876."]

  """
  @spec extract_completions(map()) :: list(binary())
  def extract_completions(body) do
    for completion <- body["choices"] || [], completion["finish_reason"] == "stop" do
      completion["message"]["content"]
    end
  end

  @doc ~S"""
  A function that takes a list of completions and returns the content of the first one that finished.

  ## Example

      iex> body = %{
      ...>   "choices" => [
      ...>     %{
      ...>       "finish_reason" => "stop",
      ...>       "index" => 0,
      ...>       "message" => %{
      ...>         "content" => "Correct Answer: Option 1.",
      ...>         "role" => "assistant"
      ...>       }
      ...>     }
      ...>   ]
      ...> }
      ...> WiseGPTEx.OpenAIUtils.extract_completion(body)
      "Correct Answer: Option 1."

  """
  @spec extract_completion(map()) :: binary()
  def extract_completion(body) do
    choice =
      Enum.find(body["choices"] || [], %{}, fn completion ->
        completion["finish_reason"] == "stop"
      end)

    choice["message"]["content"]
  end
end
