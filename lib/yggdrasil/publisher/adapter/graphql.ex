defmodule Yggdrasil.Publisher.Adapter.GraphQL do
  @moduledoc false
  use Yggdrasil.Publisher.Adapter

  @doc false
  def start_link(_, _) do
    raise "Cannot start #{__MODULE__} because it does not exist"
  end

  @doc false
  def publish(_, _, _, _ \\ []) do
    raise "Cannot publish using #{__MODULE__} because if does not exist"
  end
end
