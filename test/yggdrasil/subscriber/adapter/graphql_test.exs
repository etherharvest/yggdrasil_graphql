defmodule Yggdrasil.Subscriber.Adapter.GraphQLTest do
  use ExUnit.Case, async: true

  alias Phoenix.Socket.Broadcast

  test "distribute message" do
    name = UUID.uuid4()
    query =
      """
      subscription {
        test(channel: "#{name}") {
          content
        }
      }
      """
    {:ok, %{"subscribed" => topic}} =
      Absinthe.run(query, MyTestSchema, context: %{pubsub: MyTestEndpoint})
    MyTestEndpoint.subscribe(topic)
    message = %{content: "message"}

    Yggdrasil.publish([name: name], message)
    assert_receive %Broadcast{payload: payload}
    assert payload.result.data == %{"test" => %{"content" => "message"}}
  end
end
