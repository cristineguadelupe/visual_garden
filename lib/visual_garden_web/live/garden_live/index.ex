defmodule VisualGardenWeb.GardenLive.Index do
  use VisualGardenWeb, :live_view

  alias VisualGarden.Gardens
  alias VisualGarden.Gardens.Garden

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:public_gardens, Gardens.list_public_gardens(socket.assigns.current_user))
     |> stream(:gardens, Gardens.list_gardens(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    Authorization.authorize_garden_view(id, socket.assigns.current_user)

    socket
    |> assign(:page_title, "Edit Garden")
    |> assign(:garden, Gardens.get_garden!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Garden")
    |> assign(:garden, %Garden{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Gardens")
    |> assign(:garden, nil)
  end

  @impl true
  def handle_info({VisualGardenWeb.GardenLive.FormComponent, {:saved, garden}}, socket) do
    {:noreply, stream_insert(socket, :gardens, garden)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Authorization.authorize_garden_view(id, socket.assigns.current_user)
    garden = Gardens.get_garden!(id)
    {:ok, _} = Gardens.delete_garden(garden)

    {:noreply, stream_delete(socket, :gardens, garden)}
  end
end
