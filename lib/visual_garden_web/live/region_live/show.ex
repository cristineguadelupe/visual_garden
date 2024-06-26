defmodule VisualGardenWeb.RegionLive.Show do
  alias VisualGarden.Gardens
  alias VisualGardenWeb.DisplayHelpers
  use VisualGardenWeb, :live_view

  alias VisualGarden.Library

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    schedules = schedules(id)

    {:noreply,
     socket
     |> assign(:can_modify?, Authorization.can_modify_library?(socket.assigns.current_user))
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:region, Library.get_region!(id))
     |> add_garden(params)
     |> assign(:schedules, schedules)}
  end

  defp add_garden(socket, params) do
    if params["garden_id"] do
      assign(socket, :garden, Gardens.get_garden!(params["garden_id"]))
    else
      socket
    end
  end

  defp schedules(id) do
    Library.list_schedules(id)
    |> Enum.group_by(& &1.species)
    |> Enum.map(fn {sp, scheds} ->
      sched_list =
        scheds
        |> Enum.map(fn sched ->
          s = Date.new!(2024, sched.start_month, sched.start_day)
          e = Date.new!(2024, sched.end_month, sched.end_day)

          if Timex.before?(e, s) do
            {sched, [Date.new!(2024, 1, 1), e, s, Date.new!(2024, 12, 31)]}
          else
            {sched, [s, e]}
          end
        end)

      types = Enum.group_by(sched_list, fn {sched, dates} -> sched.plantable_types end)

      for {type, sched} <- types do
        {sp, sched}
      end
    end)
    |> List.flatten()
  end

  def rect_for2(assigns = %{dates: [a, b]}) do
    assigns = assign(assigns, a: a)
    assigns = assign(assigns, b: b)

    ~H"""
    <rect
      y={@idx * 60}
      style="stroke-width:0.5;stroke:black"
      height="60"
      fill="rgba(1,1,1,0.2)"
      width={Timex.diff(@b, @a, :days) * 2}
      x={Timex.diff(@a, Date.new!(2024, 1, 1), :days) * 2}
    />
    """
  end

  def types_str(assigns) do
    ~H"""
    <text phx-no-format dominant-baseline="central" text-anchor="middle" x={365} y={30 + 60 * @idx}>
    <%= DisplayHelpers.species_display_string_simple(@species) %>
    [<%= for type <- Enum.intersperse(@schedule.plantable_types, ", ") do %><%= type %><% end %>]
    </text>
    """
  end

  def rect_for(assigns = %{dates: dates}) do
    pairs = Enum.chunk_every(dates, 2)

    assigns =
      assign(assigns, pairs: pairs)
      |> assign(
        types_str:
          types_str(%{schedule: assigns.schedule, species: assigns.species, idx: assigns.idx})
      )

    ~H"""
    <g>
      <%= for pair <- @pairs do %>
        <.rect_for2 dates={pair} idx={@idx} />
      <% end %>
      <%= @types_str %>
    </g>
    """
  end

  defp page_title(:show), do: "Show Region"
  defp page_title(:garden_show), do: "Show Region"
  defp page_title(:edit), do: "Edit Region"
end
