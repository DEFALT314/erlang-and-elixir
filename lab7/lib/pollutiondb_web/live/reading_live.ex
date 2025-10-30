defmodule PollutiondbWeb.ReadingLive do
alias File.Stat
  use PollutiondbWeb, :live_view
  alias Pollutiondb.Station
  alias Pollutiondb.Reading

  def mount(_params, _session, socket) do

    socket = assign(socket, stations: Station.getAll(), readings: Reading.get_last_10(), date: Date.utc_today(), station_id: "", type: "", value: "")
    {:ok, socket}
  end

  def handle_event("search", %{"date" => date}, socket) do
    if date == "" do
        socket = assign(socket, readings: Reading.get_last_10(), date: Date.utc_today())
        {:noreply, socket }
    else
      date = to_date(date)
      IO.puts date
      readings = Reading.find_by_date(date)
      socket = assign(socket, readings: readings, date: date)
      {:noreply, socket }

    end

  end
  def handle_event("insert", %{"station_id" => station_id, "type" => type, "value" => value}, socket) do
    station = %Station{id: to_int(station_id, 1)}
    Reading.add_now(station,type, to_float(value, 0.0))
    socket =  assign(socket, readings: Reading.get_last_10())
    {:noreply, socket }
  end
  def to_float(x,def) do
    case Float.parse(x) do
      :error -> def
      {val, _} -> val
    end
  end
  def to_int(x, default) do
    case Integer.parse(x) do
      :error -> default
      {val, _} -> val
    end
  end

  def to_date(val) do
    case Date.from_iso8601(val) do
      {:error, _} -> Date.utc_today()
      {:ok, x} -> x
    end
  end
  def render(assigns) do
    ~H"""
        Create new reading
      <form phx-submit="insert">

        Station: <select name="station_id">
          <%= for station <- @stations do %>
            <option label={station.name} value={station.id} selected={station.id == @station_id}/>
          <% end %>
        </select><br/>
        Type: <input type="text" name="type" step="0.1" value={@type} /><br/>
        Value: <input type="number" name="value" step="0.1" value={@value} /><br/>
        <input type="submit" />
      </form>


    <form phx-change="search">
        <input type="date" name="date" value={@date} /><br />
      </form>
    <table>

      <tr>
        <th>Name</th>
        <th>Date</th>
        <th>Time</th>
        <th>Type</th>
        <th>Value</th>
      </tr>
      <%= for reading <- @readings do %>
        <tr>
          <td><%= reading.station.name %></td>
          <td><%= reading.date %></td>
          <td><%= reading.time %></td>
          <td><%= reading.type %></td>
          <td><%= reading.value %></td>
        </tr>
      <% end %>
    </table>
    """
  end
end
