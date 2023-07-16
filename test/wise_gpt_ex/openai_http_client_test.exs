defmodule WiseGPTEx.OpenAIHTTPClientTest do
  use ExUnit.Case, async: true

  alias WiseGPTEx.OpenAIHTTPClient

  import Mox
  setup :verify_on_exit!

  describe "get_raw_completion/1" do
    @success_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\n  \"id\": \"chatcmpl-7ctGZpJTEEGq8XfzwpWRF8Ph1e0ZA\",\n  \"object\": \"chat.completion\",\n  \"created\": 1689503263,\n  \"model\": \"gpt-3.5-turbo-0613\",\n  \"choices\": [\n    {\n      \"index\": 0,\n      \"message\": {\n        \"role\": \"assistant\",\n        \"content\": \"The capital of France in the 15th century was Paris.\"\n      },\n      \"finish_reason\": \"stop\"\n    }\n  ],\n  \"usage\": {\n    \"prompt_tokens\": 29,\n    \"completion_tokens\": 13,\n    \"total_tokens\": 42\n  }\n}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body:
          "{\"messages\":[{\"content\":\"You are High School Geography Teacher\",\"role\":\"system\"},{\"content\":\"What was the capital of France in 15th century?\",\"role\":\"user\"}],\"model\":\"gpt-3.5-turbo\",\"temperature\":0.5}",
        params: %{},
        options: []
      }
    }
    test "returns the completion" do
      messages = [
        %{"role" => "system", "content" => "You are High School Geography Teacher"},
        %{"role" => "user", "content" => "What was the capital of France in 15th century?"}
      ]

      expect(HTTPoison.BaseMock, :post!, fn url, payload, headers, _opts ->
        assert url == "https://api.openai.com/v1/chat/completions"
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-3.5-turbo"
        assert payload["temperature"] == 0.5
        assert payload["messages"] == messages

        assert Enum.any?(headers, fn
                 {"authorization", "Bearer " <> _} -> true
                 _ -> false
               end)

        @success_resp
      end)

      assert {:ok, completion} = OpenAIHTTPClient.get_raw_completion(messages)
      assert completion == "The capital of France in the 15th century was Paris."
    end
  end

  describe "get_completions_with_reasoning/1" do
    @success_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX1\",\"object\":\"chat.completion\",\"created\":1683498123,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":38,\"completion_tokens\":960,\"total_tokens\":998},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"First, we multiply 6 (the ones place of 456) by 1 (the ones place of 23421) to get 6.\\n\\nNext, we multiply 5 (the tens place of 456) by 1 to get 5.\\n\\nThen, we multiply 4 (the hundreds place of 456) by 1 to get 4.\\n\\nNow, we move to the next digit in 23421, which is the tens place. We multiply 6 by 2 (the tens place of 23421) to get 12. We write down the 2 and carry the 1 over to the next step.\\n\\nNext, we multiply 5 by 2 and add the carried over 1 to get 11. We write down the 1 and carry over the other 1.\\n\\nMoving on to the next digit in 23421, we multiply 4 by 2 and add the carried over 1 to get 9.\\n\\nNow, we move to the next digit in 23421, which is the hundreds place. We multiply 6 by 3 (the hundreds place of 23421) to get 18. We write down the 8 and carry the 1 over to the next step.\\n\\nNext, we multiply 5 by 3 and add the carried over 1 to get 16. We write down the 6 and carry over the 1.\\n\\nMoving on to the next digit in 23421, we multiply 4 by 3 and add the carried over 1 to get 13. We write down the 3 and carry over the 1.\\n\\nFinally, we multiply 2 by 3 (the thousands place of 23421) to get 6. We write down the 6.\\n\\nNow, we add up all the products we wrote down: 6 + 5 + 4 + 12 + 1 + 9 + 8 + 6 + 3 = 54,456.\\n\\nTherefore, 456 * 23421 = 54,456.\"},\"finish_reason\":\"stop\",\"index\":0},{\"message\":{\"role\":\"assistant\",\"content\":\"First, we can start by multiplying 6 (the ones digit of 456) by 1 (the ones digit of 23421), which gives us 6. We write down the 6 and carry over the 0.\\n\\nNext, we multiply 5 (the tens digit of 456) by 1, which gives us 5. We add the carried over 0 to get 50. We write down the 0 and carry over the 5.\\n\\nThen, we multiply 4 (the hundreds digit of 456) by 1, which gives us 4. We add the carried over 5 to get 45. We write down the 5 and carry over the 4.\\n\\nWe continue this process for each digit of 23421, multiplying it by each digit of 456 and carrying over as necessary. Once we have multiplied all the digits, we add up the results to get the final answer.\\n\\nAfter completing all the multiplication and addition, we get the answer: 10,686,876.\"},\"finish_reason\":\"stop\",\"index\":1},{\"message\":{\"role\":\"assistant\",\"content\":\"Step 1: Multiply 6 (the ones place of 456) by 1 (the ones place of 23421), which equals 6.\\n\\nStep 2: Multiply 5 (the tens place of 456) by 2 (the tens place of 23421), which equals 10. Write down the 0 and carry over the 1.\\n\\nStep 3: Multiply 4 (the hundreds place of 456) by 4 (the hundreds place of 23421), which equals 16. Write down the 6 and carry over the 1.\\n\\nStep 4: Multiply 6 (the ones place of 456) by 3 (the thousands place of 23421), which equals 18. Write down the 8 and carry over the 1.\\n\\nStep 5: Multiply 5 (the tens place of 456) by 2 (the ten thousands place of 23421), which equals 10. Write down the 0 and carry over the 1.\\n\\nStep 6: Multiply 4 (the hundreds place of 456) by 3 (the hundred thousands place of 23421), which equals 12. Write down the 2 and carry over the 1.\\n\\nStep 7: Add up all the partial products: 6, 0 (from step 2), 6 (from step 3), 8 (from step 4), 0 (from step 5), and 2 (from step 6). This equals 22.\\n\\nTherefore, 456 * 23421 = 10,670,676.\"},\"finish_reason\":\"stop\",\"index\":2}]}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body:
          "{\"messages\":[{\"content\":\"Question: 456 * 23421\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.\",\"role\":\"user\"}],\"model\":\"gpt-3.5-turbo\",\"temperature\":0.5}",
        params: %{},
        options: []
      }
    }
    test "makes request with correct params" do
      expect(HTTPoison.BaseMock, :post!, fn url, payload, headers, _opts ->
        assert url == "https://api.openai.com/v1/chat/completions"
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-3.5-turbo"
        assert payload["temperature"] == 0.5
        assert payload["n"] == 3

        assert Enum.any?(headers, fn
                 {"authorization", "Bearer " <> _} -> true
                 _ -> false
               end)

        assert payload["messages"] == [
                 %{
                   "role" => "user",
                   "content" =>
                     "Question: 456 * 23421\nAnswer: Let's work this out in a step by step way to be sure we have the right answer."
                 }
               ]

        @success_resp
      end)

      assert {:ok, [_comp1, _comp2, _comp3]} =
               OpenAIHTTPClient.get_completions_with_reasoning("456 * 23421")
    end

    @error_response %HTTPoison.Response{
      status_code: 401,
      body:
        "{\n    \"error\": {\n        \"message\": \"Incorrect API key provided: sk-XXX. You can find your API key at https://platform.openai.com/account/api-keys.\",\n        \"type\": \"invalid_request_error\",\n        \"param\": null,\n        \"code\": \"invalid_api_key\"\n    }\n}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body:
          "{\"messages\":[{\"content\":\"Question: 456 * 23421\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.\",\"role\":\"user\"}],\"model\":\"gpt-3.5-turbo\",\"n\":3,\"temperature\":0.5}",
        params: %{},
        options: []
      }
    }
    test "handles error response" do
      expect(HTTPoison.BaseMock, :post!, fn _url, _payload, _headers, _opts ->
        @error_response
      end)

      assert {:error,
              %{
                "error" => %{
                  "code" => "invalid_api_key",
                  "message" =>
                    "Incorrect API key provided: sk-XXX. You can find your API key at https://platform.openai.com/account/api-keys.",
                  "param" => nil,
                  "type" => "invalid_request_error"
                }
              }} = OpenAIHTTPClient.get_completions_with_reasoning("456 * 23421")
    end
  end

  describe "get_best_completion/2" do
    @success_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX2\",\"object\":\"chat.completion\",\"created\":1683537824,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":3229,\"completion_tokens\":324,\"total_tokens\":3553},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"As an AI language model, I cannot determine the intention of the question and the answer options provided. However, I can provide a general guideline on how to approach the problem and identify errors in the answer options.\\n\\nTo solve the problem of 456 * 23421, we can use the standard multiplication algorithm, which involves multiplying each digit of the second number (23421) by each digit of the first number (456) and adding the partial products. The correct answer is 10,672,776.\\n\\nHere are some possible errors and faulty logic in the answer options:\\n\\nAnswer Option 1:\\nThe answer option correctly uses the standard multiplication algorithm and obtains the correct partial products. However, the answer option adds the partial products incorrectly, which results in the wrong final answer of 10,678,976.\\n\\nAnswer Option 2:\\nThe answer option attempts to use a different method of multiplication, which involves multiplying each digit of the first number by each digit of the second number and adding the partial products. However, the answer option contains several errors in the calculations, which result in an incorrect final answer of 10,679,176.\\n\\nAnswer Option 3:\\nThe answer option attempts to use a variation of the standard multiplication algorithm, which involves multiplying each digit of the first number by each digit of the second number and writing down the partial products in a separate column. However, the answer option contains several errors in the calculations, which result in an incorrect final answer of 10,672,776.\\n\\nOverall, it is important to use the correct method of multiplication and perform the calculations accurately to obtain the correct answer.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body: "...",
        params: %{},
        options: []
      }
    }
    test "get_best_completion/2 returns the best completion based on success_resp" do
      expect(HTTPoison.BaseMock, :post!, fn url, payload, _headers, _opts ->
        assert url == "https://api.openai.com/v1/chat/completions"
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-3.5-turbo"
        assert payload["temperature"] == 0.5

        assert [
                 %{
                   "content" =>
                     "Question: 456 * 23421\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.",
                   "role" => "user"
                 },
                 %{
                   "content" => "Answer Option 1: A\nAnswer Option 2: B\nAnswer Option 3: C",
                   "role" => "assistant"
                 },
                 %{
                   "content" => "" <> _,
                   "role" => "user"
                 }
               ] = payload["messages"]

        @success_resp
      end)

      assert {:ok, "" <> _comp} =
               OpenAIHTTPClient.get_best_completion("456 * 23421", ["A", "B", "C"])
    end
  end

  describe "get_resolver_completion/3" do
    @get_resolver_completion %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX4\",\"object\":\"chat.completion\",\"created\":1683648350,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":2195,\"completion_tokens\":161,\"total_tokens\":2356},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Answer Option 1 and 2 are incorrect, as they solve a different problem involving the multiplication of 37 and 89122, not 456 and 23421. \\n\\nAnswer Option 3 is closer to the correct answer, but it contains errors in the partial products. To improve the answer, we can use the standard long multiplication algorithm, which is more efficient and less prone to errors. \\n\\nHere is the improved solution using the long multiplication algorithm:\\n\\n```\\n   456\\n x23421\\n -------\\n  31992  (6 x 1)\\n 364560  (5 x 56)\\n1822800  (4 x 421)\\n---------\\n10649876  (total)\\n```\\n\\nTherefore, 456 multiplied by 23421 equals 10,649,876.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body: "...",
        params: %{},
        options: []
      }
    }
    test "returns the best completion generated base on the previous completions" do
      expect(HTTPoison.BaseMock, :post!, fn url, payload, _headers, _opts ->
        assert url == "https://api.openai.com/v1/chat/completions"
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-3.5-turbo"
        assert payload["temperature"] == 0.5

        assert [
                 %{"content" => "" <> _, "role" => "user"},
                 %{"content" => "" <> _, "role" => "assistant"},
                 %{"content" => "" <> _, "role" => "user"},
                 %{"content" => "" <> _, "role" => "assistant"},
                 %{"content" => "You are a resolver " <> _, "role" => "user"}
               ] = payload["messages"]

        @get_resolver_completion
      end)

      assert {:ok, "" <> _comp} =
               OpenAIHTTPClient.get_resolver_completion(
                 "456 * 23421",
                 ["A", "B", "C"],
                 "Correct Answer: Option 2"
               )
    end
  end
end
