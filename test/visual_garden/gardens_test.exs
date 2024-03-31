defmodule VisualGarden.GardensTest do
  use VisualGarden.DataCase

  alias VisualGarden.Gardens

  describe "gardens" do
    alias VisualGarden.Gardens.Garden

    import VisualGarden.GardensFixtures

    @invalid_attrs %{}

    test "list_gardens/0 returns all gardens" do
      garden = garden_fixture()
      assert Gardens.list_gardens() == [garden]
    end

    test "get_garden!/1 returns the garden with given id" do
      garden = garden_fixture()
      assert Gardens.get_garden!(garden.id) == garden
    end

    test "create_garden/1 with valid data creates a garden" do
      valid_attrs = %{}

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

  describe "products" do
    alias VisualGarden.Gardens.Products

    import VisualGarden.GardensFixtures

    @invalid_attrs %{name: nil, type: nil}

    test "list_products/0 returns all products" do
      products = products_fixture()
      assert Gardens.list_products() == [products]
    end

    test "get_products!/1 returns the products with given id" do
      products = products_fixture()
      assert Gardens.get_products!(products.id) == products
    end

    test "create_products/1 with valid data creates a products" do
      valid_attrs = %{name: "some name", type: :growing_media}

      assert {:ok, %Products{} = products} = Gardens.create_products(valid_attrs)
      assert products.name == "some name"
      assert products.type == :growing_media
    end

    test "create_products/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Gardens.create_products(@invalid_attrs)
    end

    test "update_products/2 with valid data updates the products" do
      products = products_fixture()
      update_attrs = %{name: "some updated name", type: :fertilizer}

      assert {:ok, %Products{} = products} = Gardens.update_products(products, update_attrs)
      assert products.name == "some updated name"
      assert products.type == :fertilizer
    end

    test "update_products/2 with invalid data returns error changeset" do
      products = products_fixture()
      assert {:error, %Ecto.Changeset{}} = Gardens.update_products(products, @invalid_attrs)
      assert products == Gardens.get_products!(products.id)
    end

    test "delete_products/1 deletes the products" do
      products = products_fixture()
      assert {:ok, %Products{}} = Gardens.delete_products(products)
      assert_raise Ecto.NoResultsError, fn -> Gardens.get_products!(products.id) end
    end

    test "change_products/1 returns a products changeset" do
      products = products_fixture()
      assert %Ecto.Changeset{} = Gardens.change_products(products)
    end
  end
end
