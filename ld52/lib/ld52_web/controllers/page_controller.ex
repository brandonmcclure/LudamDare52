defmodule Ld52Web.PageController do
  use Ld52Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
