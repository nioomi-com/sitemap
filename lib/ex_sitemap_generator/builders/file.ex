defmodule ExSitemapGenerator.Builders.File do
  alias ExSitemapGenerator.Consts
  alias ExSitemapGenerator.Config
  alias ExSitemapGenerator.Builders.Url
  alias ExSitemapGenerator.Location
  require XmlBuilder

  defstruct [
    content: "",
    link_count: 0,
    news_count: 0,
  ]

  def start_link do
    Location.start_link(:file)
    Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
  end

  @doc """
  Get state
  """
  def state do
    Agent.get(__MODULE__, &(&1))
  end

  defp add_content(xml) do
    Agent.update(__MODULE__, fn s ->
      Map.update!(s, :content, &(&1 <> xml))
    end)
  end

  defp incr_count(key) do
    Agent.update(__MODULE__, fn s ->
      Map.update!(s, key, &(&1 + 1))
    end)
  end

  defp sizelimit?(content) do
    s = state

    cfg = Config.get
    r = String.length(s.content <> content) < cfg.max_sitemap_filesize
    r = r && s.link_count < cfg.max_sitemap_links
    r = r && s.news_count < cfg.max_sitemap_news
    r
  end

  def add(link, attrs \\ []) do
    content =
      Url.to_xml(link, attrs)
      |> XmlBuilder.generate

    if sizelimit?(content) do
      add_content content
      incr_count :link_count
    end
  end

  def write do
    s = state
    content = Consts.xml_header <> s.content <> Consts.xml_footer
    Location.write :file, content, s.link_count
  end

end
