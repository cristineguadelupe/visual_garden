defmodule VisualGarden.Planner do
  import Ecto.Query, warn: false
  alias VisualGarden.Library.Schedule
  alias VisualGarden.Library
  alias VisualGarden.Gardens
  alias VisualGarden.Repo

  def get_plantables_from_garden(bed, start_date, end_date \\ nil, today \\ nil) do
    # get seeds in garden from bed.garden_id
    # get species -> schedule map
    # get days of maturation for each seed
    seeds = Gardens.list_seeds(bed.garden_id)
    garden = Gardens.get_garden!(bed.garden_id)

    today =
      if today do
        today
      else
        Timex.now(garden.tz) |> DateTime.to_date()
      end

    species = Library.list_species_with_schedule(garden.region_id)

    schedule_ids = Enum.map(species, fn {_, id} -> id end)

    schedules_map =
      Repo.all(from s in Schedule, where: s.id in ^schedule_ids)
      |> Enum.map(&{&1.id, &1})
      |> Enum.into(%{})

    species_map =
      species
      |> Enum.map(fn {species, schedule_id} ->
        {species.id, %{species: species, schedule: schedules_map[schedule_id]}}
      end)
      |> Enum.into(%{})

    for seed <- seeds do
      %{species: species, schedule: schedule} = species_map[seed.species_id]

      {sched_start, sched_end} =
        unwrwap_dates(
          schedule.start_month,
          schedule.start_day,
          schedule.end_month,
          schedule.end_day,
          today
        )

      days = seed.days_to_maturation

      a = Timex.shift(sched_start, days: days)
      b = Timex.shift(sched_end, days: days)
      a = clamp_date(start_date, end_date, a)
      b = clamp_date(start_date, end_date, b)

      if Timex.diff(b, a, :days) < 14 do
        []
      else
        sow_start = Timex.shift(a, days: -days)
        sow_end = Timex.shift(b, days: -days)

        direct = %{
          type: seed.type,
          sow_start: sow_start,
          sow_end: sow_end,
          days: days,
          seed: seed,
          species: species
        }

        if schedule.nursery_lead_weeks_max && schedule.nursery_lead_weeks_min &&
             seed.type == :seed do
          c = Timex.shift(sow_start, days: -schedule.nursery_lead_weeks_max)
          d = Timex.shift(sow_start, days: -schedule.nursery_lead_weeks_min)

          c = clamp_date(start_date, end_date, c)
          d = clamp_date(start_date, end_date, d)

          if Timex.diff(b, a, :days) < 14 do
            [direct]
          else
            nursery = %{
              type: "nursery",
              sow_start: c,
              sow_end: d,
              days: days,
              seed: seed,
              species: species
            }

            [direct, nursery]
          end
        else
          [direct]
        end
      end
    end
    |> List.flatten()
  end

  def clamp_date(start, en, date) do
    if start == nil do
      if en == nil do
        date
      else
        case Timex.diff(en, date) do
          c when c > 0 -> date
          _ -> en
        end
      end
    end

    case Timex.diff(date, start, :days) do
      b when b > 0 ->
        if en == nil do
          date
        else
          case Timex.diff(en, date) do
            c when c > 0 -> date
            _ -> en
          end
        end

      _ ->
        start
    end
  end

  def unwrwap_dates(m1, d1, m2, d2, today) do
    start = Date.new!(today.year, m1, d1)
    endd = Date.new!(today.year, m2, d2)

    {s, e} =
      if Timex.before?(start, endd) do
        {start, endd}
      else
        {start, Timex.shift(endd, years: 1)}
      end

    if Timex.before?(e, today) do
      {Timex.shift(s, years: 1), Timex.shift(e, years: 1)}
    else
      {s, e}
    end
  end
end
