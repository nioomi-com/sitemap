defmodule Sitemap.Adapters.ETS do
  @behaviour Sitemap.Adapters.Behaviour

  def write(:indexfile, data), do: nil

  def write(:file, data) do
    :dets.open_file(:sitemap, type: :set)

    :dets.insert(:sitemap, {"sitemap", [:os.system_time(:seconds), data]})
  end
end
