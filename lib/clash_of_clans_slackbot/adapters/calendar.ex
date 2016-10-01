#A convenience adapter for testing time related code
defmodule ClashOfClansSlackbot.Adapters.Calendar do
  use GenServer

  def local_time() do
    Process.whereis(__MODULE__)
      |> get_time
  end

  def init(local_time), do: {:ok, local_time}

  def start_link do
    GenServer.start_link(__MODULE__, [:calendar.local_time()], name: __MODULE__)
  end

  def get_time(nil) do
    start_link()
    GenServer.call(__MODULE__, :get_time)
  end

  def get_time(_) do
    GenServer.call(__MODULE__, :get_time)
  end

  def handle_call(:get_time, _from, state) do
    {:reply, state, state}
  end

  #since we want the time to be updated in our tests, a call is used
  def set_time({{_year, _month, _day}, {_hours, _minutes, _seconds}} = date) do
    GenServer.call(__MODULE__, {:set_time, date})
  end

  def handle_call({:set_time, date}, _from, _state) do
    {:reply, date, date}
  end
end
