defmodule Ld52Web.PageLiveTest do
  use Ld52Web.ConnCase
  import Phoenix.LiveViewTest

  test "disconnect and connect render",%{conn: conn} do
    {:ok, page_live, disconnected_html}= live(conn,"/")
    assert disconnected_html =~ "0"
    assert render(page_live) =~ "0"
  end
  test "inc dec",%{conn: conn}  do
    {:ok, page_live, _html}= live(conn,"/")

    assert render_click(page_live, :inc,%{}) =~ "1"
    assert render_click(page_live, :inc,%{}) =~ "2"
    assert render_click(page_live, :dec,%{}) =~ "1"
  end

  test "clear event",%{conn: conn}  do
    {:ok, page_live, _html}= live(conn,"/")

    assert render_click(page_live, :inc,%{}) =~ "1"
    assert render_click(page_live, :clear,%{}) =~ "0"
  end
end
