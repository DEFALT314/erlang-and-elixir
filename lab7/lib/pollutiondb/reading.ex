defmodule Pollutiondb.Reading do
  require Ecto.Query

  use Ecto.Schema

  schema "readings" do
    field :date, :date
    field :time, :time
    field :type, :string
    field :value, :float
    belongs_to :station, Pollutiondb.Station
  end
  def add_Mock() do
    stations = Pollutiondb.Station.getAll()
    Pollutiondb.Reading.add_now(Enum.at(stations, 0), "pm10", 13.2)
    Pollutiondb.Reading.add_now(Enum.at(stations, 1), "pm2.5", 25.7)
    Pollutiondb.Reading.add_now(Enum.at(stations, 2), "ozone", 42.1)
    Pollutiondb.Reading.add_now(Enum.at(stations, 3), "so2", 9.8)
    Pollutiondb.Reading.add_now(Enum.at(stations, 4), "no2", 18.3)
  end
  @spec add_now(any(), any(), any()) :: any()
  def add_now(station,type, value) do
    reading = %Pollutiondb.Reading{
        date: Date.utc_today,
        time: Time.utc_now |> Time.truncate(:second),
        type: type,
        value: value,
        station_id: station.id
    }
    reading |> Pollutiondb.Repo.insert
  end
  def find_by_date(date) do

        Ecto.Query.from(r in Pollutiondb.Reading,
  limit: 10, where: r.date == ^date,order_by: [desc: r.time])
  |> Pollutiondb.Repo.all()
  |> Pollutiondb.Repo.preload(:station)
  end
  def get_last_10() do
    Ecto.Query.from(r in Pollutiondb.Reading,
  limit: 10, order_by: [desc: r.date, desc: r.time])
  |> Pollutiondb.Repo.all()
  |> Pollutiondb.Repo.preload(:station)
  end

  def add(station, date, time, type, value) do
        reading = %Pollutiondb.Reading{
        date: date,
        time: time,
        type: type,
        value: value,
        station: station

    }
    reading |> Pollutiondb.Repo.insert
  end
  def get_all() do
    Pollutiondb.Repo.all(Pollutiondb.Reading)
  end

end
