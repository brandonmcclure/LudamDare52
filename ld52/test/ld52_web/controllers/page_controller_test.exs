defmodule Ld52Web.PageControllerTest do
  use Ld52Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ ~r/Counter/i
  end
end
