defmodule Storage do
  @dir "data"
  @filename Application.get_env(:clash_of_clans_slackbot, :war_url_filename) || "data/war_url.bk"

  def save_url(url) do
    :ok = make_db_dir
    url
      |> :erlang.term_to_binary
      |> write_to_file
  end

  defp make_db_dir do
    case File.mkdir(@dir) do
      :ok -> :ok
      {:error, :eexist} -> :ok
      other -> other
    end
  end

  defp write_to_file(link) do
    File.write(@filename, link)
  end

  def get_war_url() do
    case File.read(@filename) do
      {:ok, binary_url} -> :erlang.binary_to_term(binary_url)
      _ -> raise :enoent
    end
  end
end
