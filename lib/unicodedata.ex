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
  """

  alias UnicodeData.Script
  alias UnicodeData.Bidi

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
  @spec script_from_codepoint(integer | String.codepoint) :: String.t
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
  @spec script_to_tag(String.t) :: String.t
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
  @spec right_to_left?(String.t) :: boolean
  def right_to_left?(script) do
    as_tag = Script.right_to_left?(script)
    if as_tag do
      true
    else
      script
      |> script_to_tag
      |> Script.right_to_left?
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
  @spec uses_joining_type?(String.t) :: boolean
  def uses_joining_type?(script) do
    as_tag = Script.uses_joining_type?(script)
    if as_tag do
      true
    else
      script
      |> script_to_tag
      |> Script.uses_joining_type?
    end
  end


  @doc """
  Determine the joining type for cursive scripts.

  Cursive scripts have the following join types:
  *  `R` Right_Joining (top-joining for vertical)
  *  `L` Left_Joining (bottom-joining for vertical)
  *  `D` Dual_Joining
  *  `C` Join_Causing
  *  `U` Non_Joining
  *  `T` Transparent
  
  Characters from other scripts return `U` as they do
  not participate in cursive shaping.

  This is sourced from [ArabicShaping.txt](http://www.unicode.org/Public/UNIDATA/ArabicShaping.txt)

  ## Examples

      iex> UnicodeData.joining_type("\u0643")
      "D"
      iex> UnicodeData.joining_type("\u062F")
      "R"
      iex> UnicodeData.joining_type("\u0710")
      "R"
  """
  @spec joining_type(integer | String.codepoint) :: String.t
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
  @spec joining_group(integer | String.codepoint) :: String.t
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
  @spec bidi_class(integer | String.codepoint) :: String.t
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
  @spec bidi_mirrored?(integer | String.codepoint) :: boolean
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
  @spec bidi_mirror_codepoint(integer | String.codepoint) :: String.codepoint | nil
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
  @spec bidi_paired_bracket_type(integer | String.codepoint) :: String.t
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

  For example

  This is sourced from [BidiBrackets.txt](http://www.unicode.org/Public/UNIDATA/BidiBrackets.txt)

  ## Examples

      iex> UnicodeData.bidi_paired_bracket("[")
      "]"
      iex> UnicodeData.bidi_paired_bracket("]")
      "["
      iex> UnicodeData.bidi_paired_bracket("A")
      nil
  
  """
  @spec bidi_paired_bracket(integer | String.codepoint) :: String.codepoint | nil
  def bidi_paired_bracket(codepoint) when is_integer(codepoint) do
    val = Bidi.paired_bracket(codepoint)
    if val != nil, do: <<val::utf8>>, else: nil
  end
  def bidi_paired_bracket(<<codepoint::utf8>>) do
    bidi_paired_bracket(codepoint)
  end

  # TODO: UAX14 Line_Break
  # LineBreak.txt
  # TODO: UAX11 East_Asian_Width
  # EastAsianWidth.txt
  # TODO: UAX29 Word_Break, Sentence_Break
  # WordBreakProperty.txt
  # SentenceBreakProperty.txt
  # TODO: UAX50 Vertical_Orientation
  # VerticalOrientation.txt

end
