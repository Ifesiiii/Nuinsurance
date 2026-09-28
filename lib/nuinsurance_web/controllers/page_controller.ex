defmodule NuinsuranceWeb.PageController do
  use NuinsuranceWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
