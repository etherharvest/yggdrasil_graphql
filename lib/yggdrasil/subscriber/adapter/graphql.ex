defmodule Yggdrasil.Subscriber.Adapter.GraphQL do
  @moduledoc """
  GraphQL subscriber adapter.
  """
  use Yggdrasil.Subscriber.Adapter
  use GenServer

  require Logger

  alias Yggdrasil.Channel
  alias Yggdrasil.Subscriber.Manager
  alias Yggdrasil.Subscriber.Publisher

  defstruct [:channel]
  alias __MODULE__, as: State

  @impl true
  def init(
    %{channel: %Channel{} = channel} = arguments
  ) do
    state = struct(State, arguments)
    Logger.debug(fn -> "Started #{__MODULE__} for #{inspect channel}" end)
    {:ok, state, 0}
  end

  @impl true
  def handle_info(
    :timeout,
    %State{channel: %Channel{name: {_, _, %Channel{} = source}}} = state
  ) do
    Yggdrasil.subscribe(source)
    {:noreply, state}
  end
  def handle_info(
    {:Y_CONNECTED, _},
    %State{channel: %Channel{} = channel} = state
  ) do
    Manager.connected(channel)
    {:noreply, state}
  end
  def handle_info(
    {:Y_EVENT, _, message},
    %State{channel: %Channel{} = channel} = state
  ) do
    Publisher.notify(channel, message)
    {:noreply, state}
  end
  def handle_info(
    {:Y_DISCONNECTED, _},
    %State{channel: %Channel{} = channel} = state
  ) do
    Manager.disconnected(channel)
    {:noreply, state}
  end
  def handle_info(_, %State{} = state) do
    {:noreply, state}
  end

  @impl true
  def terminate(
    :normal,
    %State{channel: %Channel{name: {_, _, %Channel{} = source}} = channel}
  ) do
    Yggdrasil.unsubscribe(source)
    Manager.disconnected(channel)
    Logger.debug(fn -> "Stopped #{__MODULE__} for #{inspect channel}" end)
  end
  def terminate(
    reason,
    %State{channel: %Channel{name: {_, _, %Channel{} = source} = channel}}
  ) do
    Yggdrasil.unsubscribe(source)
    Manager.disconnected(channel)
    Logger.warn(fn ->
      "Stopped #{__MODULE__} for #{inspect channel} due to #{inspect reason}"
    end)
  end
end
