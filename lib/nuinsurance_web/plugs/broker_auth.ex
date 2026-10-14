defmodule NuinsuranceWeb.Plugs.BrokerAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    config = Application.get_env(:nuinsurance, :broker_auth, [])

    username = config[:username]
    password = config[:password]

    if configured?(username) and configured?(password) do
      authenticate(conn, username, password)
    else
      reject(conn, 503, "Broker access has not been configured.")
    end
  end

  defp authenticate(conn, username, password) do
    case Plug.BasicAuth.parse_basic_auth(conn) do
      {provided_username, provided_password} ->
        valid_username =
          Plug.Crypto.secure_compare(provided_username, username)

        valid_password =
          Plug.Crypto.secure_compare(provided_password, password)

        if valid_username and valid_password do
          assign(conn, :broker_authenticated, true)
        else
          reject(conn, 401, "Invalid broker credentials.")
        end

      :error ->
        reject(conn, 401, "Broker credentials are required.")
    end
  end

  defp configured?(value), do: is_binary(value) and byte_size(value) > 0

  defp reject(conn, status, message) do
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(status, Jason.encode!(%{error: message}))
    |> halt()
  end
end
