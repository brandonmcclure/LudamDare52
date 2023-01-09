defmodule Ld52.Periodically do
  use GenServer
  alias Ld52.{Repo, ServerState}
  import Ecto.Query, only: [from: 2]
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def server_state_by_id(id) do
    query = from u in ServerState, where: u.id == ^id, select: %{id: u.id}
    found = Repo.one(query)
    # if not result, found will be nil
    found != nil
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()

    if(!server_state_by_id(1)) do
      # dbg("init here")
      case Repo.insert(%ServerState{id: 1, hourssincecreation: 0, realsecondspergamehour: 1}) do
        {:ok, server_state} ->
          # dbg("ok")
          state = %{serverstate: server_state}

        {:error, _changeset} ->
          # dbg("error")
          state = %{serverstate: state}
      end
    else
      # dbg("Passing on existing state")
      state = %{serverstate: Repo.get!(ServerState, 1)}
      # dbg(state)
      {:ok, state}
    end
  end

  def handle_info(:work, state) do
    state = %{serverstate: Repo.get!(ServerState, 1)}
    dbg("time keeps on sliping")
    dbg(state)
    hr = state.serverstate.hourssincecreation
    # dbg(hr)
    new_state =
      Ecto.Changeset.change(state.serverstate, %{
        hourssincecreation: hr + 1
      })

    state = Repo.update!(new_state)
    PubSub.broadcast(Ld52.PubSub, "serverstate", state)
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, Repo.get!(ServerState, 1).realsecondspergamehour * 1000)
  end
end
