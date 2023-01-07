defmodule Ld52.Periodically do
  use GenServer
  alias Ld52.{Repo,ServerState}
  import Ecto.Query, only: [from: 2]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def server_state_by_id(id) do
    query = (from u in ServerState, where: u.id == ^id, select: %{id: u.id})
    found = Repo.one(query)
    #if not result, found will be nil
    found != nil
  end
  def init(state) do

    schedule_work() # Schedule work to be performed at some point
    if(!server_state_by_id(1)) do
      dbg("init here")
      case Repo.insert(%ServerState{id: 1, hourssincecreation: 0, realsecondspergamehour: 10}) do

        {:ok, server_state} ->
          dbg("ok")
          state = %{serverstate: server_state}

        {:error, _changeset} ->
          dbg("error")
          state = %{serverstate: state}
      end
    else
      dbg("Passing on existing state")
      state = %{serverstate: Repo.get!(ServerState, 1)}
      dbg(state)
      {:ok, state}
    end


  end

  def handle_info(:work, state) do

    dbg("time keeps on sliping")
    dbg(state)
    hr = state.serverstate.hourssincecreation
    dbg(hr)
    new_state =
      Ecto.Changeset.change(state.serverstate, %{
        hourssincecreation: hr + 1
      })

      state = Repo.update!(new_state)

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 20 * 1000) # In 2 minutes
  end
end
