# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id
      column :email, String, null: false, unique: true
      column :name, String
      column :handle, String, unique: true
      column :look, Integer, null: false, default: 0
      column :admin, TrueClass, null: false, default: false
      column :invited_at, DateTime
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end

    create_table :login_codes do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      column :digest, String, null: false
      column :attempts, Integer, null: false, default: 0
      column :expires_at, DateTime, null: false
      column :created_at, DateTime, null: false
      index :user_id
    end

    create_table :teams do
      primary_key :id
      column :name, String, null: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end

    create_table :memberships do
      primary_key :id
      foreign_key :team_id, :teams, null: false, on_delete: :cascade
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      foreign_key :invited_by_id, :users, on_delete: :set_null
      column :status, String, null: false, default: "invited"
      column :admin, TrueClass, null: false, default: false
      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
      index [:team_id, :user_id], unique: true
      index :user_id
    end
  end
end
