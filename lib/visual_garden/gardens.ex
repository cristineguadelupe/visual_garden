defmodule VisualGarden.Gardens do
  @moduledoc """
  The Gardens context.
  """

  import Ecto.Query, warn: false
  alias VisualGarden.Gardens.PlannerEntry
  alias VisualGarden.MyDateTime
  alias VisualGarden.Gardens.EventLog
  alias VisualGarden.Gardens.GardenUser
  alias VisualGarden.Repo

  alias VisualGarden.Gardens.Garden
  alias VisualGarden.Planner

  def create_garden_user(garden, user) do
    params = %{garden_id: garden.id, user_id: user.id}

    %GardenUser{}
    |> GardenUser.changeset(params)
    |> Repo.insert()
  end

  def get_garden_user(garden, user) do
    Repo.one(
      from gu in GardenUser,
        where: gu.garden_id == ^garden.id and gu.user_id == ^user.id
    )
  end

  def list_garden_users(garden) do
    Repo.all(
      from gu in GardenUser,
        where: gu.garden_id == ^garden.id
    )
    |> Repo.preload([:user])
  end

  def delete_garden_user(%GardenUser{} = gu) do
    Repo.delete(gu)
  end

  @doc """
  Returns the list of gardens.

  ## Examples

      iex> list_gardens()
      [%Garden{}, ...]

  """
  def list_gardens(user \\ nil) do
    if user do
      Repo.all(
        from g in Garden,
          left_join: gu in GardenUser,
          on: gu.garden_id == g.id,
          where: g.owner_id == ^user.id or gu.user_id == ^user.id
      )
    else
      []
    end
  end

  def list_public_gardens(user \\ nil) do
    user_garden_ids = list_gardens(user) |> Enum.map(& &1.id)

    Repo.all(from g in Garden, where: g.visibility == :public)
    |> Enum.reject(&(&1.id in user_garden_ids))
  end

  @doc """
  Gets a single garden.

  Raises `Ecto.NoResultsError` if the Garden does not exist.

  ## Examples

      iex> get_garden!(123)
      %Garden{}

      iex> get_garden!(456)
      ** (Ecto.NoResultsError)

  """
  def get_garden!(id), do: Repo.get!(Garden, id)

  @doc """
  Creates a garden.

  ## Examples

      iex> create_garden(%{field: value})
      {:ok, %Garden{}}

      iex> create_garden(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_garden(attrs \\ %{}) do
    %Garden{}
    |> Garden.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a garden.

  ## Examples

      iex> update_garden(garden, %{field: new_value})
      {:ok, %Garden{}}

      iex> update_garden(garden, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_garden(%Garden{} = garden, attrs) do
    garden
    |> Garden.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a garden.

  ## Examples

      iex> delete_garden(garden)
      {:ok, %Garden{}}

      iex> delete_garden(garden)
      {:error, %Ecto.Changeset{}}

  """
  def delete_garden(%Garden{} = garden) do
    Repo.delete(garden)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking garden changes.

  ## Examples

      iex> change_garden(garden)
      %Ecto.Changeset{data: %Garden{}}

  """
  def change_garden(%Garden{} = garden, attrs \\ %{}) do
    Garden.changeset(garden, attrs)
  end

  alias VisualGarden.Gardens.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Products{}, ...]

  """
  def list_products(garden_id) do
    Repo.all(from p in Product, where: p.garden_id == ^garden_id)
  end

  def list_beds(garden_id) do
    Repo.all(from p in Product, where: p.garden_id == ^garden_id and p.type == :bed)
  end

  def get_last_water_for_bed(bed_id) do
    Repo.one(
      from event in EventLog,
        where: event.event_type in [:water, :humidity] and event.product_id == ^bed_id,
        order_by: [desc: :event_time],
        limit: 1
    )
  end

  def get_last_media_for_bed(bed_id) do
    Repo.one(
      from event in EventLog,
        where:
          event.event_type == :transfer and event.product_id == ^bed_id and
            event.transferred_to_id == ^bed_id,
        order_by: [desc: :event_time],
        limit: 1
    )
  end

  @doc """
  Gets a single products.

  Raises `Ecto.NoResultsError` if the Products does not exist.

  ## Examples

      iex> get_products!(123)
      %Products{}

      iex> get_products!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a products.

  ## Examples

      iex> create_products(%{field: value})
      {:ok, %Products{}}

      iex> create_products(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}, garden) do
    garden
    |> Ecto.build_assoc(:products)
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a products.

  ## Examples

      iex> update_products(products, %{field: new_value})
      {:ok, %Products{}}

      iex> update_products(products, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a products.

  ## Examples

      iex> delete_products(products)
      {:ok, %Products{}}

      iex> delete_products(products)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking products changes.

  ## Examples

      iex> change_products(products)
      %Ecto.Changeset{data: %Products{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  alias VisualGarden.Gardens.Seed

  @doc """
  Returns the list of seeds.

  ## Examples

      iex> list_seeds()
      [%Seed{}, ...]

  """
  def list_seeds(garden_id) do
    Repo.all(from s in Seed, where: s.garden_id == ^garden_id, preload: [:harvest_species])
  end

  @doc """
  Gets a single seed.

  Raises `Ecto.NoResultsError` if the Seed does not exist.

  ## Examples

      iex> get_seed!(123)
      %Seed{}

      iex> get_seed!(456)
      ** (Ecto.NoResultsError)

  """
  def get_seed!(id), do: Repo.get!(Seed, id)

  def get_seed_by_library_seed(lseed_id, garden_id) do
    Repo.one(
      from s in Seed,
        where: s.library_seed_id == ^lseed_id and s.garden_id == ^garden_id
    )
  end

  @doc """
  Creates a seed.

  ## Examples

      iex> create_seed(%{field: value})
      {:ok, %Seed{}}

      iex> create_seed(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seed(attrs \\ %{}) do
    %Seed{}
    |> Seed.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a seed.

  ## Examples

      iex> update_seed(seed, %{field: new_value})
      {:ok, %Seed{}}

      iex> update_seed(seed, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seed(%Seed{} = seed, attrs) do
    seed
    |> Seed.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a seed.

  ## Examples

      iex> delete_seed(seed)
      {:ok, %Seed{}}

      iex> delete_seed(seed)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seed(%Seed{} = seed) do
    Repo.delete(seed)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seed changes.

  ## Examples

      iex> change_seed(seed)
      %Ecto.Changeset{data: %Seed{}}

  """
  def change_seed(%Seed{} = seed, attrs \\ %{}) do
    Seed.changeset(seed, attrs)
  end

  alias VisualGarden.Gardens.Plant

  def archive_plant(plant) do
    pe = Planner.get_planner_entry_by_plant(plant.id)
    product = get_product!(plant.product_id)
    garden = get_garden!(product.garden_id)

    if pe do
      Planner.update_planner_entry(pe, garden, %{
        days_to_refuse: Timex.diff(MyDateTime.utc_today(), pe.end_plant_date, :days),
        days_to_maturity: Timex.diff(MyDateTime.utc_today(), pe.start_plant_date, :days)
      })
    end

    plant
    |> Plant.changeset(%{archived: true})
    |> Repo.update()
  end

  @doc """
  Returns the list of plants.

  """
  def list_plants(garden_id) do
    Repo.all(
      from p in Plant,
        join: product in Product,
        on: product.id == p.product_id,
        where: product.garden_id == ^garden_id,
        preload: [:seed, :product]
    )
  end

  def list_plants(_garden_id, product_id) do
    Repo.all(
      from p in Plant,
        where: p.product_id == ^product_id,
        preload: [:seed, :product]
    )
  end

  def list_plants(_garden_id, product_id, row, column) do
    Repo.all(
      from p in Plant,
        where:
          p.product_id == ^product_id and
            p.row == ^row and p.column == ^column,
        preload: [:seed, :product]
    )
  end

  @doc """
  Gets a single plant.

  Raises `Ecto.NoResultsError` if the Plant does not exist.

  ## Examples

      iex> get_plant!(123)
      %Plant{}

      iex> get_plant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plant!(id), do: Repo.get!(Plant, id)

  @doc """
  Creates a plant.

  ## Examples

      iex> create_plant(%{field: value})
      {:ok, %Plant{}}

      iex> create_plant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plant(attrs \\ %{}) do
    %Plant{}
    |> Plant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plant.

  ## Examples

      iex> update_plant(plant, %{field: new_value})
      {:ok, %Plant{}}

      iex> update_plant(plant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plant(%Plant{} = plant, attrs) do
    plant
    |> Plant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plant.

  ## Examples

      iex> delete_plant(plant)
      {:ok, %Plant{}}

      iex> delete_plant(plant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plant(%Plant{} = plant) do
    Repo.delete(plant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plant changes.

  ## Examples

      iex> change_plant(plant)
      %Ecto.Changeset{data: %Plant{}}

  """
  def change_plant(%Plant{} = plant, attrs \\ %{}) do
    Plant.changeset(plant, attrs)
  end

  alias VisualGarden.Gardens.Harvest

  @doc """
  Returns the list of harvests.

  ## Examples

      iex> list_harvests()
      [%Harvest{}, ...]

  """
  def list_harvests do
    Repo.all(Harvest)
  end

  @doc """
  Gets a single harvest.

  Raises `Ecto.NoResultsError` if the Harvest does not exist.

  ## Examples

      iex> get_harvest!(123)
      %Harvest{}

      iex> get_harvest!(456)
      ** (Ecto.NoResultsError)

  """
  def get_harvest!(id), do: Repo.get!(Harvest, id)

  @doc """
  Creates a harvest.

  ## Examples

      iex> create_harvest(%{field: value})
      {:ok, %Harvest{}}

      iex> create_harvest(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_harvest(attrs \\ %{}) do
    %Harvest{}
    |> Harvest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a harvest.

  ## Examples

      iex> update_harvest(harvest, %{field: new_value})
      {:ok, %Harvest{}}

      iex> update_harvest(harvest, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_harvest(%Harvest{} = harvest, attrs) do
    harvest
    |> Harvest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a harvest.

  ## Examples

      iex> delete_harvest(harvest)
      {:ok, %Harvest{}}

      iex> delete_harvest(harvest)
      {:error, %Ecto.Changeset{}}

  """
  def delete_harvest(%Harvest{} = harvest) do
    Repo.delete(harvest)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking harvest changes.

  ## Examples

      iex> change_harvest(harvest)
      %Ecto.Changeset{data: %Harvest{}}

  """
  def change_harvest(%Harvest{} = harvest, attrs \\ %{}) do
    Harvest.changeset(harvest, attrs)
  end

  alias VisualGarden.Gardens.EventLog

  @doc """
  Returns the list of event_logs.

  ## Examples

      iex> list_event_logs()
      [%EventLog{}, ...]

  """
  @event_preloads [:transferred_from, :transferred_to, :product, plant: [:seed]]
  def list_event_logs(product_id) do
    Repo.all(
      from e in EventLog,
        where: e.product_id == ^product_id,
        preload: ^@event_preloads
    )
  end

  def list_event_logs(product_id, plant_id) do
    Repo.all(
      from e in EventLog,
        where: e.plant_id == ^plant_id or (is_nil(e.plant_id) and e.product_id == ^product_id),
        preload: ^@event_preloads
    )
  end

  def list_event_logs(product_id, _plant_id, row, column) do
    Repo.all(
      from e in EventLog,
        where:
          e.product_id == ^product_id and
            ((e.row == ^row and e.column == ^column) or (is_nil(e.row) and is_nil(e.column))),
        left_join: p in Plant,
        on: e.plant_id == p.id,
        where: (p.row == ^row and p.column == ^column) or (is_nil(p.row) and is_nil(p.column)),
        preload: ^@event_preloads
    )
  end

  @doc """
  Gets a single event_log.

  Raises `Ecto.NoResultsError` if the Event log does not exist.

  ## Examples

      iex> get_event_log!(123)
      %EventLog{}

      iex> get_event_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_log!(id), do: Repo.get!(EventLog, id)

  @doc """
  Creates a event_log.

  ## Examples

      iex> create_event_log(%{field: value})
      {:ok, %EventLog{}}

      iex> create_event_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_log(params, attrs \\ %{})

  def create_event_log(type = "transfer", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)
    alt_attrs = Map.merge(attrs, %{"product_id" => attrs["transferred_from_id"]})

    {:ok, rec} =
      Repo.transaction(fn ->
        {:ok, _} =
          %EventLog{}
          |> EventLog.changeset_transfer(alt_attrs)
          |> Repo.insert()

        %EventLog{}
        |> EventLog.changeset_transfer(attrs)
        |> Repo.insert()
      end)

    rec
  end

  def create_event_log(type = "water", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)

    %EventLog{}
    |> EventLog.changeset_water(attrs)
    |> Repo.insert()
  end

  def create_event_log(type = "humidity", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)

    %EventLog{}
    |> EventLog.changeset_humidity(attrs)
    |> Repo.insert()
  end

  def create_event_log(type = "till", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)

    %EventLog{}
    |> EventLog.changeset_tilled(attrs)
    |> Repo.insert()
  end

  def create_event_log(type = "plant", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)

    %EventLog{}
    |> EventLog.changeset_plant(attrs)
    |> Repo.insert()
  end

  def create_event_log(type = "weed", attrs) do
    attrs = Map.merge(%{"event_type" => type}, attrs)

    %EventLog{}
    |> EventLog.changeset_weed(attrs)
    |> Repo.insert()
  end

  def create_event_logs(type = "transfer", squares, bed, params) do
    Repo.transaction(fn ->
      time = VisualGarden.MyDateTime.utc_now()

      for square <- squares do
        {row, column} = Planner.parse_square(square, bed)

        {:ok, _} =
          create_event_log(
            type,
            Enum.into(params, %{
              "event_type" => type,
              "event_time" => time,
              "row" => row,
              "column" => column,
              "product_id" => bed.id
            })
          )
      end
    end)
  end

  def create_event_logs(type = "weed", squares, bed) do
    Repo.transaction(fn ->
      time = VisualGarden.MyDateTime.utc_now()

      for square <- squares do
        {row, column} = Planner.parse_square(square, bed)

        {:ok, _} =
          create_event_log(type, %{
            "event_type" => type,
            "event_time" => time,
            "row" => row,
            "column" => column,
            "product_id" => bed.id
          })
      end
    end)
  end

  def create_event_logs(type = "trim", squares, bed) do
    Repo.transaction(fn ->
      time = VisualGarden.MyDateTime.utc_now()

      for square <- squares do
        {row, column} = Planner.parse_square(square, bed)

        {:ok, _} =
          create_event_log(type, %{
            "event_type" => type,
            "event_time" => time,
            "row" => row,
            "column" => column,
            "product_id" => bed.id
          })
      end
    end)
  end

  # def create_event_log(type, attrs \\ %{}) do
  #   attrs = Map.merge(%{event_type: type}, attrs)
  #   %EventLog{}
  #   |> EventLog.changeset(attrs)
  #   |> Repo.insert()
  # end

  @doc """
  Updates a event_log.

  ## Examples

      iex> update_event_log(event_log, %{field: new_value})
      {:ok, %EventLog{}}

      iex> update_event_log(event_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_log(%EventLog{} = event_log, attrs) do
    event_log
    |> EventLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_log.

  ## Examples

      iex> delete_event_log(event_log)
      {:ok, %EventLog{}}

      iex> delete_event_log(event_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_log(%EventLog{} = event_log) do
    Repo.delete(event_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_log changes.

  ## Examples

      iex> change_event_log(event_log)
      %Ecto.Changeset{data: %EventLog{}}

  """
  def change_event_log(event_log, attrs \\ %{}) do
    cond do
      attrs["event_type"] == "water" or attrs[:event_type] == "water" ->
        EventLog.changeset_water(event_log, attrs)

      attrs["event_type"] == "till" or attrs[:event_type] == "till" ->
        EventLog.changeset_tilled(event_log, attrs)

      attrs["event_type"] == "transfer" or attrs[:event_type] == "transfer" ->
        EventLog.changeset_transfer(event_log, attrs)
    end
  end

  # def change_event_log(%EventLog{event_type: "water"} = event_log, attrs \\ %{}) do
  #   EventLog.changeset(event_log, attrs)
  # end

  alias VisualGarden.Gardens.NurseryEntry

  @doc """
  Returns the list of nursery_entries.

  ## Examples

      iex> list_nursery_entries()
      [%NurseryEntry{}, ...]

  """
  def list_nursery_entries(garden_id) do
    Repo.all(from ne in NurseryEntry, where: ne.garden_id == ^garden_id)
  end

  @doc """
  Gets a single nursery_entry.

  Raises `Ecto.NoResultsError` if the Nursery entry does not exist.

  ## Examples

      iex> get_nursery_entry!(123)
      %NurseryEntry{}

      iex> get_nursery_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_nursery_entry!(id), do: Repo.get!(NurseryEntry, id) |> Repo.preload([:seed])

  def get_nursery_entries_not_planted(garden_id) do
    Repo.all(
      from ne in NurseryEntry,
        join: pe in PlannerEntry,
        on: ne.planner_entry_id == pe.id,
        where: not is_nil(pe.plant_id) and ne.garden_id == ^garden_id
    )
  end

  @doc """
  Creates a nursery_entry.

  ## Examples

      iex> create_nursery_entry(%{field: value})
      {:ok, %NurseryEntry{}}

      iex> create_nursery_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_nursery_entry(attrs \\ %{}) do
    %NurseryEntry{}
    |> NurseryEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a nursery_entry.

  ## Examples

      iex> update_nursery_entry(nursery_entry, %{field: new_value})
      {:ok, %NurseryEntry{}}

      iex> update_nursery_entry(nursery_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_nursery_entry(%NurseryEntry{} = nursery_entry, attrs) do
    nursery_entry
    |> NurseryEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a nursery_entry.

  ## Examples

      iex> delete_nursery_entry(nursery_entry)
      {:ok, %NurseryEntry{}}

      iex> delete_nursery_entry(nursery_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_nursery_entry(%NurseryEntry{} = nursery_entry) do
    Repo.delete(nursery_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking nursery_entry changes.

  ## Examples

      iex> change_nursery_entry(nursery_entry)
      %Ecto.Changeset{data: %NurseryEntry{}}

  """
  def change_nursery_entry(%NurseryEntry{} = nursery_entry, attrs \\ %{}) do
    NurseryEntry.changeset(nursery_entry, attrs)
  end

  def squares_options(bed) do
    for k <- 0..(bed.length * bed.width - 1) do
      {i, j} = Planner.parse_square(to_string(k), bed)
      {"#{i}, #{j}", k}
    end
    |> List.flatten()
  end

  def row_col_to_square(row, col, bed) do
    col * bed.width + row
  end

  def content_for_cell(plants, idx) do
    if p = plants[idx] do
      if q = hd(p) do
        Phoenix.HTML.html_escape(q.name)
        |> Phoenix.HTML.safe_to_string()
      else
        ""
      end
    else
      ""
    end
  end
end
