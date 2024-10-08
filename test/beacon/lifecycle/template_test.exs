defmodule Beacon.Lifecycle.TemplateTest do
  use Beacon.DataCase, async: false

  use Beacon.Test
  alias Beacon.Lifecycle

  test "load_template" do
    page = %Beacon.Content.Page{
      site: :lifecycle_test,
      path: "/test/lifecycle",
      format: :markdown,
      template: "<div>{ title }</div>"
    }

    assert Lifecycle.Template.load_template(page) == "<div>beacon</div>"
  end

  test "render_template" do
    page = beacon_published_page_fixture(site: "my_site") |> Repo.preload(:variants)
    env = Beacon.Web.PageLive.make_env(:my_site)
    assert %Phoenix.LiveView.Rendered{static: ["<main>\n  <h1>my_site#home</h1>\n</main>"]} = Lifecycle.Template.render_template(page, %{}, env)
  end
end
