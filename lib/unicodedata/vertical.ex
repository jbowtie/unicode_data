defmodule UnicodeData.Vertical do
  @moduledoc false
  @external_resource vert_path = Path.join([__DIR__, "VerticalOrientation.txt"])

  lines =
    File.stream!(vert_path, [], :line)
    |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))

  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)

    r =
      String.trim(r)
      |> String.split("..")
      |> Enum.map(&Integer.parse(&1, 16))
      |> Enum.map(fn {x, _} -> x end)

    s = String.trim(s)

    case r do
      [x] ->
        def orientation(unquote(x)) do
          unquote(s)
        end

      [a, b] ->
        def orientation(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end

  def orientation(_cp), do: "R"

  # The orientation for a grapheme cluster as a whole is then determined by taking the orientation of the first character 
  # in the cluster, with the following exception:
  #
  # If the cluster contains an enclosing combining mark (general category Me), then the whole cluster has the Vertical_Orientation value U.

  @external_resource eaw_path = Path.join([__DIR__, "EastAsianWidth.txt"])
  lines =
    File.stream!(eaw_path, [], :line)
    |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))

  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)

    r =
      String.trim(r)
      |> String.split("..")
      |> Enum.map(&Integer.parse(&1, 16))
      |> Enum.map(fn {x, _} -> x end)

    s = String.trim(s)

    case r do
      [x] ->
        def east_asian_width(unquote(x)) do
          unquote(s)
        end

      [a, b] ->
        def east_asian_width(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end

  def east_asian_width(_cp), do: "N"
end
