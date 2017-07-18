defmodule UnicodeData.Bidi do
  @moduledoc false
  @external_resource bidic_path = Path.join([__DIR__, "DerivedBidiClass.txt"])
  lines = File.stream!(bidic_path, [], :line)
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

  # TODO: BidiMirroring.txt (for each line, bmg(1) = 2, bm=true)
  # BidiBrackets.txt (for each line, bpb(1) = 2, bpbt = 3)
end

