defmodule Ld52Web.PageLive do
  use Ld52Web, :live_view
  alias Ld52Web.{Repo, GameState}

  def mount(%{"id" => _} = _params, _session, socket) do
    {:ok, socket}
  end
  def mount(_param, _session, socket) do
    {:ok,
     if connected?(socket) do
       :timer.send_interval(1000, self(), :tick)
        IO.puts("sdG")
       case Repo.insert(%GameState{counter: 0}) do
         {:ok, game_state} ->
           socket = assign(socket, %{game: game_state})
           push_redirect(socket, to: "/" <> game_state.id)

         {:error, _changeset} ->
           assign(socket, :error, "not sorry. I am broke")
       end
     else
       socket
     end}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, %{game: socket.assigns.game})}
  end

  def handle_event("inc",_params,socket) do
    {:noreply, socket
    |> update(:number, &(&1 + 1)) #Anonymous function
  }
  end
  def handle_event("dec",_params,socket) do
    {:noreply,
    socket
    |> update(:number, &max(0, &1 - 1))
  }
  end
  def handle_event("clear",_params,socket) do
    {:noreply,
    socket
    |> assign(number: 0)
  }
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    game_state = Repo.get!(GameState, id)
    socket = assign(socket, %{game: game_state})
    :timer.send_interval(1000, self(), :tick)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

end
