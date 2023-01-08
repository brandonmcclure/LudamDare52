defmodule Ld52Web.PageLive do
  use Ld52Web, :live_view
  alias Ld52.{Repo,GameState,ServerState}
  alias Phoenix.PubSub

  def mount(%{"id" => id} = _params, _session, socket) do
    #dbg("Existing game")
    game_state = Repo.get!(GameState, id)
    server_state = Repo.get!(ServerState, 1)
    socket = assign(socket,%{game: game_state, serverstate: server_state})
    {:ok, socket}
  end
  def mount(_param, _session, socket) do
    #dbg(socket)
    #dbg(connected?(socket))

    {:ok,
     if connected?(socket) do
       #:timer.send_interval(1000, self(), :tick)
        #dbg("Socket connected")

        case Repo.insert(%GameState{counter: 0}) do
          {:ok, game_state} ->
            socket = assign(socket, %{game: game_state})
            push_redirect(socket, to: "/" <> game_state.id)

          {:error, _changeset} ->
            assign(socket, :error, "sorry")
        end
     else
        #dbg("mounting - socket not connected")
        socket
     end
    }
  end

  def handle_info(:tick, socket) do
    #dbg("handle_tick")
    {:noreply, assign(socket, %{game: socket.assigns.game})}

  end
  def handle_info({:serverstate, state}, socket) do
    {:noreply, socket |> assign(:serverstate, state)}
end
def handle_state_transition() do

end
  def handle_event("inc",_params,socket) do
    #dbg("increment")
    #dbg(socket.assigns.game)
    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        counter: socket.assigns.game.counter + 1
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end


  def handle_params(%{"id" => id} = _params, _uri, socket) do
    #dbg("handle_params id")
    #dbg(id)
    Phoenix.PubSub.subscribe(Ld52.PubSub,"serverstate")
    game_state = Repo.get!(GameState, id)
    server_state = Repo.get!(ServerState, 1)
    #dbg(game_state)
    socket = assign(socket, %{game: game_state, serverstate: server_state})
    #:timer.send_interval(1000, self(), :tick)
    #dbg("done handling")
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    #dbg("handle_params empty")
    {:noreply, socket}
  end

end
