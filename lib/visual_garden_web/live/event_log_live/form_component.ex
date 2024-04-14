defmodule VisualGardenWeb.EventLogLive.FormComponent do
  alias VisualGarden.Gardens.EventLog
  use VisualGardenWeb, :live_component

  alias VisualGarden.Gardens

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage event_log records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="event_log-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          phx-hook="EventTime"
          field={@form[:event_time_hidden]}
          type="datetime-local"
          label="Event time"
        />
        <.input
          id="event-time"
          field={@form[:event_time]}
          type="hidden"
          label="Event time"
          value={DateTime.utc_now()}
        />

        <%= if @action == :new_humidity do %>
          <.input field={@form[:humidity]} type="number" label="Humidity" />
        <% end %>
        <%!-- <.input field={@form[:mowed]} type="checkbox" label="Mowed" />
        <.input field={@form[:mow_depth_in]} type="number" label="Mow depth in" step="any" /> --%>
        <%= if @action == :till do %>
          <.input field={@form[:till_depth_in]} type="number" label="Till depth in" step="any" />
        <% end %>
        <%= if @action == :transfer do %>
          <.input
            field={@form[:transferred_from_id]}
            type="text"
            label="Transferred From"
            list="product-list"
          />

          <datalist id="product-list">
            <%= for product <- @products do %>
              <option value={product.id}><%= product.name %></option>
            <% end %>
          </datalist>

          <.input
            field={@form[:transferred_amount]}
            type="number"
            label="Transferred amount"
            step="any"
          />

          <.input
            field={@form[:transfer_units]}
            type="select"
            label="Units"
            prompt="Choose a value"
            options={Ecto.Enum.values(VisualGarden.Gardens.EventLog, :transfer_units)}
          />
        <% end %>

        <%!-- <.input field={@form[:trimmed]} type="checkbox" label="Trimmed" /> --%>
        <:actions>
          <.button phx-disable-with="Saving...">Save Event log</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp event_type_for_action(:new_water), do: "water"
  defp event_type_for_action(:till), do: "till"
  defp event_type_for_action(:transfer), do: "transfer"

  @impl true
  def update(assigns, socket) do
    el = %EventLog{}

    changeset =
      Gardens.change_event_log(el, %{"event_type" => event_type_for_action(assigns.action)})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:event_log, el)
     |> assign_form(changeset)}
  end

  defp merge_attrs(params, action, product) do
    Map.merge(
      %{
        "event_type" => event_type_for_action(action),
        "product_id" => product.id,
        "transferred_to_id" => product.id
      },
      params
    )
  end

  @impl true
  def handle_event("validate", %{"event_log" => event_log_params}, socket) do
    changeset =
      socket.assigns.event_log
      |> Gardens.change_event_log(
        merge_attrs(event_log_params, socket.assigns.action, socket.assigns.product)
      )
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"event_log" => event_log_params}, socket) do
    save_event_log(socket, socket.assigns.action, event_log_params)
  end

  # defp save_event_log(socket, :edit, event_log_params) do
  #   case Gardens.update_event_log(socket.assigns.event_log, event_log_params) do
  #     {:ok, event_log} ->
  #       notify_parent({:saved, event_log})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Event log updated successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp save_event_log(socket, :transfer, event_log_params) do
    do_save_event_log(socket, "transfer", event_log_params)
  end

  defp save_event_log(socket, :new_water, event_log_params) do
    do_save_event_log(socket, "water", event_log_params)
  end

  defp save_event_log(socket, :till, event_log_params) do
    do_save_event_log(socket, "till", event_log_params)
  end

  defp do_save_event_log(socket, type, event_log_params) do
    case Gardens.create_event_log(
           type,
           merge_attrs(event_log_params, socket.assigns.action, socket.assigns.product)
         ) do
      {:ok, event_log} ->
        notify_parent({:saved, VisualGarden.Repo.preload(event_log, :transferred_from)})

        {:noreply,
         socket
         |> put_notification(Normal.new(:info, "Event log created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
