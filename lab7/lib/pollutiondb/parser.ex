defmodule Pollutiondb.Parser do
  def parser(data) do
    IO.puts(data)
    [datetime, pollutionType, pollutionLevel, id, stationName, locaton] = String.split(data, ";")
    date = datetime|> String.slice(0..9) |> String.split("-") |> Enum.map(&String.to_integer/1)
      |> List.to_tuple
    time = datetime |> String.slice(11..18) |> String.split(":") |> Enum.map(&String.to_integer/1)
      |>List.to_tuple
    location = locaton |> String.split(",") |> Enum.map(&String.to_float/1) |> List.to_tuple
    %{:datetime => { date, time},
      :location => location,
      :stationId => String.to_integer(id),
      :stationName => stationName,
      :pollutionType => pollutionType,
      :pollutionLevel => String.to_float(pollutionLevel)}
  end

  def identifyStations(data) do
    Enum.uniq_by(data, & (&1.stationId))
  end

  def addStations do
    data = File.read!("/home/defalt/Pobrane/AirlyData-ALL-50k.csv") |> String.split("\n", trim: true)
    IO.puts length(data)
    parsed_data = Enum.map(data, &parser/1) |> identifyStations
    |> Enum.map(
      &{"#{&1.stationId} #{&1.stationName}", &1.location})
    |> Enum.each(
      fn ({name, {x,y}})->
        Pollutiondb.Station.add(name, x,y)
      end
    )

  end
  def addReadings do
    data = File.read!("/home/defalt/Pobrane/AirlyData-ALL-50k.csv") |> String.split("\n", trim: true)
    Enum.map(data, &parser/1)
    |> Enum.each(
      fn x ->
        {date, time} = x.datetime
        date = Date.from_erl!(date)
        time = Time.from_erl!(time)
        station = Pollutiondb.Station.find_by_name("#{x.stationId} #{x.stationName}") |> List.first()
        Pollutiondb.Reading.add(station, date, time, x.pollutionType, x.pollutionLevel)
      end
    )

  end
end
