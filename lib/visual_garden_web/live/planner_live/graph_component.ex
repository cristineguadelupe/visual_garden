defmodule VisualGardenWeb.PlannerLive.GraphComponent do
  use VisualGardenWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <svg viewBox="0 0 600 100" xmlns="http://www.w3.org/2000/svg">
      <%= for mo <- generate_months(@garden.tz, @extent_dates) do %>
        <rect
          width={mo.days_in_month}
          height="25"
          x={40 + x_shift(mo.mo_num, @garden.tz, @extent_dates)}
          style="stroke-width:0.5;stroke:black"
          fill="none"
        >
        </rect>
        <text y="13" x={40 + x_shift(mo.mo_num, @garden.tz, @extent_dates) + 3} style="font-size:11px;">
          <%= mo.month_name %>
        </text>
      <% end %>
      <%= for i <- 0..(@bed.length - 1) do %>
        <%= for j <- 0..(@bed.width - 1) do %>
          <text y={13 + 25 + 25 * (i * @bed.width + j)} x="0" style="font-size:11px;">
            Sq <%= i %>, <%= j %>
          </text>
        <% end %>
      <% end %>
      <%= for entry <- @planner_entries do %>
        <.link patch={~p"/planner/foo"}>
          <rect
            width={entry.days_to_maturation}
            height="25"
            y={25 + 25 * (entry.square - 1)}
            style="fill:yellow;"
            class="crop-span"
            x={40 + x_shift_date(entry.plant_date, @garden.tz, @extent_dates)}
          >
          </rect>
          <text
            dominant-baseline="central"
            text-anchor="middle"
            x={40 + x_shift_date(entry.plant_date, @garden.tz, @extent_dates) + entry.days_to_maturation / 2}
            y={25 + 25 * (entry.square - 1) + 25 / 2}
            style="font-size: 11px"
          >
            <%= entry.crop_name %>
          </text>
        </.link>

        <%= for {group, spans} <- generate_available_regions(@planner_entries, @extent_dates) do %>
          <%= for %{start_date: a, finish_date: b} <- spans do %>
            <.link patch={~p"/planner/foo"}>
              <rect
                width={Timex.diff(b, a, :days)}
                height="25"
                y={25 + 25 * (group - 1)}
                class="new-crop-span"
                x={40 + x_shift_date(a, @garden.tz, @extent_dates)}
              >
              </rect>
            </.link>
          <% end %>
        <% end %>
      <% end %>
    </svg>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def months_in_extent({start_d, end_d}) do
    Timex.diff(end_d, start_d, :months)
  end

  def generate_months(tz, extent_dates) do
    days = {start_d, _} = extent_dates

    for mo <- 1..months_in_extent(days) do
      ed =
        start_d
        |> Timex.shift(months: mo - 1)

      days_in_month =
        ed |> Timex.days_in_month()

      month_name = Timex.month_shortname(ed.month)

      %{
        days_in_month: days_in_month,
        month_name: month_name,
        mo_num: mo
      }
    end
  end

  def x_shift(mo, tz, extent_dates) do
    {start_d, _end_d} = extent_dates

    beg = start_d

    en =
      start_d
      |> Timex.shift(months: mo - 1)
      |> Timex.shift(days: -1)
      |> Timex.end_of_month()

    Timex.diff(en, beg, :days)
  end

  def x_shift_date(date, tz, extent_dates) do
    {start_d, _} = extent_dates
    Timex.diff(date, start_d, :days)
  end

  def clamp_date(start, en, date) do
    case Timex.diff(date, start, :days) do
      b when b > 0 ->
        case Timex.diff(en, date) do
          c when c > 0 -> date
          _ -> en
        end

      _ ->
        start
    end
  end

  @num_squares 3

  defp generate_available_regions(entries, extent_dates) do
    {sd, ed} = extent_dates

    grouped =
      entries
      |> Enum.group_by(& &1.square)

    grouped =
      Enum.map(1..@num_squares, fn
        square_num ->
          case grouped[square_num] do
            nil -> {square_num, []}
            _el -> {square_num, grouped[square_num]}
          end
      end)
      |> Enum.into(%{})

    for {group, es} <- grouped, into: %{} do
      plant_dates = Enum.map(es, & &1.plant_date)
      days = Enum.map(es, & &1.days_to_maturation)

      pairs =
        for {date, days} <- Enum.zip(plant_dates, days), do: [date, Timex.shift(date, days: days)]

      pairs = List.flatten(pairs)

      new_list =
        [Date.new!(DateTime.utc_now().year, 1, 1)] ++
          pairs ++ [Timex.end_of_year(DateTime.utc_now().year)]

      chunks = Enum.chunk_every(new_list, 2)

      spans =
        for [a, b] <- chunks do
          %{
            start_date: clamp_date(DateTime.utc_now(), ed, a),
            finish_date: clamp_date(sd, ed, b)
          }
        end

      {group, spans}
    end
  end
end
