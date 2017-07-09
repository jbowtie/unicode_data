defmodule UnicodedataTest do
  use ExUnit.Case
  doctest UnicodeData

  test "recognize Latin codepoints" do
    assert UnicodeData.script_from_codepoint("a") == "Latin"
    # LOWER CASE A WITH ACUTE MARK
    assert UnicodeData.script_from_codepoint("\u0225") == "Latin"
  end
  test "recognize Arabic codepoints" do
    assert UnicodeData.script_from_codepoint("\u0643") == "Arabic"
  end
  test "recognize Common codepoints" do
    # number 9
    assert UnicodeData.script_from_codepoint("9") == "Common"
    # chess symbol
    assert UnicodeData.script_from_codepoint("\u{2654}") == "Common"
    # math symbol
    assert UnicodeData.script_from_codepoint("\u{2203}") == "Common"
    # breastfeeding emoji (Unicode 10.0)
    assert UnicodeData.script_from_codepoint("\u{1F931}") == "Common"
  end
  test "recognize Adlam codepoints" do
    # Adlam character (Unicode 9.0)
    assert UnicodeData.script_from_codepoint("\u{1E922}") == "Adlam"
  end
  test "recognize Nushu codepoints" do
    # Nushu character (Unicode 10.0)
    assert UnicodeData.script_from_codepoint("\u{1B245}") == "Nushu"
  end

  test "determine join_type" do
    assert UnicodeData.joining_type("a") == "U"
    assert UnicodeData.joining_type("\u0643") == "D"
    assert UnicodeData.joining_type("\u0710") == "R"
  end

  test "determine join_group" do
    assert UnicodeData.joining_group("a") == "No_Joining_Group"
    assert UnicodeData.joining_group("\u0643") == "KAF"
  end
end
