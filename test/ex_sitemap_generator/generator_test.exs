Code.require_file "../../test_helper.exs", __ENV__.file

defmodule ExSitemapGenerator.GeneratorTest do

  use ExUnit.Case
  use ExSitemapGenerator
  alias ExSitemapGenerator.Builders.File

  setup do
    ExSitemapGenerator.start_link
    on_exit fn ->
      nil
    end
    # Returns extra metadata, it must be a dict
    # {:ok, hello: "world"}
  end

  test "create macro" do
    statement = create do
      false
    end
    assert {:ok, []} == statement
  end

  test "create & add" do
    create do
      add "rss",     priority: nil, changefreq: nil, lastmod: nil, mobile: true
      add "site",    priority: nil, changefreq: nil, lastmod: nil, mobile: true
      add "entry",   priority: nil, changefreq: nil, lastmod: nil, mobile: true
      add "about",   priority: nil, changefreq: nil, lastmod: nil, mobile: true
      add "contact", priority: nil, changefreq: nil, lastmod: nil, mobile: true

      assert add("link", []) == :ok
    end

    assert File.state.link_count == 6
  end

  test "add_to_index function" do
    data = [loc: "loc", lastmod: "lastmod", expires: "expires", changefreq: "changefreq", priority: 0.5]
    File.add(data)

    assert :ok == add_to_index([])
  end

  test "A lot of creating" do

    create do
      Enum.each 0..50, fn n ->
        add "rss#{n}",     priority: 0.1, changefreq: "weekly", lastmod: nil, mobile: true
        add "site#{n}",    priority: 0.2, changefreq: "always", lastmod: nil, mobile: true
        add "entry#{n}",   priority: 0.3, changefreq: "dayly", lastmod: nil, mobile: false
        add "about#{n}",   priority: 0.4, changefreq: "monthly", lastmod: nil, mobile: true
        add "contact#{n}", priority: 0.5, changefreq: "yearly", lastmod: nil, mobile: false
      end

      assert add("link", []) == :ok
    end

    assert File.state.link_count == 256
  end

end
