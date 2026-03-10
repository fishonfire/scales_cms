defmodule ScalesCmsWeb.SidebarStateStore do
  @moduledoc """
  SidebarStateStore is a GenServer that manages an ETS table for storing sidebar state across LiveView navigations.
  """
  use GenServer

  @table :sidebar_state

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  def table, do: @table

  @impl true
  def init(:ok) do
    tid =
      :ets.new(@table, [
        :set,
        :public,
        :named_table,
        read_concurrency: true,
        write_concurrency: true
      ])

    IO.puts("""
    [ETS] #{@table} created at app startup
    tid: #{inspect(tid)}
    owner: #{inspect(self())}
    """)

    {:ok, %{table: tid}}
  end
end
