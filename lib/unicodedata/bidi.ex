defmodule UnicodeData.Bidi do
  @moduledoc false
  @external_resource bidic_path = Path.join([__DIR__, "DerivedBidiClass.txt"])
  lines =
    File.stream!(bidic_path, [], :line)
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
        def bidi_class(unquote(x)) do
          unquote(s)
        end

      [a, b] ->
        def bidi_class(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end

  # default to L for code points not explicitly listed
  def bidi_class(_n) do
    "L"
  end

  # Bidi mirroring
  @external_resource bidim_path = Path.join([__DIR__, "BidiMirroring.txt"])
  lines =
    File.stream!(bidim_path, [], :line)
    |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))

  for line <- lines do
    [r, s, _] = String.split(line, ~r/[\#;]/)
    {orig, _} = r |> String.trim() |> Integer.parse(16)
    {mirrored, _} = s |> String.trim() |> Integer.parse(16)
    def mirrored?(unquote(orig)), do: true

    def mirror_glyph(unquote(orig)) do
      unquote(mirrored)
    end
  end

  def mirrored?(_n), do: false
  def mirror_glyph(_n), do: nil

  # Bidi brackets
  @external_resource bidib_path = Path.join([__DIR__, "BidiBrackets.txt"])
  lines =
    File.stream!(bidib_path, [], :line)
    |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))

  for line <- lines do
    [r, s, t, _] = String.split(line, ~r/[\#;]/)
    {orig, _} = r |> String.trim() |> Integer.parse(16)
    {paired, _} = s |> String.trim() |> Integer.parse(16)
    t = String.trim(t)
    def paired_bracket_type(unquote(orig)), do: unquote(t)
    def paired_bracket(unquote(orig)), do: unquote(paired)
  end

  def paired_bracket_type(_n), do: "n"
  def paired_bracket(_n), do: nil
end
