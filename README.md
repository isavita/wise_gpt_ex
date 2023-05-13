# WiseGPTEx

WiseGPTEx is an Elixir library that utilizes OpenAI's GPT-3.5-turbo model to provide intelligent question answering and reasoning capabilities.

## Installation

1. Add `wise_gpt_ex` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:wise_gpt_ex, "~> 0.3.0"}
  ]
end
```

2. Add the OpenAI API key to your configuration file (e.g., config/config.exs):
```elixir
config :wise_gpt_ex, :openai_api_key, "your_openai_api_key"
```

## Usage

To use WiseGPTEx, simply call the `get_best_completion/2` or `get_best_completion_with_resolver/2` function with a question and optional list of options:
```elixir
{:ok, response} = WiseGPTEx.get_best_completion("What is the capital of France?")
```

You can also pass options to customize the API request:
```elixir
opts = [model: "gpt-4", temperature: 0.4, num_completions: 4, timeout: 3_600_000]
{:ok, response} = WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?", opts)
```

Note that the `get_best_completion_with_resolver/2` function is similar to `get_best_completion/2`.
This is because the difference between these two functions is in the method of how they select the best completion, not in their usage or the nature of their inputs or outputs.
The `get_best_completion_with_resolver/2` function will perform an additional API call to get a more accurate completion, which can be beneficial for complex or ambiguous queries.

## Options
The following options can be passed to the `get_best_completion/2` function:

- `:model` - The name of the OpenAI model to use (default: "gpt-3.5-turbo").
- `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
- `:num_completions` - The number of completions to generate (default: 3).
- `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 3_600_000 ms, or 60 minutes).
