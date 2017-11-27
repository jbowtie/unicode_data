defmodule Uax14Test.Helper do
  def create_test_seq(combined) do
    test_str = combined
    |> Enum.take_every(2)
    |> Enum.map(&String.to_integer(&1, 16))
    |> Enum.map(fn x -> <<x::utf8>> end)
    |> Enum.join

    test_breaks = combined
    |> Enum.drop_every(2)
    |> Enum.with_index
    |> Enum.reject(fn {x, _} -> x == "×" end)
    |> Enum.map(fn {_, n} -> {:allowed, n+1} end)
    {test_str, test_breaks}
  end

  defmacro run_uax14_test(comment, t, breaks) do
    quote do
      test unquote(comment) do
        actual = UnicodeData.linebreak_locations(unquote(t))
        assert(unquote(breaks) == actual)
      end
    end
  end
end

defmodule Uax14Test do
  use ExUnit.Case
  import Uax14Test.Helper


  @external_resource linebreak_path = Path.join([__DIR__, "LineBreakTest.txt"])
  lines = File.stream!(linebreak_path, [], :line)
          |> Stream.reject(&String.starts_with?(&1, "#"))
          |> Enum.take(150)
  for line <- lines do
    [test_seq, comment] = String.split(line, ~r/\#/)
    {t, breaks} = test_seq
        |> String.trim
        |> String.trim_leading("× ")
        |> String.trim_trailing(" ÷")
        |> String.split(" ")
        |> create_test_seq
    run_uax14_test(comment, unquote(t), unquote(breaks))
  end

end
