defmodule Yggdrasil.GraphQL do
  @moduledoc """
  [![Build Status](https://travis-ci.org/etherharvest/yggdrasil_graphql.svg?branch=master)](https://travis-ci.org/etherharvest/yggdrasil_graphql) [![Hex pm](http://img.shields.io/hexpm/v/yggdrasil_graphql.svg?style=flat)](https://hex.pm/packages/yggdrasil_graphql) [![hex.pm downloads](https://img.shields.io/hexpm/dt/yggdrasil_graphql.svg?style=flat)](https://hex.pm/packages/yggdrasil_graphql)

  This project is a GraphQL adapter for `Yggdrasil` publisher/subscriber.

  ## Small example

  Let's say we want to have the following GraphQL `subscription`:

  ```graphql
  subscription {
    events(channel: "my_channel") {
      content
    }
  }
  ```

  And we have a process in Elixir that, using `Yggdrasil`, generates the
  following event:

  ```
  Yggdrasil.publish(
    %Yggdrasil.Channel{name: "my_channel"},
    %{content: "some message"}
  )
  ```

  Using [Absinthe](https://github.com/absinthe-graphql/absinthe), our Schema
  would look like this:

  ```elixir
  defmodule MyAppWeb.Schema do
    use Absinthe.Schema

    object :message do
      field :content, :string
    end

    query do
    end

    subscription do
      field :events, :message do
        arg :channel, non_null(:string)

        config fn args, %{context: %{pubsub: endpoint}} ->
          channel = %Yggdrasil.Channel{name: args.channel}
          Yggdrasil.GraphQL.subscribe(endpoint, :events, channel)
        end
      end
    end
  end
  ```

  ## Phoenix setup

  > This is an extract from
  > [this guide](https://hexdocs.pm/absinthe/subscriptions.html) modified
  > slightly to fit this example.

  1. Add the `Absinthe` libraries:
    ```elixir
    {:absinthe, "~> 1.4"},
    {:absinthe_phoenix, "~> 1.4"},
    ```
  2. Add the `Phoenix.PubSub` configuration for your endpoint:
    ```elixir
    config :my_app, MyAppWeb.Endpoint,
      # ... other config
      pubsub: [
        name: MyApp.PubSub,
        adapter: Phoenix.PubSub.PG2
      ]
    ```
  3. In your application supervisor, add a line **after** your existing endpoint
  supervision line:
    ```elixir
    [
      # other children ...
      supervisor(MyAppWeb.Endpoint, []), # this line should already exist.
      supervisor(Absinthe.Subscription, [MyAppWeb.Endpoint]), # add this line
      # other children ...
    ]
    ```
  Where `MyAppWeb.Endpoint` is the name of your application’s phoenix endpoint.
  4. In your `MyAppWeb.Endpoint` module add:
    ```
    use Absinthe.Phoenix.Endpoint
    ```
  5. In your socket add:
    - **Phoenix 1.3**
      ```elixir
      use Absinthe.Phoenix.Socket, schema: MyAppWeb.Schema
      ```
    - **Phoenix 1.2**
      ```
      use Absinthe.Phoenix.Socket
      def connect(_params, socket) do
        socket = Absinthe.Phoenix.Socket.put_schema(socket, MyAppWeb.Schema)
        {:ok, socket}
      end
      ```

  And that should be enough to have a working subscription setup.

  ## GraphQL adapter

  The GraphQL adapter has the following rules:
    * The `adapter` name is identified by the atom `:graphql`.
    * The channel `name` must be a tuple with the `endpoint` name,
    the subscription `field` and an `Yggdrasil` channel to any of the available
    adapters.
    * The `transformer` must encode to a map. It is recommended to leave the
    encoding and decoding to the underlying adapter. Defaults to `:default`
    transformer.
    * The `backend` is and always should be `:graphql`.

  The function `Yggdrasil.GraphQL.subscribe/3` is in charged of creating the
  channel and generating the topic for` Absinthe`.

  ## Installation

  Using this GraphQL adapter with `Yggdrasil` is a matter of adding the available
  hex package to your `mix.exs` file e.g:

  ```elixir
  def deps do
    [{:yggdrasil_graphql, "~> 0.1"}]
  end
  ```
  """
  alias Yggdrasil.Channel
  alias Yggdrasil.Registry

  @doc """
  Subscribes to `channel` using the `endpoint` for message distribution to
  subscribers of a `field`.
  """
  @spec subscribe(module(), atom(), Channel.t())
          :: {:ok, Keyword.t()} | {:error, term()}
  def subscribe(endpoint, field, channel)

  def subscribe(endpoint, field, %Channel{} = source) do
    channel = %Channel{
      name: {endpoint, field, source},
      adapter: :graphql
    }

    with :ok <- Yggdrasil.subscribe(channel) do
      {:ok, topic: gen_topic(channel)}
    end
  end

  @doc """
  Generates a `topic` from a `channel`.
  """
  @spec gen_topic(Channel.t()) :: binary()
  def gen_topic(channel)

  def gen_topic(%Channel{} = channel) do
    channel
    |> Registry.get_full_channel()
    |> :erlang.phash2()
    |> to_string()
  end
end
