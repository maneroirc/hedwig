defmodule Hedwig.Responder.Supervisor do
  @moduledoc false

  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      Hedwig.Responder,
      [],
      restart: :transient
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
