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
