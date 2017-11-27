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
    # ambiguous category resolution
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
        #TODO: figure out how LB9 and LB10 work, would normally go here!
        #see 9.1 for a possible implementation
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
      {"OP", _} -> :prohibited #SP*
      #LB 15
      {"QU", "OP"} -> :prohibited #SP*
      #LB 16
      {"CL", "NS"} -> :prohibited #SP*
      {"CP", "NS"} -> :prohibited #SP*
      #LB 17
      {"B2", "B2"} -> :prohibited #SP*
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
      {"AL", "IN"} -> :prohibited
      {"CM", "IN"} -> :prohibited #LB10 alt
      {"HL", "IN"} -> :prohibited
      {"EX", "IN"} -> :prohibited
      {"ID", "IN"} -> :prohibited
      {"EB", "IN"} -> :prohibited
      {"EM", "IN"} -> :prohibited
      {"IN", "IN"} -> :prohibited
      {"NU", "IN"} -> :prohibited
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
      #LB 25
      #LB 26
      #LB 27
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
