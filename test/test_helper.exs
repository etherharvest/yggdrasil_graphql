options = [pool_size: 1, name: MyTestEndpoint]
Application.put_env(:my_test_endpoint, MyTestEndpoint, [pubsub: options])

defmodule MyTestEndpoint do
  use Phoenix.Endpoint, otp_app: :my_test_endpoint
  use Absinthe.Phoenix.Endpoint
end

defmodule MyTestSchema do
  use Absinthe.Schema

  alias Yggdrasil.Channel
  alias Yggdrasil.GraphQL

  object :message do
    field :content, :string
  end

  query do
  end

  subscription do
    field :test, :message do
      arg :channel, non_null(:string)

      config fn args, %{context: %{pubsub: endpoint}} ->
        source = %Channel{name: args.channel}
        GraphQL.subscribe(endpoint, :test, source)
      end
    end
  end
end

Phoenix.PubSub.PG2.start_link(options)
Absinthe.Subscription.start_link(MyTestEndpoint)

ExUnit.start()
