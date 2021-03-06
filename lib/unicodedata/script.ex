defmodule UnicodeData.Script do
  @moduledoc false
  @external_resource scripts_path = Path.join([__DIR__, "Scripts.txt"])
  lines =
    File.stream!(scripts_path, [], :line)
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
        def script_from_codepoint(unquote(x)) do
          unquote(s)
        end

      [a, b] ->
        def script_from_codepoint(n) when n in unquote(a)..unquote(b) do
          unquote(s)
        end
    end
  end

  def script_to_tag(script) do
    # This maps the Unicode Script property to an OpenType script tag
    # Data from http://www.microsoft.com/typography/otspec/scripttags.htm
    # and http://www.unicode.org/Public/UNIDATA/PropertyValueAliases.txt.
    #
    # Updated through to Unicode 12.0
    unicode_scripts = %{
      "Ahom" => "ahom",
      "Anatolian_Hieroglyphs" => "hluw",
      "Caucasian_Albanian" => "aghb",
      "Arabic" => "arab",
      "Imperial_Aramaic" => "armi",
      "Armenian" => "armn",
      "Avestan" => "avst",
      "Balinese" => "bali",
      "Bamum" => "bamu",
      "Bassa_Vah" => "bass",
      "Batak" => "batk",
      "Bengali" => ["bng2", "beng"],
      "Bopomofo" => "bopo",
      "Brahmi" => "brah",
      "Braille" => "brai",
      "Buginese" => "bugi",
      "Buhid" => "buhd",
      "Byzantine_Music" => "byzm",
      "Chakma" => "cakm",
      # "Canadian_Syllabics"=> "cans",
      "Canadian_Aboriginal" => "cans",
      "Carian" => "cari",
      "Cham" => "cham",
      "Cherokee" => "cher",
      "Coptic" => "copt",
      "Cypriot" => "cprt",
      "Cyrillic" => "cyrl",
      "Devanagari" => ["dev2", "deva"],
      "Deseret" => "dsrt",
      "Duployan" => "dupl",
      "Egyptian_Hieroglyphs" => "egyp",
      "Elbasan" => "elba",
      "Ethiopic" => "ethi",
      "Georgian" => "geor",
      "Glagolitic" => "glag",
      "Gothic" => "goth",
      "Grantha" => "gran",
      "Greek" => "grek",
      "Gujarati" => ["gjr2", "gujr"],
      "Gurmukhi" => ["gur2", "guru"],
      "Hangul" => "hang",
      "Han" => "hani",
      "Hanunoo" => "hano",
      "Hebrew" => "hebr",
      "Hiragana" => "hira",
      "Pahawh_Hmong" => "hmng",
      "Katakana_Or_Hiragana" => "hrkt",
      "Old_Italic" => "ital",
      "Javanese" => "java",
      "Kayah_Li" => "kali",
      "Katakana" => "kana",
      "Kharoshthi" => "khar",
      "Khmer" => "khmr",
      "Khojki" => "khoj",
      "Kannada" => ["knd2", "knda"],
      "Kaithi" => "kthi",
      "Tai_Tham" => "lana",
      "Lao" => "lao ",
      "Latin" => "latn",
      "Lepcha" => "lepc",
      "Limbu" => "limb",
      "Linear_A" => "lina",
      "Linear_B" => "linb",
      "Lisu" => "lisu",
      "Lycian" => "lyci",
      "Lydian" => "lydi",
      "Mahajani" => "mahj",
      "Mandaic" => "mand",
      "Manichaean" => "mani",
      "Mende_Kikakui" => "mend",
      "Meroitic_Cursive" => "merc",
      "Meroitic_Hieroglyphs" => "mero",
      "Malayalam" => ["mlm2", "mlym"],
      "Modi" => "modi",
      "Mongolian" => "mong",
      "Mro" => "mroo",
      "Meetei_Mayek" => "mtei",
      "Myanmar" => ["mym2", "mymr"],
      "Old_North_Arabian" => "narb",
      "Nabataean" => "nbat",
      "Nko" => "nko ",
      "Ogham" => "ogam",
      "Ol_Chiki" => "olck",
      "Old_Turkic" => "orkh",
      "Odia" => ["ory2", "orya"],
      "Osmanya" => "osma",
      "Palmyrene" => "palm",
      "Pau_Cin_Hau" => "pauc",
      "Old_Permic" => "perm",
      "Phags_Pa" => "phag",
      "Inscriptional_Pahlavi" => "phli",
      "Psalter_Pahlavi" => "phlp",
      "Phoenician" => "phnx",
      "Miao" => "plrd",
      "Inscriptional_Parthian" => "prti",
      "Rejang" => "rjng",
      "Runic" => "runr",
      "Samaritan" => "samr",
      "Old_South_Arabian" => "sarb",
      "Saurashtra" => "saur",
      "Shavian" => "shaw",
      "Sharada" => "shrd",
      "Siddham" => "sidd",
      "Khudawadi" => "sind",
      "Sinhala" => "sinh",
      "Sora_Sompeng" => "sora",
      "Sundanese" => "sund",
      "Syloti_Nagri" => "sylo",
      "Syriac" => "syrc",
      "Tagbanwa" => "tagb",
      "Takri" => "takr",
      "Tai_Le" => "tale",
      "New_Tai_Lue" => "talu",
      "Tamil" => ["tml2", "taml"],
      "Tai_Viet" => "tavt",
      "Telugu" => ["tel2", "telu"],
      "Tifinagh" => "tfng",
      "Tagalog" => "tglg",
      "Thaana" => "thaa",
      "Thai" => "thai",
      "Tibetan" => "tibt",
      "Tirhuta" => "tirh",
      "Ugaritic" => "ugar",
      "Vai" => "vai ",
      "Warang_Citi" => "wara",
      "Old_Persian" => "xpeo",
      "Cuneiform" => "xsux",
      "Yi" => "yi  ",

      # Unicode 8.0
      "Hatran" => "hatr",
      "Multani" => "mult",
      "Old_Hungarian" => "hung",
      "SignWriting" => "sgnw",

      # Unicode 9.0
      "Adlam" => "adlm",
      "Bhaisuki" => "bhks",
      "Marchen" => "marc",
      "Newa" => "newa",
      "Osage" => "osge",
      "Tangut" => "tang",

      # Unicode 10.0
      "Masaram_Gondi" => "gonm",
      "Nushu" => "nshu",
      "Soyombo" => "soyo",
      "Zanabazar_Square" => "zanb",

      # Unicode 11.0
      "Hanifi_Rohingya" => "rohg",
      "Old_Sogdian" => "sogo",
      "Sogdian" => "sogd",
      "Dogra" => "dogr",
      "Gunjala_Gondi" => "gong",
      "Makasar" => "maka",
      "Medefaidrin" => "medf",

      # Unicode 12.0
      "Elymaic" => "elym",
      "Nyiakeng_Puachue_Hmong" => "hmnp",
      "Nandinagari" => "nand",
      "Wancho" => "wcho",

      # always at the bottom as they are special
      "Inherited" => "zinh",
      "Common" => "zyyy",
      "Unknown" => "zzzz"
    }

    Map.get(unicode_scripts, script, "zzzz")
  end

  # this list comes from ISO 15924
  # There's a handy sortable table on
  # https://en.wikipedia.org/wiki/ISO_15924
  #
  # Updated through to Unicode 12.0
  def right_to_left?(script) do
    rtl_scripts = [
      # unicode 7.0
      "arab",
      "hebr",
      "syrc",
      "thaa",
      "cprt",
      "khar",
      "phnx",
      "nko ",
      "lydi",
      "avst",
      "armi",
      "phli",
      "prti",
      "sarb",
      "orkh",
      "samr",
      "mand",
      "merc",
      "mero",
      "mani",
      "mend",
      "nbat",
      "narb",
      "palm",
      "phlp",
      # unicode 8.0
      "hatr",
      "hung",
      # unicode 9.0
      "adlm",
      # unicode 11.0
      "medf",
      "rohg",
      "sogd",
      "sogo",
      # unicode 12.0
      "elym"
    ]

    script in rtl_scripts
  end

  def uses_joining_type?(script) do
    joining_scripts = ["arab", "mong", "syrc", "nko ", "phag", "mand", "mani", "phlp"]
    script in joining_scripts
  end

  def detect_script(text) do
    x =
      String.codepoints(text)
      |> Stream.map(fn <<x::utf8>> -> x end)
      |> Stream.map(&script_from_codepoint(&1))
      |> Stream.filter(fn x -> !(x in ["Common", "Inherited", "Unknown"]) end)
      |> Enum.to_list()

    script = if x == [], do: "Unknown", else: hd(x)
    script_to_tag(script)
  end

  # used for cursive scripts -- Arabic, Syriac, N'Ko, Mongolian, etc
  @external_resource shaping_path = Path.join([__DIR__, "ArabicShaping.txt"])
  lines =
    File.stream!(shaping_path, [], :line)
    |> Stream.filter(&String.match?(&1, ~r/^[0-9A-F]+/))

  for line <- lines do
    [cp, _, t, join_group] = String.split(line, ~r/[\#;]/)

    cp =
      cp
      |> String.trim()
      |> Integer.parse(16)
      |> elem(0)

    join_group = String.trim(join_group)

    # use the join type unless in special-cased join group
    jt =
      if join_group in ["ALAPH", "DALATH RISH"] do
        join_group
      else
        String.trim(t)
      end

    def arabic_shaping_from_codepoint(unquote(cp)) do
      unquote(jt)
    end

    def jointype_from_codepoint(unquote(cp)) do
      unquote(String.trim(t))
    end

    def joingroup_from_codepoint(unquote(cp)) do
      unquote(join_group)
    end
  end

  def arabic_shaping_from_codepoint(_cp) do
    "U"
  end

  def jointype_from_codepoint(_cp) do
    "U"
  end

  def joingroup_from_codepoint(_cp) do
    "No_Joining_Group"
  end
end
