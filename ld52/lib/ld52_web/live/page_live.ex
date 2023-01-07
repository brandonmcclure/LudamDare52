defmodule Ld52Web.PageLive do
  use Ld52Web, :live_view
  alias Ld52Web.{GameState}

  def mount(%{"id" => _} = _params, _session, socket) do
    {:ok, socket}
    dbg("mounting id?")
    socket
  end
  def mount(_param, _session, socket) do
    {:ok,
     if connected?(socket) do
       :timer.send_interval(1000, self(), :tick)
        dbg("mounting")
        socket = assign(socket, %{game: %GameState{counter: 0}})
        socket
     else
        dbg("mounting - socket not connected")
        socket = assign(socket, %{game: %GameState{counter: 0}})
        socket
     end
    }
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, %{game: socket.assigns.game})}
    dbg("handle_info")
  end

  def handle_event("inc",_params,socket) do
    {:noreply, socket
    |> dbg("increment")
    |> update(:socket.assigns.game.counter, &(&1 + 1)) #Anonymous function
  }
  end
  def handle_event("dec",_params,socket) do
    {:noreply,
    socket
    |> dbg("decrement")
    |> update(:socket.assigns.game.counter, &max(0, &1 - 1))
  }
  end
  def handle_event("clear",_params,socket) do
    {:noreply,
    socket
    |> dbg("clear")
    |> update(:socket.assigns.game.counter, 0)
  }
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    dbg("handling something"+id)
    game_state = %GameState{counter: 0}
    socket = assign(socket, %{game: game_state})
    :timer.send_interval(1000, self(), :tick)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    dbg("handle_params empty")
    {:noreply, socket}
  end

end
