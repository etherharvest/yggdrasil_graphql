defmodule Yggdrasil.Backend.GraphQL do
  @moduledoc """
  GraphQL backend.
  """
  use Yggdrasil.Backend, name: :graphql

  alias Absinthe.Subscription
  alias Yggdrasil.Channel
  alias Yggdrasil.GraphQL

  @impl true
  def subscribe(_) do
    :ok
  end

  @impl true
  def unsubscribe(_) do
    :ok
  end

  @impl true
  def connected(_, _) do
    :ok
  end

  @impl true
  def disconnected(_, _) do
    :ok
  end

  @impl true
  def publish(%Channel{name: {endpoint, field, _}} = channel, message) do
    topic = GraphQL.gen_topic(channel)

    routing = Keyword.put([], field, topic)

    Subscription.publish(endpoint, message, routing)
  end
end
