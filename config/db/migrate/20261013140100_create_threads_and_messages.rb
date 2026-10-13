# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :threads do
      primary_key :id
      foreign_key :team_id, :teams, null: false, on_delete: :cascade
      foreign_key :created_by_id, :users, on_delete: :set_null
      foreign_key :source_thread_id, :threads, on_delete: :set_null
      column :title, String, null: false
      column :last_message_at, DateTime, null: false
      column :created_at, DateTime, null: false
      index [:team_id, :last_message_at]
    end

    create_table :messages do
      primary_key :id
      foreign_key :thread_id, :threads, null: false, on_delete: :cascade
      foreign_key :user_id, :users, on_delete: :set_null
      foreign_key :linked_thread_id, :threads, on_delete: :set_null
      column :kind, String, null: false, default: "text"
      column :body, String, text: true, null: false, default: ""
      column :created_at, DateTime, null: false
      index [:thread_id, :id]
    end

    create_table :mentions do
      primary_key :id
      foreign_key :message_id, :messages, null: false, on_delete: :cascade
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      index [:user_id, :message_id], unique: true
    end

    # Holds how loudly a thread bubbles up for one person, and how far they have read.
    create_table :thread_states do
      primary_key :id
      foreign_key :thread_id, :threads, null: false, on_delete: :cascade
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      column :level, String, null: false, default: "all"
      column :last_read_id, Integer, null: false, default: 0
      index [:thread_id, :user_id], unique: true
      index :user_id
    end
  end
end
