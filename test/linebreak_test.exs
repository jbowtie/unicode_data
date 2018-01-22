defmodule Uax14Test do
  use ExUnit.Case, async: true

  def create_test_seq(combined) do
    test_str =
      combined
      |> Stream.take_every(2)
      |> Stream.map(&String.to_integer(&1, 16))
      |> Stream.map(fn x -> <<x::utf8>> end)
      |> Enum.join()

    test_breaks =
      combined
      |> Enum.drop_every(2)
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> x == "×" end)
      |> Enum.map(fn {_, n} -> n + 1 end)

    {test_str, test_breaks}
  end

  # tailor classes for our approach
  # replace NU with NUalt
  # can we detect (PR|PO) (OP|HY) NU and flag??
  def uax14_13_alt(lb1, lb2) do
    case {lb1, lb2} do
      {x, "CL"} when x != "NU" -> :prohibited
      {x, "CP"} when x != "NU" -> :prohibited
      {_, "EX"} -> :prohibited
      {x, "IS"} when x != "NU" -> :prohibited
      {x, "SY"} when x != "NU" -> :prohibited
      _ -> nil
    end
  end

  # NUalt props to NUalt, SY, IS
  # NUalt props to CL, CP but then disappears
  def uax14_25_alt(lb1, lb2) do
    case {lb1, lb2} do
      # (PR | PO) × ( OP | HY )? NU
      {"PO", "NU"} ->
        :prohibited

      {"PR", "NU"} ->
        :prohibited

      # {"PO", "OP"} -> :prohibited # PO OP NU
      # {"PR", "OP"} -> :prohibited # PR OP NU

      # {"PO", "HY"} -> :prohibited # PO HY NU
      # {"PR", "HY"} -> :prohibited # PR HY NU
      # ( OP | HY ) × NU
      {"OP", "NU"} ->
        :prohibited

      {"HY", "NU"} ->
        :prohibited

      # NU × (NU | SY | IS)
      {"NU", "NU"} ->
        :prohibited

      {"NU", "SY"} ->
        :prohibited

      {"NU", "IS"} ->
        :prohibited

      # NU (NU | SY | IS)* × (NU | SY | IS | CL | CP )
      {"NU", "CL"} ->
        :prohibited

      {"NU", "CP"} ->
        :prohibited

      # NU (NU | SY | IS)* (CL | CP)? × (PO | PR)
      {"NU", "PO"} ->
        :prohibited

      {"NU", "PR"} ->
        :prohibited

      _ ->
        nil
    end
  end

  def replace_rule(rules, old_rule, new_rule) do
    s = Enum.find_index(rules, fn x -> x == old_rule end)

    rules
    |> List.replace_at(s, new_rule)
  end

  test "UAX14 test suite" do
    linebreak_path = Path.join([__DIR__, "LineBreakTest.txt"])

    lines =
      File.stream!(linebreak_path, [], :line)
      |> Stream.reject(&String.starts_with?(&1, "#"))
      |> Stream.take(7176)
      |> Stream.with_index()

    # the test file assumes that the tailoring of rules 13 and 25
    # from the customization example 8.2 is in force
    rules =
      UnicodeData.Segment.uax14_default_rules()
      |> replace_rule(&UnicodeData.Segment.uax14_13/2, &uax14_13_alt/2)
      |> replace_rule(&UnicodeData.Segment.uax14_25/2, &uax14_25_alt/2)

    for {line, index} <- lines do
      [test_seq, comment] = String.split(line, ~r/\#/)

      {t, breaks} =
        test_seq
        |> String.trim()
        |> String.trim_leading("× ")
        |> String.trim_trailing(" ÷")
        |> String.split(" ")
        |> create_test_seq

      actual =
        UnicodeData.linebreak_locations(t, nil, rules)
        |> Enum.map(fn {_, n} -> n end)

      assert(
        breaks == actual,
        "Test #{index}: #{t}\nExpected: #{inspect(breaks)}\nActual: #{inspect(actual)}\n#{comment}"
      )
    end
  end
end
