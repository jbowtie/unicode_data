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
  """

  alias UnicodeData.Script

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
  def joining_group(codepoint) when is_integer(codepoint) do
    Script.joingroup_from_codepoint(codepoint)
  end
  def joining_group(codepoint) do
    <<intval::utf8>> = codepoint
    joining_group(intval)
  end

  # TODO: UAX9 Bidi_Class, Bidi_Paired_Bracket, Bidi_Paired_Bracket_Type,
  # Bidi_Mirroring_Glyph, Bidi_Mirrored
  # BidiMirroring.txt
  # BidiBrackets.txt
  # DerivedBidiClass.txt
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
