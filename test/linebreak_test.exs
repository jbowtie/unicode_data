defmodule Uax14Test do
  use ExUnit.Case, async: true

  def create_test_seq(combined) do
    test_str = combined
    |> Stream.take_every(2)
    |> Stream.map(&String.to_integer(&1, 16))
    |> Stream.map(fn x -> <<x::utf8>> end)
    |> Enum.join

    test_breaks = combined
    |> Enum.drop_every(2)
    |> Enum.with_index
    |> Enum.reject(fn {x, _} -> x == "×" end)
    |> Enum.map(fn {_, n} -> n+1 end)
    {test_str, test_breaks}
  end

  test "UAX14 test suite" do
    linebreak_path = Path.join([__DIR__, "LineBreakTest.txt"])
    lines = File.stream!(linebreak_path, [], :line)
            |> Stream.reject(&String.starts_with?(&1, "#"))
            |> Stream.take(7176)
            |> Stream.with_index

    for {line, index} <- lines do
      [test_seq, comment] = String.split(line, ~r/\#/)
      {t, breaks} = test_seq
                    |> String.trim
                    |> String.trim_leading("× ")
                    |> String.trim_trailing(" ÷")
                    |> String.split(" ")
                    |> create_test_seq

      actual = UnicodeData.linebreak_locations(t)
               |> Enum.map(fn {_, n} -> n end)
      assert(breaks == actual, "Test #{index}: #{t}\nExpected: #{inspect breaks}\nActual: #{inspect actual}\n#{comment}")
    end

  end

end
