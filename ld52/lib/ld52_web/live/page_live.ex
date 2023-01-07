defmodule Ld52Web.PageLive do
  use Ld52Web, :live_view
  alias Ld52.{Repo,GameState}

  def mount(%{"id" => _} = _params, _session, socket) do
    dbg("Existing game")
    {:ok, socket}
  end
  def mount(_param, _session, socket) do
    dbg(socket)
    dbg(connected?(socket))
    {:ok,
     if connected?(socket) do
       #:timer.send_interval(1000, self(), :tick)
        dbg("Socket connected")

        case Repo.insert(%GameState{counter: 0}) do
          {:ok, game_state} ->
            socket = assign(socket, %{game: game_state})
            push_redirect(socket, to: "/" <> game_state.id)

          {:error, _changeset} ->
            assign(socket, :error, "sorry")
        end
     else
        dbg("mounting - socket not connected")
        socket
     end
    }
  end

  def handle_info(:tick, socket) do
    dbg("handle_tick")
    {:noreply, assign(socket, %{game: socket.assigns.game})}

  end

  def handle_event("inc",_params,socket) do
    dbg("increment")
    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        counter: socket.assigns.game.counter + 1
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end
  def handle_event("dec",_params,socket) do
    dbg("decrement")
    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        counter: max(0,socket.assigns.game.counter - 1)
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end
  def handle_event("clear",_params,socket) do
    dbg("clear")
    new_state =
      Ecto.Changeset.change(socket.assigns.game, %{
        counter: 0
      })

    game_state = Repo.update!(new_state)
    {:noreply, assign(socket, :game, game_state)}
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    dbg("handle_params id")
    dbg(id)
    game_state = Repo.get!(GameState, id)
    dbg(game_state)
    socket = assign(socket, %{game: game_state})
    #:timer.send_interval(1000, self(), :tick)
    dbg("done handling")
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    dbg("handle_params empty")
    {:noreply, socket}
  end

end
