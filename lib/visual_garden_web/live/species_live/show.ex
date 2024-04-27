defmodule VisualGardenWeb.SpeciesLive.Show do
  use VisualGardenWeb, :live_view

  alias VisualGarden.Library

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:species, Library.get_species!(id))}
  end

  defp page_title(:show), do: "Show Species"
  defp page_title(:edit), do: "Edit Species"

  defp cultivar(species) do
    case species.cultivar do
      nil -> ""
      cultivar -> "'#{cultivar}'"
    end
  end
end
