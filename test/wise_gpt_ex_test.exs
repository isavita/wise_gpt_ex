defmodule WiseGPTExTest do
  use ExUnit.Case, async: true

  import Mox
  setup :verify_on_exit!

  describe "get_best_completion/2" do
    @get_completions_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX1\",\"object\":\"chat.completion\",\"created\":1683578704,\"model\":\"gpt-4-0314\",\"usage\":{\"prompt_tokens\":98,\"completion_tokens\":296,\"total_tokens\":394},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counter-clockwise.\\nStep 3: Since gear 2 is engaged with gear 1, gear 1 will rotate clockwise.\\nStep 4: Since gear 1 is engaged with gear 7, gear 7 will rotate counter-clockwise.\\n\\nSo, gear 7 would rotate counter-clockwise.\"},\"finish_reason\":\"stop\",\"index\":0},{\"message\":{\"role\":\"assistant\",\"content\":\"If gear 3 rotates clockwise, then gear 4 (which is engaged with gear 3) would rotate counterclockwise.\\n\\nNext, gear 5 (which is engaged with gear 4) would rotate clockwise since gear 4 is rotating counterclockwise.\\n\\nSimilarly, gear 6 (which is engaged with gear 5) would rotate counterclockwise since gear 5 is rotating clockwise.\\n\\nFinally, gear 7 (which is engaged with gear 6) would rotate clockwise since gear 6 is rotating counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":1},{\"message\":{\"role\":\"assistant\",\"content\":\"Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counterclockwise.\\nStep 3: Gear 2 is engaged with gear 1, so gear 1 will rotate clockwise.\\nStep 4: Gear 1 is engaged with gear 7, so gear 7 will rotate counterclockwise.\\n\\nAnswer: Gear 7 would rotate counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":2}]}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body:
          "{\"messages\":[{\"content\":\"Question: 7 axles are equally spaced in a circle. a gear is placed on each axle such that each gear is engaged with the gear to its left and the gear to its right. the gears are numbered 1 to 7 around the circle. If gear 3 were rotated clockwise, in which direction would gear 7 rotate?\\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.\",\"role\":\"user\"}],\"model\":\"gpt-4\",\"n\":3,\"temperature\":0.5}",
        params: %{},
        options: []
      }
    }
    @get_best_completion_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX2\",\"object\":\"chat.completion\",\"created\":1683579016,\"model\":\"gpt-4-0314\",\"usage\":{\"prompt_tokens\":862,\"completion_tokens\":154,\"total_tokens\":1016},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Correct Answer: Option 1\\n\\nFlaws and faulty logic in other answer options:\\n\\nAnswer Option 2:\\n- This option starts with gear 3 rotating clockwise and then moves to gear 4, which is not directly engaged with gear 7. This method of working through the gears does not directly help in determining the rotation of gear 7.\\n- The final statement of this option contradicts itself, stating that gear 7 would rotate clockwise when it should be counterclockwise based on the previous steps.\\n\\nAnswer Option 3:\\n- There are no flaws or faulty logic in this option, but it is essentially the same as Answer Option 1, just with slightly different wording. It arrives at the correct answer of gear 7 rotating counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n",
      headers: [],
      request_url: "https://api.openai.com/v1/chat/completions",
      request: %HTTPoison.Request{
        method: :post,
        url: "https://api.openai.com/v1/chat/completions",
        headers: [],
        body:
          "{\"messages\":[{\"content\":\"Question: 7 axles are equally spaced in a circle. a gear is placed on each axle such that each gear is engaged with the gear to its left and the gear to its right. the gears are numbered 1 to 7 around the circle. If gear 3 were rotated clockwise, in which direction would gear 7 rotate?\\nAnswer: Let's work this out in a step by step way to be sure we have the right answer.\",\"role\":\"user\"},{\"content\":\"Answer Option 1: Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counter-clockwise.\\nStep 3: Since gear 2 is engaged with gear 1, gear 1 will rotate clockwise.\\nStep 4: Since gear 1 is engaged with gear 7, gear 7 will rotate counter-clockwise.\\n\\nSo, gear 7 would rotate counter-clockwise.\\nAnswer Option 2: If gear 3 rotates clockwise, then gear 4 (which is engaged with gear 3) would rotate counterclockwise.\\n\\nNext, gear 5 (which is engaged with gear 4) would rotate clockwise since gear 4 is rotating counterclockwise.\\n\\nSimilarly, gear 6 (which is engaged with gear 5) would rotate counterclockwise since gear 5 is rotating clockwise.\\n\\nFinally, gear 7 (which is engaged with gear 6) would rotate clockwise since gear 6 is rotating counterclockwise.\\nAnswer Option 3: Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counterclockwise.\\nStep 3: Gear 2 is engaged with gear 1, so gear 1 will rotate clockwise.\\nStep 4: Gear 1 is engaged with gear 7, so gear 7 will rotate counterclockwise.\\n\\nAnswer: Gear 7 would rotate counterclockwise.\",\"role\":\"assistant\"},{\"content\":\"7 axles are equally spaced in a circle. a gear is placed on each axle such that each gear is engaged with the gear to its left and the gear to its right. the gears are numbered 1 to 7 around the circle. If gear 3 were rotated clockwise, in which direction would gear 7 rotate?\\n\\nAnswer Option 1: Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counter-clockwise.\\nStep 3: Since gear 2 is engaged with gear 1, gear 1 will rotate clockwise.\\nStep 4: Since gear 1 is engaged with gear 7, gear 7 will rotate counter-clockwise.\\n\\nSo, gear 7 would rotate counter-clockwise.\\nAnswer Option 2: If gear 3 rotates clockwise, then gear 4 (which is engaged with gear 3) would rotate counterclockwise.\\n\\nNext, gear 5 (which is engaged with gear 4) would rotate clockwise since gear 4 is rotating counterclockwise.\\n\\nSimilarly, gear 6 (which is engaged with gear 5) would rotate counterclockwise since gear 5 is rotating clockwise.\\n\\nFinally, gear 7 (which is engaged with gear 6) would rotate clockwise since gear 6 is rotating counterclockwise.\\nAnswer Option 3: Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counterclockwise.\\nStep 3: Gear 2 is engaged with gear 1, so gear 1 will rotate clockwise.\\nStep 4: Gear 1 is engaged with gear 7, so gear 7 will rotate counterclockwise.\\n\\nAnswer: Gear 7 would rotate counterclockwise.\\n\\nYou are researcher tasked with investigating the answer options provided. List the flaws and faulty logic of each answer option. Let's work this out in a step by step way to be sure we have all the errors\\n\\n**Answer format:**\\nCorrect Answer: <Option Number>\\n**If there are multiple correct answers, pick the first one.**\",\"role\":\"user\"}],\"model\":\"gpt-4\",\"temperature\":0.5}",
        params: %{},
        options: []
      }
    }
    test "returns the best completion based on success_resp" do
      expect(HTTPoison.BaseMock, :post!, fn _url,
                                            "{\"messages\":[{\"content\":\"Question: ..." <> _ =
                                              payload,
                                            _headers,
                                            _opts ->
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-4"
        assert payload["temperature"] == 0.4
        assert payload["n"] == 4

        @get_completions_resp
      end)

      expect(HTTPoison.BaseMock, :post!, fn _url, payload, _headers, _opts ->
        assert {:ok, payload} = Jason.decode(payload)
        assert payload["model"] == "gpt-4"
        assert payload["temperature"] == 0.4
        refute payload["n"]

        @get_best_completion_resp
      end)

      assert {:ok, "" <> _comp} =
               WiseGPTEx.get_best_completion("...",
                 model: "gpt-4",
                 temperature: 0.4,
                 num_completions: 4
               )
    end

    @error_resp %HTTPoison.Response{
      status_code: 401,
      body:
        "{\n    \"error\": {\n        \"message\": \"Incorrect API key provided: sk-XXX. You can find your API key at https://platform.openai.com/account/api-keys.\",\n        \"type\": \"invalid_request_error\",\n        \"param\": null,\n        \"code\": \"invalid_api_key\"\n    }\n}\n",
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

    test "handles error response" do
      expect(HTTPoison.BaseMock, :post!, fn _url, _payload, _headers, _opts ->
        @error_resp
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
              }} = WiseGPTEx.get_best_completion("...")
    end
  end

  describe "get_best_completion_with_resolver" do
    @get_resolver_completion_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX4\",\"object\":\"chat.completion\",\"created\":1683648350,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":2195,\"completion_tokens\":161,\"total_tokens\":2356},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Answer Option 1 and 2 are incorrect,\\n\\n<|answerstart|>Therefore, 456 multiplied by 23421 equals 10,649,876.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n",
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

    test "returns the completion given by the resolver" do
      expect(HTTPoison.BaseMock, :post!, fn _url,
                                            "{\"messages\":[{\"content\":\"Question: " <> _ =
                                              _payload,
                                            _headers,
                                            _opts ->
        @get_completions_resp
      end)

      expect(HTTPoison.BaseMock, :post!, fn _url, _payload, _headers, _opts ->
        @get_best_completion_resp
      end)

      expect(HTTPoison.BaseMock, :post!, fn _url, _payload, _headers, _opts ->
        @get_resolver_completion_resp
      end)

      {:ok, "Therefore, 456 multiplied by 23421 equals 10,649,876."} =
        WiseGPTEx.get_best_completion_with_resolver("", model: "gpt-3.5-turbo-0301")
    end
  end
end
