defmodule UnicodeData.Segment do
  @moduledoc false

  # TODO: UAX14 Line_Break
  # LineBreak.txt
  @external_resource linebreak_path = Path.join([__DIR__, "LineBreak.txt"])
  lines = File.stream!(linebreak_path, [], :line)
          |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))
  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)
    r = String.trim(r)
        |> String.split("..")
        |> Enum.map(&Integer.parse(&1, 16))
        |> Enum.map(fn {x, _} -> x end)
    s = String.trim(s)
    case r do
      [x] ->
        def line_break(unquote(x)) do
          unquote(s)
        end
      [a, b] ->
        def line_break(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end
  def line_break(_codepoint), do: "XX"

  @doc """
  Indicate the result of enforcing the required breaking rules (LB 2 - LB 12),
  which cannot be tailored according to UAX #14.
  """
  def uax14_required_rules(left, right) do
    case {left, right} do
      {"BK", _} -> :required
      {"CR", "LF"} -> :prohibited
      {"CR", _} -> :required
      {"LF", _} -> :required
      {"NL", _} -> :required
      {_, "BK"} -> :prohibited
      {_, "CR"} -> :prohibited
      {_, "LF"} -> :prohibited
      {_, "NL"} -> :prohibited
      {_, "SP"} -> :prohibited
      {_, "ZW"} -> :prohibited
      {"ZW", _} -> :allowed
      {"ZWJ", "ID"} -> :prohibited
      {"ZWJ", "EB"} -> :prohibited
      {"ZWJ", "EM"} -> :prohibited
      # LB 9 and 10 are fully implemented in calling code
      {x, "CM"} when x not in [ "BK", "CR", "LF", "NL", "SP", "ZW"] -> :prohibited
      {x, "ZWJ"} when x not in [ "BK", "CR", "LF", "NL", "SP", "ZW"] -> :prohibited
      {"WJ", _} -> :prohibited
      {_, "WJ"} -> :prohibited
      {"GL", _} -> :prohibited
      _ -> nil
    end
  end

  def uax14_12a(lb1, lb2) do
    case {lb1, lb2} do
      {x, "GL"} when x in ["SP", "BA", "HY"] -> :allowed
      {_, "GL"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_13(lb1, lb2) do
    case {lb1, lb2} do
      {_, "CL"} -> :prohibited
      {_, "CP"} -> :prohibited
      {_, "EX"} -> :prohibited
      {_, "IS"} -> :prohibited
      {_, "SY"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_14(lb1, lb2) do
    case {lb1, lb2} do
      {"OP", _} -> :prohibited
      _ -> nil
    end
  end
  def uax14_15(lb1, lb2) do
    case {lb1, lb2} do
      {"QU", "OP"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_16(lb1, lb2) do
    case {lb1, lb2} do
      {"CL", "NS"} -> :prohibited
      {"CP", "NS"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_17(lb1, lb2) do
    case {lb1, lb2} do
      {"B2", "B2"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_18(lb1, lb2) do
    case {lb1, lb2} do
      {"SP", _} -> :allowed #LB18
      _ -> nil
    end
  end
  def uax14_19(lb1, lb2) do
    case {lb1, lb2} do
      {_, "QU"} -> :prohibited
      {"QU", _} -> :prohibited
      _ -> nil
    end
  end
  def uax14_20(lb1, lb2) do
    case {lb1, lb2} do
      {_, "CB"} -> :allowed
      {"CB", _} -> :allowed
      _ -> nil
    end
  end
  def uax14_21(lb1, lb2) do
    case {lb1, lb2} do
      {_, "BA"} -> :prohibited
      {_, "HY"} -> :prohibited
      {_, "NS"} -> :prohibited
      {"BB", _} -> :prohibited
      _ -> nil
    end
  end
  def uax14_21b(lb1, lb2) do
    case {lb1, lb2} do
      {"SY", "HL"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_22(lb1, lb2) do
    case {lb1, lb2} do
      {"AL", "IN"} -> :prohibited
      {"HL", "IN"} -> :prohibited
      {"EX", "IN"} -> :prohibited
      {"ID", "IN"} -> :prohibited
      {"EB", "IN"} -> :prohibited
      {"EM", "IN"} -> :prohibited
      {"IN", "IN"} -> :prohibited
      {"NU", "IN"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_23(lb1, lb2) do
    case {lb1, lb2} do
      {"AL", "NU"} -> :prohibited
      {"HL", "NU"} -> :prohibited
      {"NU", "AL"} -> :prohibited
      {"NU", "HL"} -> :prohibited
      {"PR", "ID"} -> :prohibited
      {"PR", "EB"} -> :prohibited
      {"PR", "EM"} -> :prohibited
      {"ID", "PO"} -> :prohibited
      {"EB", "PO"} -> :prohibited
      {"EM", "PO"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_24(lb1, lb2) do
    case {lb1, lb2} do
      {"PR", "AL"} -> :prohibited
      {"PR", "HL"} -> :prohibited
      {"PO", "AL"} -> :prohibited
      {"PO", "HL"} -> :prohibited
      {"AL", "PR"} -> :prohibited
      {"HL", "PR"} -> :prohibited
      {"AL", "PO"} -> :prohibited
      {"HL", "PO"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_25(lb1, lb2) do
    case {lb1, lb2} do
      #{"CL", "PO"} -> :prohibited
      #{"CP", "PO"} -> :prohibited
      #{"CL", "PR"} -> :prohibited
      #{"CP", "PR"} -> :prohibited
      {"NU", "PO"} -> :prohibited
      {"NU", "PR"} -> :prohibited
      #{"PO", "OP"} -> :prohibited
      {"PO", "NU"} -> :prohibited
      #{"PR", "OP"} -> :prohibited
      {"PR", "NU"} -> :prohibited
      {"HY", "NU"} -> :prohibited
      #{"IS", "NU"} -> :prohibited
      {"NU", "NU"} -> :prohibited
      #{"SY", "NU"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_26(lb1, lb2) do
    case {lb1, lb2} do
      {"JL", "JL"} -> :prohibited
      {"JL", "JV"} -> :prohibited
      {"JL", "H2"} -> :prohibited
      {"JL", "H3"} -> :prohibited
      {"JV", "JV"} -> :prohibited
      {"JV", "JT"} -> :prohibited
      {"H2", "JV"} -> :prohibited
      {"H2", "JT"} -> :prohibited
      {"JT", "JT"} -> :prohibited
      {"H3", "JT"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_27(lb1, lb2) do
    case {lb1, lb2} do
      {"JL", "IN"} -> :prohibited
      {"JV", "IN"} -> :prohibited
      {"JT", "IN"} -> :prohibited
      {"H2", "IN"} -> :prohibited
      {"H3", "IN"} -> :prohibited
      {"JL", "PO"} -> :prohibited
      {"JV", "PO"} -> :prohibited
      {"JT", "PO"} -> :prohibited
      {"H2", "PO"} -> :prohibited
      {"H3", "PO"} -> :prohibited
      {"PR", "JL"} -> :prohibited
      {"PR", "JV"} -> :prohibited
      {"PR", "JT"} -> :prohibited
      {"PR", "H2"} -> :prohibited
      {"PR", "H3"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_28(lb1, lb2) do
    case {lb1, lb2} do
      {"AL", "AL"} -> :prohibited
      {"AL", "HL"} -> :prohibited
      {"CM", "AL"} -> :prohibited #LB10 alt
      {"CM", "HL"} -> :prohibited #LB10 alt
      {"HL", "HL"} -> :prohibited
      {"HL", "AL"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_29(lb1, lb2) do
    case {lb1, lb2} do
      {"IS", "AL"} -> :prohibited
      {"IS", "HL"} -> :prohibited
      _ -> nil
    end
  end
  def uax14_30(lb1, lb2) do
    case {lb1, lb2} do
      {"AL", "OP"} -> :prohibited
      {"CM", "OP"} -> :prohibited #LB10 alt
      {"HL", "OP"} -> :prohibited
      {"NU", "OP"} -> :prohibited
      {"CP", "AL"} -> :prohibited
      {"CP", "HL"} -> :prohibited
      {"CP", "NU"} -> :prohibited
      # 30a - TODO: actually allow break between RI pairs
      {"RI", "RI"} -> :prohibited
      # LB 30b
      {"EB", "EM"} -> :prohibited
      _ -> nil
    end
  end

  @doc """
  Given line break classes of two characters, indicate whether a break between them is required, 
  prohibited, or allowed according to UAX#14.

  Assumes that LB1 has already resolved ambiguous characters.
  """
  def line_break_between(lb1, lb2) do
    tailored_rules = [
      &uax14_12a/2, &uax14_13/2, &uax14_14/2, &uax14_15/2,
      &uax14_16/2, &uax14_17/2, &uax14_18/2, &uax14_19/2,
      &uax14_20/2, &uax14_21/2, &uax14_21b/2, &uax14_22/2,
      &uax14_23/2, &uax14_24/2, &uax14_25/2, &uax14_26/2,
      &uax14_27/2, &uax14_28/2, &uax14_29/2, &uax14_30/2
    ]
    req = &uax14_required_rules/2 
    ruleset = [ req  | tailored_rules]
    ruleset
    |> Enum.find_value(:allowed, fn(rule) -> rule.(lb1, lb2) end)
  end

  @doc """
  This determines whether a break is allowed, required, or prohibited between two characters.
  """
  def uax14_break_between([x, y], state) do
    uax14_space_state([x, y], state)
  end

  # any of these classes before a space, carry foward in state
  defp uax14_space_state([x, "SP"], _) when x in ["OP", "QU", "CL", "CP", "B2", "ZW"] do
    # automatically prohibit (LB 7)
    # but also carry foward for other rules
    {:prohibited, x}
  end

  # carry forward the base type when followed by a space
  defp uax14_space_state([x1, "SP"], carry_fwd) when x1 in ["CM", "ZWJ"] and carry_fwd in ["OP", "QU", "CL", "CP", "B2", "ZW"] do
    # automatically prohibit (LB 7)
    # but also continue to carry foward
    {:prohibited, carry_fwd}
  end

  # LB9 - non-space followed by CM/ZWJ, carry foward in state
  defp uax14_space_state([x, "CM"], _) when x not in ["SP", "BK", "CR", "LF", "NL", "ZW", "CM", "ZWJ"] do
    # but also carry foward for other rules
    {line_break_between(x, "CM"), x}
  end
  defp uax14_space_state([x, "ZWJ"], _) when x not in ["SP", "BK", "CR", "LF", "NL", "ZW", "CM", "ZWJ"] do
    # automatically prohibit (LB 7)
    # but also carry foward for other rules
    {line_break_between(x, "CM"), x}
  end

  # SP - SP; promulgate carry_fwd
  defp uax14_space_state(["SP", "SP"], carry_fwd) do
    # automatically prohibit (LB 7)
    {:prohibited, carry_fwd}
  end
  # LB 9 CM/ZWJ - CM; promulgate carry_fwd
  defp uax14_space_state([x, "CM"], carry_fwd) when x in ["CM", "ZWJ"] do
    # automatically prohibit (LB 7)
    {:prohibited, carry_fwd}
  end
  # LB 9 CM/ZWJ - ZWJ; promulgate carry_fwd
  defp uax14_space_state([x, "ZWJ"], carry_fwd) when x in ["CM", "ZWJ"] do
    # automatically prohibit (LB 7)
    {:prohibited, carry_fwd}
  end
  # LB 8 - treat ZWJ normally (higher precendence)
  defp uax14_space_state(["ZWJ", x2], nil) when x2 in ["ID","EB","EM"] do
    {line_break_between("ZWJ", x2), nil}
  end
  # LB 10
  defp uax14_space_state(["ZWJ", x2], nil) when x2 in ["CM", "ZWJ"] do
    {line_break_between("AL", x2), "AL"}
  end
  # LB 10
  defp uax14_space_state([x1, x2], nil) when x1 in ["CM", "ZWJ"] do
    {line_break_between("AL", x2), nil}
  end
  # LB 9 - end of CM/ZWJ chain
  defp uax14_space_state([x1, x2], carry_fwd) when x1 in ["CM", "ZWJ"] do
    {line_break_between(carry_fwd, x2), nil}
  end
  #LB 7
  defp uax14_space_state(["SP", x2], "ZW") do
    {line_break_between("ZW", x2), nil}
  end
  # LB 14
  defp uax14_space_state(["SP", _], "OP") do
    {:prohibited, nil}
  end
  # LB 15
  defp uax14_space_state(["SP", "OP"], "QU") do
    {:prohibited, nil}
  end
  # LB 16
  defp uax14_space_state(["SP", "NS"], "CL") do
    {:prohibited, nil}
  end
  # LB 16
  defp uax14_space_state(["SP", "NS"], "CP") do
    {:prohibited, nil}
  end
  # LB 17
  defp uax14_space_state(["SP", "B2"], "B2") do
    {:prohibited, nil}
  end

  #by default defer to our case statement
  defp uax14_space_state([x1, x2], carry_fwd) do
    {line_break_between(x1, x2), carry_fwd}
  end

  # TODO: UAX29 Word_Break, Sentence_Break
  # WordBreakProperty.txt
  @external_resource wordbreak_path = Path.join([__DIR__, "WordBreakProperty.txt"])
  lines = File.stream!(wordbreak_path, [], :line)
          |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))
  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)
    r = String.trim(r)
        |> String.split("..")
        |> Enum.map(&Integer.parse(&1, 16))
        |> Enum.map(fn {x, _} -> x end)
    s = String.trim(s)
    case r do
      [x] ->
        def word_break(unquote(x)) do
          unquote(s)
        end
      [a, b] ->
        def word_break(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end
  def word_break(_codepoint), do: "Other"

  # SentenceBreakProperty.txt
  @external_resource sentence_path = Path.join([__DIR__, "SentenceBreakProperty.txt"])
  lines = File.stream!(sentence_path, [], :line)
          |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))
  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)
    r = String.trim(r)
        |> String.split("..")
        |> Enum.map(&Integer.parse(&1, 16))
        |> Enum.map(fn {x, _} -> x end)
    s = String.trim(s)
    case r do
      [x] ->
        def sentence_break(unquote(x)) do
          unquote(s)
        end
      [a, b] ->
        def sentence_break(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end
  def sentence_break(_codepoint), do: "Other"
end
