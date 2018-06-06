# UnicodeData

[![pipeline status](https://gitlab.com/jbowtie/unicode_data/badges/master/pipeline.svg)](https://gitlab.com/jbowtie/unicode_data/commits/master)
[![coverage report](https://gitlab.com/jbowtie/unicode_data/badges/master/coverage.svg)](https://gitlab.com/jbowtie/unicode_data/commits/master)
[![Inline docs](http://inch-ci.org/github/jbowtie/unicode_data.svg)](http://inch-ci.org/github/jbowtie/unicode_data)
[![Hex Version](https://img.shields.io/hexpm/v/unicode_data.svg)](https://hex.pm/packages/unicode_data)

This Elixir module provides access to additional Unicode properties required to support
text layout and analysis tasks. Script identification, cursive joining, line breaking,
and text segmentation are common tasks where the String module just doesn't provide
adequate information.

It also provides a default, compliant implementation of the Unicode line breaking algorithm
that can be tailored as needed.

## Installation

The package can be installed by adding `unicode_data` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:unicode_data, "~> 0.6.0"}]
end
```

* [Documentation](https://hexdocs.pm/unicode_data)

