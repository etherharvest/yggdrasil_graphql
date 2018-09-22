defmodule Yggdrasil.Adapter.GraphQL do
  @moduledoc """
  GraphQL adapter.
  """
  use Yggdrasil.Adapter,
    name: :graphql,
    backend: :graphql
end
