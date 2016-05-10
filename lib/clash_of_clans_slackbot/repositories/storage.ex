defmodule Storage do
  @db_name Application.get_env :clash_of_clans_slackbot, :database

  def save_url(url) do
    Sqlitex.with_db(@db_name, fn db ->
      init db
      save db, url
    end)
  end

  defp init(db) do
    Sqlitex.query(db, "
      CREATE TABLE IF NOT EXISTS war_urls (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        url VARCHAR NOT NULL
      );
    ")
  end

  defp save(db, url) do
    Sqlitex.query(db, "
      INSERT INTO war_urls (url) VALUES ('#{url}');
    ")
  end
end
