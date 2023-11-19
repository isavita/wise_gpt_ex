defmodule WiseGPTExTest do
  use ExUnit.Case

  import Mock

  describe "get_best_completion/2" do
    @get_completions_resp %{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX1\",\"object\":\"chat.completion\",\"created\":1683578704,\"model\":\"gpt-4-0314\",\"usage\":{\"prompt_tokens\":98,\"completion_tokens\":296,\"total_tokens\":394},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counter-clockwise.\\nStep 3: Since gear 2 is engaged with gear 1, gear 1 will rotate clockwise.\\nStep 4: Since gear 1 is engaged with gear 7, gear 7 will rotate counter-clockwise.\\n\\nSo, gear 7 would rotate counter-clockwise.\"},\"finish_reason\":\"stop\",\"index\":0},{\"message\":{\"role\":\"assistant\",\"content\":\"If gear 3 rotates clockwise, then gear 4 (which is engaged with gear 3) would rotate counterclockwise.\\n\\nNext, gear 5 (which is engaged with gear 4) would rotate clockwise since gear 4 is rotating counterclockwise.\\n\\nSimilarly, gear 6 (which is engaged with gear 5) would rotate counterclockwise since gear 5 is rotating clockwise.\\n\\nFinally, gear 7 (which is engaged with gear 6) would rotate clockwise since gear 6 is rotating counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":1},{\"message\":{\"role\":\"assistant\",\"content\":\"Step 1: Gear 3 rotates clockwise.\\nStep 2: Since gear 3 is engaged with gear 2, gear 2 will rotate counterclockwise.\\nStep 3: Gear 2 is engaged with gear 1, so gear 1 will rotate clockwise.\\nStep 4: Gear 1 is engaged with gear 7, so gear 7 will rotate counterclockwise.\\n\\nAnswer: Gear 7 would rotate counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":2}]}\n"
    }
    @get_best_completion_resp %{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX2\",\"object\":\"chat.completion\",\"created\":1683579016,\"model\":\"gpt-4-0314\",\"usage\":{\"prompt_tokens\":862,\"completion_tokens\":154,\"total_tokens\":1016},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Correct Answer: Option 1\\n\\nFlaws and faulty logic in other answer options:\\n\\nAnswer Option 2:\\n- This option starts with gear 3 rotating clockwise and then moves to gear 4, which is not directly engaged with gear 7. This method of working through the gears does not directly help in determining the rotation of gear 7.\\n- The final statement of this option contradicts itself, stating that gear 7 would rotate clockwise when it should be counterclockwise based on the previous steps.\\n\\nAnswer Option 3:\\n- There are no flaws or faulty logic in this option, but it is essentially the same as Answer Option 1, just with slightly different wording. It arrives at the correct answer of gear 7 rotating counterclockwise.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n"
    }
    test "returns the best completion based on success_resp" do
      with_mock HTTPoison,
        post!: fn "https://api.openai.com/v1/chat/completions", payload, _headers, _opts ->
          payload = Jason.decode!(payload)

          assert payload["model"] == "gpt-4"
          assert payload["temperature"] == 0.4

          case payload["messages"] do
            [%{"content" => "Question: ..." <> _}] ->
              assert payload["n"] == 4
              @get_completions_resp

            _ ->
              refute payload["n"]
              @get_best_completion_resp
          end
        end do
        assert {:ok, "" <> _comp} =
                 WiseGPTEx.get_best_completion("...",
                   model: "gpt-4",
                   temperature: 0.4,
                   num_completions: 4
                 )
      end
    end

    @error_resp %{
      status_code: 401,
      body:
        "{\n    \"error\": {\n        \"message\": \"Incorrect API key provided: sk-XXX. You can find your API key at https://platform.openai.com/account/api-keys.\",\n        \"type\": \"invalid_request_error\",\n        \"param\": null,\n        \"code\": \"invalid_api_key\"\n    }\n}\n"
    }

    test "handles error response" do
      with_mock HTTPoison,
        post!: fn _url, _payload, _headers, _opts ->
          @error_resp
        end do
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
  end

  describe "get_best_completion_with_resolver" do
    @get_resolver_completion_resp %{
      status_code: 200,
      body:
        "{\"id\":\"chatcmpl-XX4\",\"object\":\"chat.completion\",\"created\":1683648350,\"model\":\"gpt-3.5-turbo-0301\",\"usage\":{\"prompt_tokens\":2195,\"completion_tokens\":161,\"total_tokens\":2356},\"choices\":[{\"message\":{\"role\":\"assistant\",\"content\":\"Answer Option 1 and 2 are incorrect,\\n\\n<|answerstart|>Therefore, 456 multiplied by 23421 equals 10,649,876.\"},\"finish_reason\":\"stop\",\"index\":0}]}\n"
    }
    test "returns the completion given by the resolver" do
      with_mock HTTPoison,
        post!: fn _url, payload, _headers, _opts ->
          payload = Jason.decode!(payload)

          case payload["messages"] do
            [%{"content" => "Question: " <> _}] -> @get_completions_resp
            _ -> @get_resolver_completion_resp
          end
        end do
        {:ok, "Therefore, 456 multiplied by 23421 equals 10,649,876."} =
          WiseGPTEx.get_best_completion_with_resolver("", model: "gpt-3.5-turbo-0301")
      end
    end
  end

  describe "anthropic_completion/2" do
    @anthropic_success_resp %{
      status_code: 200,
      body:
        "{\"completion\":\"The sky is blue because of the way sunlight interacts with Earth's atmosphere.\",\"stop\":\"\\n\\nHuman:\",\"stop_reason\":\"length\",\"model\":\"claude-2\"}"
    }

    test "handles successful response from Anthropic API" do
      with_mock HTTPoison,
        post!: fn "https://api.anthropic.com/v1/complete", _payload, _headers, _opts ->
          @anthropic_success_resp
        end do
        assert {:ok,
                "The sky is blue because of the way sunlight interacts with Earth's atmosphere."} =
                 WiseGPTEx.anthropic_completion("Why is the sky blue?")
      end
    end

    @anthropic_error_resp %{
      status_code: 401,
      body: "{\"error\":{\"message\":\"Unauthorized access\",\"type\":\"authentication_error\"}}"
    }

    test "handles error response from Anthropic API" do
      with_mock HTTPoison,
        post!: fn _url, _payload, _headers, _opts ->
          @anthropic_error_resp
        end do
        assert {:error,
                %{
                  "error" => %{
                    "message" => "Unauthorized access",
                    "type" => "authentication_error"
                  }
                }} = WiseGPTEx.anthropic_completion("Why is the sky blue?")
      end
    end
  end
end
