defmodule VisualGarden.LibraryFixtures do
  @doc """
  Generate a species.
  """
  def species_fixture(attrs \\ %{}) do
    {:ok, species} =
      attrs
      |> Enum.into(%{
        name: "some name",
        genus: "my genus"
      })
      |> VisualGarden.Library.create_species()

    species
  end

  @doc """
  Generate a region.
  """
  def region_fixture(attrs \\ %{}) do
    {:ok, region} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> VisualGarden.Library.create_region()

    region
  end

  @doc """
  Generate a schedule.
  """
  def schedule_fixture(attrs \\ %{}) do
    region =
      if attrs[:region_id] do
        nil
      else
        region_fixture()
      end

    species =
      if attrs[:species_id] do
        nil
      else
        species_fixture()
      end

    {:ok, schedule} =
      attrs
      |> Enum.into(%{
        region_id: if(region, do: region.id, else: attrs[:region_id]),
        species_id: if(species, do: species.id, else: attrs[:species_id]),
        end_day: 42,
        end_month: 42,
        end_month_adjusted: 42,
        start_day: 42,
        start_month: 42
      })
      |> VisualGarden.Library.create_schedule()

    schedule
  end

  @doc """
  Generate a library_seed.
  """
  def library_seed_fixture(attrs \\ %{}) do
    species = species_fixture()

    {:ok, library_seed} =
      attrs
      |> Enum.into(%{
        days_to_maturation: 42,
        manufacturer: "some manufacturer",
        type: :seed,
        species_id: species.id
      })
      |> VisualGarden.Library.create_library_seed()

    library_seed
  end
end
