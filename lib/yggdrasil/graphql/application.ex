defmodule Yggdrasil.GraphQL.Application do
  @moduledoc """
  GraphQL adapter application.
  """
  use Application

  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Yggdrasil.Backend.GraphQL, []}, []),
      Supervisor.child_spec({Yggdrasil.Adapter.GraphQL, []}, [])
    ]

    opts = [strategy: :one_for_one, name: Yggdrasil.GraphQL.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
