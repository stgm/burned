# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table(:threads) do
      add_column :pinned_at, DateTime
    end
  end
end
