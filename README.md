# UnicodeData

[![Build Status](https://travis-ci.org/jbowtie/unicode_data.svg?branch=master)](https://travis-ci.org/jbowtie/unicode_data)
[![codecov](https://codecov.io/gh/jbowtie/unicode_data/branch/master/graph/badge.svg)](https://codecov.io/gh/jbowtie/unicode_data)

This Elixir module provides access to additional Unicode properties required to support
text layout and analysis tasks. Script identification, cursive joining, line breaking,
and text segmentation are common tasks where the String module just doesn't provide
adequate information.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `unicode_data` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:unicode_data, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/unicodedata](https://hexdocs.pm/unicodedata).

