# WiseGPTEx

WiseGPTEx is an Elixir library that integrates with various language models, including OpenAI's GPT-3.5-turbo, Anthropic's Claude model, and Mistral's AI model. It provides intelligent question answering, reasoning capabilities, and AI-generated text completions across these platforms.

## Installation

1. Add `wise_gpt_ex` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [
    {:wise_gpt_ex, "~> 0.7.0"}
  ]
end
```

2. Add the OpenAI, Anthropic, and Mistral API keys to your configuration file (e.g., config/config.exs):
```elixir
config :wise_gpt_ex, :openai_api_key, "your_openai_api_key"
config :wise_gpt_ex, :anthropic_api_key, "your_anthropic_api_key"
config :wise_gpt_ex, :mistral_api_key, "your_mistral_api_key"
```

## Usage (only with OpenAI API)

To use WiseGPTEx, simply call the `get_best_completion/2` or `get_best_completion_with_resolver/2` function with a question and optional list of options:
```elixir
{:ok, response} = WiseGPTEx.get_best_completion("What is the capital of France?")
```

You can also pass options to customize the API request:
```elixir
opts = [model: "gpt-4", temperature: 0.4, num_completions: 4, timeout: 3_600_000]
{:ok, response} = WiseGPTEx.get_best_completion_with_resolver("What is the capital of France?", opts)
```

You can also make a raw call to the OpenAI API using the `openai_completion/2` function:
```elixir
messages = [
  %{"role" => "system", "content" => "You are High School Geography Teacher"},
  %{"role" => "user", "content" => "What was the capital of France in 15th century?"}
]
{ok, response} = WiseGPTEx.openai_completion(messages, [model: "gpt-4", temperature: 0.75, timeout: 3_600])
```

Note that the `get_best_completion_with_resolver/2` function is similar to `get_best_completion/2`.
This is because the difference between these two functions is in the method of how they select the best completion, not in their usage or the nature of their inputs or outputs.
The `get_best_completion_with_resolver/2` function will perform an additional API call to get a more accurate completion, which can be beneficial for complex or ambiguous queries.
The `openai_completion/2` function allows sending a custom conversation to the API without any additional prompting or setting the up the system role etc. This is useful when you want direct access to the model's system messages.

## OpenAI API
For interactions with the OpenAI API, use the `openai_completion/1` function:
```elixir
{:ok, response} = WiseGPTEx.openai_completion("What is the capital of France?")
{:ok, "Paris"}
```
## Anthropic API
For interactions with the Anthropic API, use the `anthropic_completion/1` function:
```elixir
{:ok, response} = WiseGPTEx.anthropic_completion("Why is the sky blue?")
{:ok, "The sky is blue because of the way sunlight interacts with Earth's atmosphere."}
```
## Mistral API
For interactions with the Mistral API, use the `mistral_completion/1` function:
```elixir
{:ok, response} = WiseGPTEx.mistral_completion("What is the best French cheese?")
{:ok, "The best French cheese is..."}
```

## Options

### Options for the OpenAI API functions:

- `:model` - The name of the OpenAI model to use (default: "gpt-3.5-turbo").
- `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
- `:num_completions` - The number of completions to generate (default: 3).
- `:timeout` - The maximum time in milliseconds to wait for a response from the OpenAI API (default: 3_600_000 ms, or 60 minutes).

### Options for the Anthropic API function:

- `:model` - The version of the Claude model to use (default: "claude-2").
- `:temperature` - Controls the randomness of the model's output (default: 0.1).
- `:max_tokens_to_sample` - Maximum number of tokens to generate (default: 100,000).
- `:timeout` - Maximum time in milliseconds to wait for a response (default: 3,600,000 ms, or 60 minutes).

## Options for the Mistral API function:

- `:model` - The version of the Mistral model to use (default: "mistral-small").
- `:temperature` - Controls the randomness of the model's output. Higher values result in more diverse responses (default: 0.5).
- `:top_p` - Nucleus sampling parameter, controlling the token selection process (default: 1).
- `:max_tokens` - The maximum number of tokens to generate for the completion (default: 32,000).
- `:stream` - Whether to stream back partial progress of the completion (default: false).
- `:safe_mode` - Whether to enable content moderation features (default: false).
- `:random_seed` - An optional seed for deterministic results (default: nil).
- `:timeout` - Maximum time in milliseconds to wait for a response (default: 600,000 ms, or 10 minutes).
