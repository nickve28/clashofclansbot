defmodule ClashOfClansSlackbot.Models.Player do
  @derive [Poison.Encoder]
  defstruct [:name, :donations, :donations_received]

  def to_player(%{"name" => name, "donationsReceived" => donations_received, "donations" => donations}) do
    %ClashOfClansSlackbot.Models.Player{
      name: name,
      donations_received: donations_received,
      donations: donations
    }
  end

end
