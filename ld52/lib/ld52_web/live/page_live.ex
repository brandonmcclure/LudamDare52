defmodule Ld52Web.PageLive do
  use Ld52Web, :live_view
  alias Ld52.{Repo, GameState, ServerState, PlotState}
  alias Phoenix.PubSub

  def mount(%{"id" => id} = _params, _session, socket) do
    dbg("Existing game")

    socket =
      socket
      |> get_game_state(id)

    game_state = socket.assigns.game_state
    # Repo.preload(game_state, [:plot_states])
    server_state = Repo.get!(ServerState, 1)

    socket =
      assign(socket, %{
        game_state: game_state,
        serverstate: server_state,
        plot1_1_harvestable: true
      })

    {:ok, socket}
  end

  def mount(_param, _session, socket) do
    # dbg(socket)
    # dbg(connected?(socket))

    {:ok,
     if connected?(socket) do
       dbg("Socket connected")

       socket = new_state(socket)
       push_redirect(socket, to: "/" <> socket.assigns.game_state.id)
     else
       dbg("mounting - socket not connected")

       socket = new_state(socket)
       push_redirect(socket, to: "/" <> socket.assigns.game_state.id)
     end}
  end

  def handle_info({:serverstate, state}, socket) do
    dbg(socket)
    dbg("here")

    {:noreply,
     socket
     |> assign(serverstate: state)
     |> assign(plot1_1_harvestable: true)}
  end

  def handle_state_transition() do
  end

  def new_state(socket) do
    socket = insert_game_state(socket)
    dbg(socket)
  end

  def get_game_state(socket, id) do
    game_state = Repo.get!(GameState, id)

    socket
    |> assign(game_state: game_state)
  end

  def insert_game_state(socket) do
    case Repo.insert(%GameState{
           counter: 0
         }) do
      {:ok, game_state} ->
        dbg("inserted a new game state")

        socket
        |> assign(%{game_state: game_state, plot1_1_harvestable: true})

      {:error, _changeset} ->
        dbg("game state changeset error")
        socket |> assign(:error, "game state changeset error")
    end
  end

  def handle_event("inc", _params, socket) do
    # dbg("increment")
    # dbg(socket.assigns.game_state)
    new_state =
      Ecto.Changeset.change(socket.assigns.game_state, %{
        counter: socket.assigns.game_state.counter + 1
      })

    game_state = Repo.update!(new_state)

    {:noreply,
     socket
     |> assign(:game_state, game_state)
     |> assign(:serverstate, socket.assigns.serverstate)
     |> assign(:plot1_1_harvestable, false)}
  end

  def handle_params(%{"id" => id} = _params, _uri, socket) do
    # dbg("handle_params id")
    # dbg(id)
    Phoenix.PubSub.subscribe(Ld52.PubSub, "serverstate")
    socket = socket |> get_game_state(id)
    game_state = socket.assigns.game_state
    # Repo.preload(game_state, [:plot_states])
    # grid_state = game_state.plot_states
    # dbg(grid_state)
    server_state = Repo.get!(ServerState, 1)
    # dbg(game_state)
    socket = assign(socket, %{game_state: game_state, serverstate: server_state})
    # dbg("done handling")
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    # dbg("handle_params empty")
    {:noreply, socket}
  end
end
