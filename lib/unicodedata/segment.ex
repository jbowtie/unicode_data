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
  Given line break classes of two characters, indicate whether a break between them is required, 
  prohibited, or allowed according to UAX#14.

  Assumes that LB1 has already resolved ambiguous characters.
  """
  def line_break_between(lb1, lb2) do
    # TAILORING
    # suppress rule X
    # replace rule X (rule might return nil?)
    # mandatory only
    # Mandatory rules (not tailored!)
    mand = case {lb1, lb2} do
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
    # Tailorable rules after this point
    # for now just case statement
    # TODO: figure out how tailoring will happen
    tailored = case {lb1, lb2} do
      #LB 12a
      {x, "GL"} when x in ["SP", "BA", "HY"] -> :allowed
      {_, "GL"} -> :prohibited
      #LB 13
      {_, "CL"} -> :prohibited
      {_, "CP"} -> :prohibited
      {_, "EX"} -> :prohibited
      {_, "IS"} -> :prohibited
      {_, "SY"} -> :prohibited
      #LB 14
      {"OP", _} -> :prohibited
      #LB 15
      {"QU", "OP"} -> :prohibited
      #LB 16
      {"CL", "NS"} -> :prohibited
      {"CP", "NS"} -> :prohibited
      #LB 17
      {"B2", "B2"} -> :prohibited
      {"SP", _} -> :allowed #LB18
      {_, "QU"} -> :prohibited
      {"QU", _} -> :prohibited
      {_, "CB"} -> :allowed
      {"CB", _} -> :allowed
      #LB 21-30 all prohibit specifc breaks
      {_, "BA"} -> :prohibited
      {_, "HY"} -> :prohibited
      {_, "NS"} -> :prohibited
      {"BB", _} -> :prohibited
      #TODO: LB21a HL(HY|BA)x
      # LB 21b
      {"SY", "HL"} -> :prohibited
      # LB 22
      {"AL", "IN"} -> :prohibited
      {"CM", "IN"} -> :prohibited #LB10 alt
      {"HL", "IN"} -> :prohibited
      {"EX", "IN"} -> :prohibited
      {"ID", "IN"} -> :prohibited
      {"EB", "IN"} -> :prohibited
      {"EM", "IN"} -> :prohibited
      {"IN", "IN"} -> :prohibited
      {"NU", "IN"} -> :prohibited
      # LB 23
      {"AL", "NU"} -> :prohibited
      {"CM", "NU"} -> :prohibited #LB10 alt
      {"HL", "NU"} -> :prohibited
      {"NU", "AL"} -> :prohibited
      {"NU", "HL"} -> :prohibited
      {"PR", "ID"} -> :prohibited
      {"PR", "EB"} -> :prohibited
      {"PR", "EM"} -> :prohibited
      {"ID", "PO"} -> :prohibited
      {"EB", "PO"} -> :prohibited
      {"EM", "PO"} -> :prohibited
      #LB 24
      {"PR", "AL"} -> :prohibited
      {"PR", "HL"} -> :prohibited
      {"PO", "AL"} -> :prohibited
      {"PO", "HL"} -> :prohibited
      {"AL", "PR"} -> :prohibited
      {"CM", "PR"} -> :prohibited #LB10 alt
      {"HL", "PR"} -> :prohibited
      {"AL", "PO"} -> :prohibited
      {"CM", "PO"} -> :prohibited #LB10 alt
      {"HL", "PO"} -> :prohibited
      #LB 25 -- UAX tests require tailoring!
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
      #LB 26
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
      #LB 27
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
      #LB 28
      {"AL", "AL"} -> :prohibited
      {"AL", "HL"} -> :prohibited
      {"CM", "AL"} -> :prohibited #LB10 alt
      {"CM", "HL"} -> :prohibited #LB10 alt
      {"HL", "HL"} -> :prohibited
      {"HL", "AL"} -> :prohibited
      #LB 29
      {"IS", "AL"} -> :prohibited
      {"IS", "HL"} -> :prohibited
      #LB 30
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
      #default - LB31
      _ -> :allowed
    end

    if mand != nil, do: mand, else: tailored
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
