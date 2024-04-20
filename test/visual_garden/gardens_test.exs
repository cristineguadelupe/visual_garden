defmodule VisualGarden.GardensTest do
  use VisualGarden.DataCase

  alias VisualGarden.Gardens

  describe "gardens" do
    alias VisualGarden.Gardens.Garden

    import VisualGarden.GardensFixtures

    @invalid_attrs %{name: nil}

    test "list_gardens/0 returns all gardens" do
      garden = garden_fixture()
      assert Gardens.list_gardens() == [garden]
    end

    test "get_garden!/1 returns the garden with given id" do
      garden = garden_fixture()
      assert Gardens.get_garden!(garden.id) == garden
    end

    test "create_garden/1 with valid data creates a garden" do
      valid_attrs = %{name: "My Other Garden"}

      assert {:ok, %Garden{} = garden} = Gardens.create_garden(valid_attrs)
    end

    test "create_garden/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_garden(@invalid_attrs)
    end

    test "update_garden/2 with valid data updates the garden" do
      garden = garden_fixture()
      update_attrs = %{}

      assert {:ok, %Garden{} = garden} = Gardens.update_garden(garden, update_attrs)
    end

    test "update_garden/2 with invalid data returns error changeset" do
      garden = garden_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_garden(garden, @invalid_attrs)
      assert garden == Gardens.get_garden!(garden.id)
    end

    test "delete_garden/1 deletes the garden" do
      garden = garden_fixture()
      assert {:ok, %Garden{}} = Gardens.delete_garden(garden)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_garden!(garden.id) end
    end

    test "change_garden/1 returns a garden changeset" do
      garden = garden_fixture()
      assert %Ecto.Changeset{} = Gardens.change_garden(garden)
    end
  end

  describe "product" do
    alias VisualGarden.Gardens.Product

    import VisualGarden.GardensFixtures

    @invalid_attrs %{name: nil, type: nil}

    test "list_products/0 returns all product" do
      product = product_fixture()
      assert Gardens.list_products(product.garden_id) == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Gardens.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", type: :growing_media}
      garden = garden_fixture(%{name: "my garden"})
      assert {:ok, %Product{} = product} = Gardens.create_product(valid_attrs, garden)
      assert product.name == "some name"
      assert product.type == :growing_media
    end

    test "create_product/1 with invalid data returns error changeset" do
      garden = garden_fixture(%{name: "my garden"})
      assert {:error, %Ecto.Changeset{}} = Gardens.create_product(@invalid_attrs, garden)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", type: :fertilizer}

      assert {:ok, %Product{} = product} = Gardens.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.type == :fertilizer
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_product(product, @invalid_attrs)
      assert product == Gardens.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Gardens.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Gardens.change_product(product)
    end
  end

  describe "seeds" do
    alias VisualGarden.Gardens.Seed

    import VisualGarden.GardensFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_seeds/0 returns all seeds" do
      seed = seed_fixture()
      garden = Gardens.get_garden!(seed.garden_id)
      assert Gardens.list_seeds(garden.id) == [seed]
    end

    test "get_seed!/1 returns the seed with given id" do
      seed = seed_fixture()
      assert Gardens.get_seed!(seed.id) == seed
    end

    test "create_seed/1 with valid data creates a seed" do
      garden = garden_fixture()
      valid_attrs = %{name: "some name", description: "some description", garden_id: garden.id}

      assert {:ok, %Seed{} = seed} = Gardens.create_seed(valid_attrs)
      assert seed.name == "some name"
      assert seed.description == "some description"
    end

    test "create_seed/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_seed(@invalid_attrs)
    end

    test "update_seed/2 with valid data updates the seed" do
      seed = seed_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Seed{} = seed} = Gardens.update_seed(seed, update_attrs)
      assert seed.name == "some updated name"
      assert seed.description == "some updated description"
    end

    test "update_seed/2 with invalid data returns error changeset" do
      seed = seed_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_seed(seed, @invalid_attrs)
      assert seed == Gardens.get_seed!(seed.id)
    end

    test "delete_seed/1 deletes the seed" do
      seed = seed_fixture()
      assert {:ok, %Seed{}} = Gardens.delete_seed(seed)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_seed!(seed.id) end
    end

    test "change_seed/1 returns a seed changeset" do
      seed = seed_fixture()
      assert %Ecto.Changeset{} = Gardens.change_seed(seed)
    end
  end

  describe "plants" do
    alias VisualGarden.Gardens.Plant

    import VisualGarden.GardensFixtures

    @invalid_attrs %{qty: 0}

    test "list_plants/1 returns all plants" do
      plant = plant_fixture()
      product = Gardens.get_product!(plant.product_id)
      garden = Gardens.get_garden!(product.garden_id)
      product2 = product_fixture(%{}, garden)
      plant2 = plant_fixture(%{product_id: product2.id})
      assert Gardens.list_plants(product.garden_id) == [plant, plant2]
    end

    test "list_plants/2 returns all plants in product" do
      plant = plant_fixture()
      product = Gardens.get_product!(plant.product_id)
      plant2 = plant_fixture(%{garden_id: product.garden_id})
      assert Gardens.list_plants(product.garden_id, product.id) == [plant]
    end

    test "get_plant!/1 returns the plant with given id" do
      plant = plant_fixture()
      assert Gardens.get_plant!(plant.id) == plant
    end

    test "create_plant/1 with valid data creates a plant" do
      product = product_fixture()
      valid_attrs = %{product_id: product.id, name: "my plant"}

      assert {:ok, %Plant{} = plant} = Gardens.create_plant(valid_attrs)
    end

    test "create_plant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_plant(@invalid_attrs)
    end

    test "update_plant/2 with valid data updates the plant" do
      plant = plant_fixture()
      update_attrs = %{}

      assert {:ok, %Plant{} = plant} = Gardens.update_plant(plant, update_attrs)
    end

    test "update_plant/2 with invalid data returns error changeset" do
      plant = plant_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_plant(plant, @invalid_attrs)
      assert plant == Gardens.get_plant!(plant.id)
    end

    test "delete_plant/1 deletes the plant" do
      plant = plant_fixture()
      assert {:ok, %Plant{}} = Gardens.delete_plant(plant)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_plant!(plant.id) end
    end

    test "change_plant/1 returns a plant changeset" do
      plant = plant_fixture()
      assert %Ecto.Changeset{} = Gardens.change_plant(plant)
    end
  end

  describe "harvests" do
    alias VisualGarden.Gardens.Harvest

    import VisualGarden.GardensFixtures

    @invalid_attrs %{quantity: nil, units: nil}

    test "list_harvests/0 returns all harvests" do
      harvest = harvest_fixture()
      assert Gardens.list_harvests() == [harvest]
    end

    test "get_harvest!/1 returns the harvest with given id" do
      harvest = harvest_fixture()
      assert Gardens.get_harvest!(harvest.id) == harvest
    end

    test "create_harvest/1 with valid data creates a harvest" do
      valid_attrs = %{quantity: "120.5", units: "some units"}

      assert {:ok, %Harvest{} = harvest} = Gardens.create_harvest(valid_attrs)
      assert harvest.quantity == Decimal.new("120.5")
      assert harvest.units == "some units"
    end

    test "create_harvest/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_harvest(@invalid_attrs)
    end

    test "update_harvest/2 with valid data updates the harvest" do
      harvest = harvest_fixture()
      update_attrs = %{quantity: "456.7", units: "some updated units"}

      assert {:ok, %Harvest{} = harvest} = Gardens.update_harvest(harvest, update_attrs)
      assert harvest.quantity == Decimal.new("456.7")
      assert harvest.units == "some updated units"
    end

    test "update_harvest/2 with invalid data returns error changeset" do
      harvest = harvest_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_harvest(harvest, @invalid_attrs)
      assert harvest == Gardens.get_harvest!(harvest.id)
    end

    test "delete_harvest/1 deletes the harvest" do
      harvest = harvest_fixture()
      assert {:ok, %Harvest{}} = Gardens.delete_harvest(harvest)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_harvest!(harvest.id) end
    end

    test "change_harvest/1 returns a harvest changeset" do
      harvest = harvest_fixture()
      assert %Ecto.Changeset{} = Gardens.change_harvest(harvest)
    end
  end

  describe "event_logs" do
    alias VisualGarden.Gardens.EventLog

    import VisualGarden.GardensFixtures

    @invalid_attrs %{event_type: nil, watered: nil, humidity: nil, mowed: nil, mow_depth_in: nil, tilled: nil, till_depth_in: nil, transferred_amount: nil, trimmed: nil, transfer_units: nil}

    test "list_event_logs/0 returns all event_logs" do
      event_log = event_log_fixture()
      assert Gardens.list_event_logs() == [event_log]
    end

    test "get_event_log!/1 returns the event_log with given id" do
      event_log = event_log_fixture()
      assert Gardens.get_event_log!(event_log.id) == event_log
    end

    test "create_event_log/1 with valid data creates a event_log" do
      valid_attrs = %{event_type: "some event_type", watered: true, humidity: 42, mowed: true, mow_depth_in: "120.5", tilled: true, till_depth_in: "120.5", transferred_amount: "120.5", trimmed: true, transfer_units: "some transfer_units"}

      assert {:ok, %EventLog{} = event_log} = Gardens.create_event_log(valid_attrs)
      assert event_log.event_type == "some event_type"
      assert event_log.watered == true
      assert event_log.humidity == 42
      assert event_log.mowed == true
      assert event_log.mow_depth_in == Decimal.new("120.5")
      assert event_log.tilled == true
      assert event_log.till_depth_in == Decimal.new("120.5")
      assert event_log.transferred_amount == Decimal.new("120.5")
      assert event_log.trimmed == true
      assert event_log.transfer_units == "some transfer_units"
    end

    test "create_event_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_event_log(@invalid_attrs)
    end

    test "update_event_log/2 with valid data updates the event_log" do
      event_log = event_log_fixture()
      update_attrs = %{event_type: "some updated event_type", watered: false, humidity: 43, mowed: false, mow_depth_in: "456.7", tilled: false, till_depth_in: "456.7", transferred_amount: "456.7", trimmed: false, transfer_units: "some updated transfer_units"}

      assert {:ok, %EventLog{} = event_log} = Gardens.update_event_log(event_log, update_attrs)
      assert event_log.event_type == "some updated event_type"
      assert event_log.watered == false
      assert event_log.humidity == 43
      assert event_log.mowed == false
      assert event_log.mow_depth_in == Decimal.new("456.7")
      assert event_log.tilled == false
      assert event_log.till_depth_in == Decimal.new("456.7")
      assert event_log.transferred_amount == Decimal.new("456.7")
      assert event_log.trimmed == false
      assert event_log.transfer_units == "some updated transfer_units"
    end

    test "update_event_log/2 with invalid data returns error changeset" do
      event_log = event_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_event_log(event_log, @invalid_attrs)
      assert event_log == Gardens.get_event_log!(event_log.id)
    end

    test "delete_event_log/1 deletes the event_log" do
      event_log = event_log_fixture()
      assert {:ok, %EventLog{}} = Gardens.delete_event_log(event_log)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_event_log!(event_log.id) end
    end

    test "change_event_log/1 returns a event_log changeset" do
      event_log = event_log_fixture()
      assert %Ecto.Changeset{} = Gardens.change_event_log(event_log)
    end
  end
end
