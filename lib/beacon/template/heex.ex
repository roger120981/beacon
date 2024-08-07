defmodule Beacon.Template.HEEx do
  @moduledoc """
  Handles loading and compilation of HEEx templates.
  """

  @doc """
  Compile `template` returning its AST.
  """
  @spec compile(Beacon.Types.Site.t(), String.t(), String.t()) :: {:ok, Beacon.Template.ast()} | {:error, Exception.t()}
  def compile(site, path, template, file \\ nil) when is_atom(site) and is_binary(path) and is_binary(template) do
    file = if file, do: file, else: "site-#{site}-path-#{path}"
    compile_template(site, file, template)
  end

  def compile!(site, path, template, file \\ nil) when is_atom(site) and is_binary(path) and is_binary(template) do
    case compile(site, path, template, file) do
      {:ok, ast} -> ast
      {:error, exception} -> raise exception
    end
  end

  defp compile_template(site, file, template) do
    opts = [
      engine: Phoenix.LiveView.TagEngine,
      line: 1,
      indentation: 0,
      file: file,
      caller: Beacon.Web.PageLive.make_env(site),
      source: template,
      trim: true,
      tag_handler: Phoenix.LiveView.HTMLEngine
    ]

    {:ok, EEx.compile_string(template, opts)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Renders the HEEx `template` with `assigns`.

  > #### Use only to render isolated templates {: .warning}
  >
  > This function should not be used to render Page Templates,
  > its purpose is only to render isolated pieces of templates.

  ## Example

      iex> Beacon.Template.HEEx.render(:my_site, ~S|<.link patch="/contact" replace={true}><%= @text %></.link>|, %{text: "Book Meeting"})
      "<a href=\"/contact\" data-phx-link=\"patch\" data-phx-link-state=\"replace\">Book Meeting</a>"

  """
  @spec render(Beacon.Types.Site.t(), String.t(), map()) :: String.t()
  def render(site, template, assigns \\ %{}) when is_atom(site) and is_binary(template) and is_map(assigns) do
    assigns =
      assigns
      |> Map.new()
      |> Map.put_new(:__changed__, %{})

    env = Beacon.Web.PageLive.make_env(site)

    {:ok, ast} = compile(site, "", template)
    {rendered, _} = Code.eval_quoted(ast, [assigns: assigns], env)

    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
