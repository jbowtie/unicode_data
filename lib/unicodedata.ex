defmodule UnicodeData do
  @moduledoc """
  Provides access to Unicode properties needed for more complex text processing.

  ## Script detection

  Proper text layout requires knowing which script is in use for a run of text.
  Unicode provides the `Script` property to identify the script associated with a
  codepoint. The script short name is also provided, which can be passed to font
  engines or cross-referenced with [ISO 15924](https://en.wikipedia.org/wiki/ISO_15924).

  Once the script is identified, it's possible to determine if the script is a right-to-left
  script, as well as what additional support might be required for proper layout.

  ## Shaping support

  The `Joining_Type` and `Joining_Group` properties provide support for shaping engines
  doing layout of cursive scripts.

  ## Layout support

  Bidirectional algorithms such the one in [UAX #9](http://www.unicode.org/reports/tr9/) require access
  to several Unicode properties in order to properly layout paragraphs where the direction of the text 
  is not uniform -- for example, when embedding an English word into a Hebrew paragraph.

  The `Bidi_Class`, `Bidi_Mirroring_Glyph`, `Bidi_Mirrored`, `Bidi_Paired_Bracket`, and `Bidi_Paired_Bracket_Type`
  properties are specifically provided to allow for implementation
  of the Unicode bidirectional algorithm described in [UAX #9](http://www.unicode.org/reports/tr9/).

  For layout of vertical text, the `Vertical_Orientation` and `East_Asian_Width` properties are exposed
  to help layout engines decide whether or not to rotate characters that are normally laid out horizontally.
  This can (and should) be tailored based on context but provide sane defaults in the absence of any
  such context (such as when rendering a plain text document).

  ## Text segmentation

  Textual analysis often requires splitting on line, word, or sentence boundaries. While the most
  sophisticated algorithms require contextual knowledge, Unicode provides properties and default
  algorithms for this purpose.

  ### Line Breaking

  The Unicode line-breaking algorithm described in [UAX #14](http://www.unicode.org/reports/tr14/) 
  makes use of the `Line_Break` property and has notes about tailoring the algorithm for various
  contexts.

  This module exposes the property, a conformant implementation of the line-breaking algorithm, and the 
  ability to tailor the algorithm according to the standard. As part of the test suite it tailors the algorithm
  by customizing rules 13 and 25 per the example given in the algorithm description. 

  For most purposes, breaking plain text into paragraphs can be accomplished by line breaking only at required
  break points.

      iex> UnicodeData.apply_required_linebreaks("Paragraph 1.\\nParagraph 2.")
      ["Paragraph 1.", "Paragraph 2."]

  Laying out paragraphs of text usually involves identifying potential breakpoints and choosing the
  ones that best satisfy layout constraints. To aid in this analysis, the `identify_linebreak_positions`
  returns a list of indices that indicate potential break positions.

      iex> UnicodeData.identify_linebreak_positions("Where can this line be broken?\\nLet me know.")
      [{"Where can this line be broken?", [6, 10, 15, 20, 23]}, {"Let me know.", [4, 7]}]

  ### Tailoring the line-breaking algorithm

  This implementation allows for several ways to tailor the algorithm for more complex needs.

  The first is to modify the classification of code points by supplying a `linebreak_classifier` function to
  any of the line-breaking functions. If you don't supply one, the aptly-named `default_linebreak_classes/2` 
  will be applied to conform with the default implementation.

  The second is to replace, discard, or supplement one or more of the tailorable rules. An example will be
  provided in future versions; for now, we recommend looking at the test suite to see such tailoring in action.

  ### Word and sentence breaking

  Breaking on word and sentence boundaries is described in [UAX #29](http://www.unicode.org/reports/tr29/)
  and makes use of the `Word_Break` and `Sentence_Break` properties, respectively.
  """

  alias UnicodeData.Script
  alias UnicodeData.Bidi
  alias UnicodeData.Segment
  alias UnicodeData.Vertical

  @typedoc """
  A codepoint in either binary or numeric form.
  """
  @type cp :: integer | String.codepoint()

  @typedoc """
  Function that can override or resolve the linebreak classification of a codepoint.
  """
  @type linebreak_classifier :: (String.codepoint(), String.t() -> String.t())

  @typedoc """
  Function that determines whether a break is allowed between two linebreak classifiers.
  """
  @type uax14_tailored_rule ::
          (String.t(), String.t(), String.t() | nil -> {atom | nil, String.t() | nil})

  @typedoc """
  Set of tailored line-breaking rules.
  """
  @type uax14_ruleset :: [uax14_tailored_rule]

  @doc """
  Lookup the script property associated with a codepoint.

  This will return the script property value. In addition to the explicitly
  defined scripts, there are three special values.

  * Characters with script value `Inherited` inherit the script of the preceding character.
  * Characters with script value `Common` are used in multiple scripts.
  * Characters of `Unknown` script are unassigned, private use, noncharacter or
  surrogate code points.

  This is sourced from [Scripts.txt](http://www.unicode.org/Public/UNIDATA/Scripts.txt)

  ## Examples

      iex> UnicodeData.script_from_codepoint("a")
      "Latin"
      iex> UnicodeData.script_from_codepoint("9")
      "Common"
      iex> UnicodeData.script_from_codepoint("\u0643")
      "Arabic"

  """
  @spec script_from_codepoint(integer | String.codepoint()) :: String.t()
  def script_from_codepoint(codepoint) when is_integer(codepoint) do
    Script.script_from_codepoint(codepoint)
  end

  def script_from_codepoint(codepoint) do
    <<intval::utf8>> = codepoint
    script_from_codepoint(intval)
  end

  @doc """
  Get the short name associated with a script. This is the tag
  used to identify scripts in OpenType fonts and generally matches
  the script code defined in ISO 15942.

  See [Annex #24](http://www.unicode.org/reports/tr24/) for more about
  the relationship between Unicode and ISO 15942.

  Data from [OpenType script tags](http://www.microsoft.com/typography/otspec/scripttags.htm)
  and [PropertyValueAliases.txt](http://www.unicode.org/Public/UNIDATA/PropertyValueAliases.txt)

  ## Examples

      iex> UnicodeData.script_to_tag("Latin")
      "latn"
      iex> UnicodeData.script_to_tag("Unknown")
      "zzzz"
      iex> UnicodeData.script_to_tag("Adlam")
      "adlm"


  """
  @spec script_to_tag(String.t()) :: String.t()
  def script_to_tag(script) do
    Script.script_to_tag(script)
  end

  @doc """
  Determine if the script is written right-to-left.

  This data is derived from ISO 15924.
  There's a handy sortable table on
  [the Wikipedia page for ISO 15924](https://en.wikipedia.org/wiki/ISO_15924).

  ## Examples

      iex> UnicodeData.right_to_left?("Latin")
      false
      iex> UnicodeData.right_to_left?("Arabic")
      true

  You can also pass the script short name.

      iex> UnicodeData.right_to_left?("adlm")
      true

  """
  @spec right_to_left?(String.t()) :: boolean
  def right_to_left?(script) do
    as_tag = Script.right_to_left?(script)

    if as_tag do
      true
    else
      script
      |> script_to_tag
      |> Script.right_to_left?()
    end
  end

  @doc """
  Determine if a script uses the `Joining Type` property
  to select contextual forms.

  Typically this is used to select a shaping engine, which will then call
  `joining_type/1` and `joining_group/1` to do cursive shaping.

  ## Examples

      iex> UnicodeData.uses_joining_type?("Latin")
      false
      iex> UnicodeData.uses_joining_type?("Arabic")
      true
      iex> UnicodeData.uses_joining_type?("Nko")
      true

  You can also pass the script short name.

      iex> UnicodeData.uses_joining_type?("syrc")
      true

  """
  @spec uses_joining_type?(String.t()) :: boolean
  def uses_joining_type?(script) do
    as_tag = Script.uses_joining_type?(script)

    if as_tag do
      true
    else
      script
      |> script_to_tag
      |> Script.uses_joining_type?()
    end
  end

  @doc """
  Determine the joining type for cursive scripts.

  Cursive scripts have the following join types:
  *  `R` Right_Joining (top-joining for vertical)
  *  `L` Left_Joining (bottom-joining for vertical)
  *  `D` Dual_Joining -- joins to characters on both sides.
  *  `C` Join_Causing -- forces a join to occur.
  *  `U` Non_Joining -- does not join to characters on either side.
  *  `T` Transparent -- characters on either side join to each other.

  Transparent characters are treated as if they do not exist during joining -- typically these are
  marks that render above or below the preceding base glyph.

  Characters from other scripts return `U` as they do not participate in cursive shaping.

  This is sourced from [ArabicShaping.txt](http://www.unicode.org/Public/UNIDATA/ArabicShaping.txt)

  ## Examples

      iex> UnicodeData.joining_type("\u0643")
      "D"
      iex> UnicodeData.joining_type("\u062F")
      "R"
      iex> UnicodeData.joining_type("\u0710")
      "R"
  """
  @spec joining_type(cp) :: String.t()
  def joining_type(codepoint) when is_integer(codepoint) do
    Script.jointype_from_codepoint(codepoint)
  end

  def joining_type(codepoint) do
    <<intval::utf8>> = codepoint
    joining_type(intval)
  end

  @doc """
  Determine the joining group for cursive scripts.

  Characters from other scripts return `No_Joining_Group` as they do not
  participate in cursive shaping.

  The `ALAPH` and `DALATH RISH` joining groups are of particular interest
  to shaping engines dealing with Syriac. 
  [Chapter 9.3 of the Unicode Standard](http://www.unicode.org/versions/Unicode10.0.0/ch09.pdf) 
  discusses Syriac shaping in detail.

  This is sourced from [ArabicShaping.txt](http://www.unicode.org/Public/UNIDATA/ArabicShaping.txt)

  ## Examples

      iex> UnicodeData.joining_group("\u0643")
      "KAF"
      iex> UnicodeData.joining_group("\u062F")
      "DAL"
      iex> UnicodeData.joining_group("\u0710")
      "ALAPH"
  """
  @spec joining_group(cp) :: String.t()
  def joining_group(codepoint) when is_integer(codepoint) do
    Script.joingroup_from_codepoint(codepoint)
  end

  def joining_group(codepoint) do
    <<intval::utf8>> = codepoint
    joining_group(intval)
  end

  @doc """
  Determine the bidirectional character type of a character.

  This is used to initialize the Unicode bidirectional algorithm, published in [UAX #9](http://www.unicode.org/reports/tr9/).

  There are several blocks of unassigned code points which are reserved to specific script blocks and therefore return
  a specific bidirectional character type. For example, unassigned code point `\uFE75`, in the Arabic block, has type "AL".

  If not specifically assigned or reserved, the default value is "L" (Left-to-Right).

  This is sourced from [DerivedBidiClass.txt](http://www.unicode.org/Public/UNIDATA/extracted/DerivedBidiClass.txt)

  ## Examples

      iex> UnicodeData.bidi_class("A")
      "L"
      iex> UnicodeData.bidi_class("\u062F")
      "AL"
      iex> UnicodeData.bidi_class("\u{10B40}")
      "R"
      iex> UnicodeData.bidi_class("\uFE75")
      "AL"
  """
  @spec bidi_class(cp) :: String.t()
  def bidi_class(codepoint) when is_integer(codepoint) do
    Bidi.bidi_class(codepoint)
  end

  def bidi_class(codepoint) do
    <<intval::utf8>> = codepoint
    bidi_class(intval)
  end

  @doc """
  The `Bidi_Mirrored` property indicates whether or not there is another Unicode character 
  that typically has a glyph that is the mirror image of the original character's glyph.

  Character-based mirroring is used by the Unicode bidirectional algorithm.  A layout engine
  may want to consider other method of mirroring.

  Some characters like \u221B (CUBE ROOT) claim to be mirrored but do not actually have a 
  corresponding mirror character - in those cases this function returns false.

  This is sourced from [BidiMirroring.txt](http://www.unicode.org/Public/UNIDATA/BidiMirroring.txt)

  ## Examples

      iex> UnicodeData.bidi_mirrored?("A")
      false
      iex> UnicodeData.bidi_mirrored?("[")
      true
      iex> UnicodeData.bidi_mirrored?("\u221B")
      false
  """
  @spec bidi_mirrored?(cp) :: boolean
  def bidi_mirrored?(codepoint) when is_integer(codepoint) do
    Bidi.mirrored?(codepoint)
  end

  def bidi_mirrored?(codepoint) do
    <<intval::utf8>> = codepoint
    bidi_mirrored?(intval)
  end

  @doc """
  The `Bidi_Mirroring_Glyph` property returns the character suitable for character-based
  mirroring, if one exists. Otherwise, it returns `nil`.

  Character-based mirroring is used by the Unicode bidirectional algorithm.  A layout engine
  may want to consider other method of mirroring.

  This is sourced from [BidiMirroring.txt](http://www.unicode.org/Public/UNIDATA/BidiMirroring.txt)

  ## Examples

      iex> UnicodeData.bidi_mirror_codepoint("[")
      "]"
      iex> UnicodeData.bidi_mirror_codepoint("A")
      nil
  """
  @spec bidi_mirror_codepoint(cp) :: String.codepoint() | nil
  def bidi_mirror_codepoint(codepoint) when is_integer(codepoint) do
    m = Bidi.mirror_glyph(codepoint)
    if m != nil, do: <<m::utf8>>, else: nil
  end

  def bidi_mirror_codepoint(<<codepoint::utf8>>) do
    bidi_mirror_codepoint(codepoint)
  end

  @doc """
  The Unicode `Bidi_Paired_Bracket_Type` property classifies characters into opening and closing
  paired brackets for the purposes of the Unicode bidirectional algorithm.

  It returns one of the following values:
  * `o` Open - The character is classified as an opening bracket.
  * `c` Close - The character is classified as a closing bracket.
  * `n` None - the character is not a paired bracket character.

  This is sourced from [BidiBrackets.txt](http://www.unicode.org/Public/UNIDATA/BidiBrackets.txt)

  ## Examples

      iex> UnicodeData.bidi_paired_bracket_type("[")
      "o"
      iex> UnicodeData.bidi_paired_bracket_type("}")
      "c"
      iex> UnicodeData.bidi_paired_bracket_type("A")
      "n"

  """
  @spec bidi_paired_bracket_type(cp) :: String.t()
  def bidi_paired_bracket_type(codepoint) when is_integer(codepoint) do
    Bidi.paired_bracket_type(codepoint)
  end

  def bidi_paired_bracket_type(<<codepoint::utf8>>) do
    Bidi.paired_bracket_type(codepoint)
  end

  @doc """
  The `Bidi_Paired_Bracket` property is used to establish pairs of opening and closing
  brackets for the purposes of the Unicode bidirectional algorithm.

  If a character is an opening or closing bracket, this will return the other character in
  the pair. Otherwise, it returns `nil`.

  This is sourced from [BidiBrackets.txt](http://www.unicode.org/Public/UNIDATA/BidiBrackets.txt)

  ## Examples

      iex> UnicodeData.bidi_paired_bracket("[")
      "]"
      iex> UnicodeData.bidi_paired_bracket("]")
      "["
      iex> UnicodeData.bidi_paired_bracket("A")
      nil

  """
  @spec bidi_paired_bracket(cp) :: String.codepoint() | nil
  def bidi_paired_bracket(codepoint) when is_integer(codepoint) do
    val = Bidi.paired_bracket(codepoint)
    if val != nil, do: <<val::utf8>>, else: nil
  end

  def bidi_paired_bracket(<<codepoint::utf8>>) do
    bidi_paired_bracket(codepoint)
  end

  @doc """
  The Line_Break property is used by the Unicode line breaking algorithm to identify locations where
  a break opportunity exists.

  These are intended to be interpreted in the scope of [UAX #14](http://www.unicode.org/reports/tr14/).
  You may wish to override these values in some contexts - in such cases consider providing a classifier
  to `line_breaking/2`.

  For a list of possible return values, best practices and implementation notes, you should refer to
  [UAX #14](http://www.unicode.org/reports/tr14/).

  This is sourced from [LineBreak.txt](http://www.unicode.org/Public/UNIDATA/LineBreak.txt)

  ## Examples

      iex> UnicodeData.line_breaking("\u00B4")
      "BB"
      iex> UnicodeData.line_breaking("]")
      "CP"
      iex> UnicodeData.line_breaking("\u061F")
      "EX"
      iex> UnicodeData.line_breaking(":")
      "IS"
  """
  @spec line_breaking(cp) :: String.t()
  def line_breaking(codepoint) when is_integer(codepoint) do
    Segment.line_break(codepoint)
  end

  def line_breaking(<<codepoint::utf8>>) do
    Segment.line_break(codepoint)
  end

  @doc """
  Tailors the `Line_Break` property by applying the `tailoring` function.

  This allows you to override the value that would normally be returned and is a simple way to tailor the 
  behaviour of the line breaking algorithm.
  """
  @spec line_breaking(cp, linebreak_classifier) :: String.t()
  def line_breaking(<<codepoint::utf8>>, tailoring) do
    orig = Segment.line_break(codepoint)
    tailoring.(codepoint, orig)
  end

  @doc """
  Indicate all linebreak opportunities in a string of text according to UAX 14.

  Breaks opportunities are classified as either required or allowed.
  """
  @spec linebreak_locations(String.t(), linebreak_classifier | nil, uax14_ruleset | nil) :: [
          {:required | :allowed, integer}
        ]
  def linebreak_locations(text, tailoring \\ nil, rules \\ nil) do
    tailored_classes = if tailoring == nil, do: &default_linebreak_classes/2, else: tailoring
    tailored_rules = if rules == nil, do: Segment.uax14_default_rules(), else: rules
    # |> Enum.map(fn {k, v} -> v end)
    out =
      text
      |> String.codepoints()
      |> Stream.map(fn x -> line_breaking(x, tailored_classes) end)
      |> Stream.chunk(2, 1)
      |> Enum.map_reduce(nil, fn x, acc -> Segment.uax14_break_between(x, acc, tailored_rules) end)
      |> elem(0)
      |> Stream.with_index(1)
      |> Stream.filter(fn {k, _} -> k != :prohibited end)
      |> Enum.to_list()

    out
  end

  @doc """
  This is the default tailoring of linebreak classes according to UAX #14.

  It resolves AI, CB, CJ, SA, SG, and XX into other line breaking classes in the
  absence of any other criteria.

  If you are supplying your own tailoring function, you may want unhandled cases to
  fall back to this implementation.
  """
  @spec default_linebreak_classes(cp, String.t()) :: String.t()
  def default_linebreak_classes(codepoint, original_class) do
    case original_class do
      "AI" -> "AL"
      "SG" -> "AL"
      "XX" -> "AL"
      "SA" -> if Regex.match?(~r/\p{Mn}|\p{Mc}/u, <<codepoint::utf8>>), do: "CM", else: "AL"
      "CJ" -> "NS"
      _ -> original_class
    end
  end

  @doc """
  Converts a run of text into a set of lines by implementing UAX#14, breaking only at required positions,
  and indicating allowed break positions.
  """
  @spec identify_linebreak_positions(String.t(), linebreak_classifier | nil, uax14_ruleset | nil) ::
          [{String.t(), [integer]}]
  def identify_linebreak_positions(text, tailoring \\ nil, rules \\ nil) do
    text
    |> linebreak_locations(tailoring, rules)
    |> Enum.chunk_while(
      {0, []},
      fn {break, index}, {offset, allowed} ->
        if break == :required do
          {
            :cont,
            {String.slice(text, offset, index - 1), Enum.reverse(allowed)},
            {index, []}
          }
        else
          {:cont, {offset, [index - offset | allowed]}}
        end
      end,
      fn {offset, allowed} ->
        {:cont, {String.slice(text, offset, String.length(text)), Enum.reverse(allowed)}, {0, []}}
      end
    )
  end

  @doc """
  Break a run of text into lines. It only breaks where required and ignores other break opportunities.

  This is a conforming implementation of [UAX #14](http://www.unicode.org/reports/tr14/).

  It supports tailoring the assignment of linebreak classes as well as tailoring the rules themselves.

  Converts a run of text into a set of lines by implementing UAX#14 and breaking only at required positions.
  """
  @spec apply_required_linebreaks(String.t(), linebreak_classifier | nil, uax14_ruleset | nil) ::
          [String.t()]
  def apply_required_linebreaks(text, linebreak_classification \\ nil, rules \\ nil) do
    text
    |> linebreak_locations(linebreak_classification, rules)
    |> Stream.filter(fn {k, _} -> k == :required end)
    |> Stream.chunk_while(
      0,
      fn {_, index}, offset ->
        {
          :cont,
          String.slice(text, offset, index - 1),
          index
        }
      end,
      fn offset -> {:cont, String.slice(text, offset, String.length(text)), 0} end
    )
    |> Enum.to_list()
  end

  @doc """
  The `Word_Break` property can be used to help determine word boundaries.

  [UAX #29](http://www.unicode.org/reports/tr29/) provides a simple algorithm that uses 
  this property to handle most unambiguous situations. To get better results, you should
  tailor the algorithm for the locale and context. In particular, hyphens and apostrophes
  commonly require a better understanding of the context to correctly determine if they 
  indicate a word boundary.

  For a list of possible return values, best practices and implementation notes, you should refer to
  section 4 of [UAX #29](http://www.unicode.org/reports/tr29/).

  This is sourced from [WordBreakProperty.txt](http://www.unicode.org/Public/UNIDATA/auxiliary/WordBreakProperty.txt)

  ## Examples

      iex> UnicodeData.word_breaking("B")
      "ALetter"
      iex> UnicodeData.word_breaking("\u30A1")
      "Katakana"
      iex> UnicodeData.word_breaking("\u00B4")
      "Other"
  """
  @spec word_breaking(cp) :: String.t()
  def word_breaking(codepoint) when is_integer(codepoint) do
    Segment.word_break(codepoint)
  end

  def word_breaking(<<codepoint::utf8>>) do
    word_breaking(codepoint)
  end

  @doc """
  The `Sentence_Break` property can be used to help determine sentence boundaries.

  [UAX #29](http://www.unicode.org/reports/tr29/) provides a simple algorithm that uses this property to 
  handle most unambiguous situations. If the locale is known, information in the [CLDR](http://cldr.unicode.org/index)
  can be used to improve the quality of boundary analysis.

  This is sourced from [SentenceBreakProperty.txt](http://www.unicode.org/Public/UNIDATA/auxiliary/SentenceBreakProperty.txt)

  For a list of possible return values, best practices and implementation notes, you should refer to
  section 5 of [UAX #29](http://www.unicode.org/reports/tr29/).

  ## Examples

      iex> UnicodeData.sentence_breaking(" ")
      "Sp"
      iex> UnicodeData.sentence_breaking("?")
      "STerm"
      iex> UnicodeData.sentence_breaking("]")
      "Close"
  """
  @spec sentence_breaking(cp) :: String.t()
  def sentence_breaking(codepoint) when is_integer(codepoint) do
    Segment.sentence_break(codepoint)
  end

  def sentence_breaking(<<codepoint::utf8>>) do
    sentence_breaking(codepoint)
  end

  # TODO: UAX11 East_Asian_Width
  # EastAsianWidth.txt

  @doc """
  The `Vertical_Orientation` property indicates the default character orientation when laying out vertical text.

  This is intended to be a reasonable or legible default to use when laying out plain text in vertical columns.
  A text layout program may need to consider the script, style, or context rather than relying exclusively on
  the value of this property.

  For more details, including a table of representative glyphs for the `Tu` and `Tr` values, see 
  [UAX #50](http://www.unicode.org/reports/tr50/).

  It returns one of the following values:
  * `U` Upright - The character is typically displayed upright (not rotated).
  * `R` Rotated - The character is typically displayed sideways (rotated 90 degrees).
  * `Tu` Typographically upright - Uses a different (unspecified) glyph but falls back to upright display.
  * `Tr` Typographically rotated - Uses a different (unspecified) glyph but falls back to rotated display.

  This is sourced from [VerticalOrientation.txt](http://www.unicode.org/Public/UNIDATA/VerticalOrientation.txt)

  ## Examples

      iex> UnicodeData.vertical_orientation("$")
      "R"
      iex> UnicodeData.vertical_orientation("\u00A9")
      "U"
      iex> UnicodeData.vertical_orientation("\u300A")
      "Tr"
      iex> UnicodeData.vertical_orientation("\u3083")
      "Tu"
  """
  @spec vertical_orientation(cp) :: String.t()
  def vertical_orientation(codepoint) when is_integer(codepoint) do
    Vertical.orientation(codepoint)
  end

  def vertical_orientation(<<codepoint::utf8>>) do
    vertical_orientation(codepoint)
  end

  @doc """
  The `East_Asian_Width` property is useful when interoperating with legacy East Asian encodings or fixed pitch fonts.

  This is an informative property that a layout engine may wish to use when tailoring line breaking or laying out vertical
  text runs. Refer to [UAX #11](http://www.unicode.org/reports/tr11/) for a discussion and guidelines around its usage.

  This is sourced from [EastAsianWidth.txt](http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt)

  ## Examples
      iex> UnicodeData.east_asian_width("$")
      "Na"
      iex> UnicodeData.east_asian_width("\u00AE")
      "A"
      iex> UnicodeData.east_asian_width("\u2B50")
      "W"

  """
  @spec east_asian_width(cp) :: String.t()
  def east_asian_width(codepoint) when is_integer(codepoint) do
    Vertical.east_asian_width(codepoint)
  end

  def east_asian_width(<<codepoint::utf8>>) do
    east_asian_width(codepoint)
  end
end
