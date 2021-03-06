defmodule ClashOfClansSlackbot.Repositories.ClashCaller do
  @war_api Application.get_env(:clash_of_clans_slackbot, :war_api)

  def start_war(name, ename, size) do
    @war_api.start_war(name, ename, size)
  end

  def reserve_attack(target, name, warcode) do
    @war_api.reserve_attack(target, name, warcode)
  end

  def overview(warcode) do

    case @war_api.overview(warcode) do
      {:ok, reservations} = result -> result
      _ -> {:error, :enowarurl}
    end
  end

  def register_attack(warcode, target, attack_position, stars) do
    @war_api.register_attack(warcode, target, attack_position, stars)
  end

  def remove_reservation({target, name, warcode, position}) do
    @war_api.remove_reservation({target, name, warcode, position})
  end
end
