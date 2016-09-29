defmodule Clashcaller.ClashcallerEntry do
  @derive [Poison.Encoder]
  defstruct player: nil, stars: nil, target: nil, position: nil

  @star_mapping %{
    1 => "No attack",
    2 => "0 stars",
    3 => "1 star",
    4 => "2 stars",
    5 => "3 stars"
  }

  for {k, v} <- @star_mapping do
    def convert(unquote(k)), do: unquote(v)
  end

  def to_clashcaller_entry(clashcaller_output_json) do
    { parsed_posy, _ } = Integer.parse clashcaller_output_json["posy"]
    target = parsed_posy + 1 #clashcaller mapping

    { stars, _ } = Integer.parse clashcaller_output_json["stars"]
    mapped_stars = convert(stars)

    { position, _ } = Integer.parse clashcaller_output_json["posx"]
    position = position + 1

    %Clashcaller.ClashcallerEntry{
      player: clashcaller_output_json["playername"],
      stars: mapped_stars,
      target: target,
      position: position
    }
  end
end


