CREATE TABLE `schema_migrations`(`filename` varchar(255) NOT NULL PRIMARY KEY);
CREATE TABLE `users`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `email` varchar(255) NOT NULL UNIQUE,
  `name` varchar(255),
  `handle` varchar(255) UNIQUE,
  `look` integer DEFAULT(0) NOT NULL,
  `admin` boolean DEFAULT(0) NOT NULL,
  `invited_at` timestamp,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
);
CREATE TABLE `login_codes`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `digest` varchar(255) NOT NULL,
  `attempts` integer DEFAULT(0) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL
);
CREATE INDEX `login_codes_user_id_index` ON `login_codes`(`user_id`);
CREATE TABLE `teams`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
);
CREATE TABLE `memberships`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `team_id` integer NOT NULL REFERENCES `teams` ON DELETE CASCADE,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `invited_by_id` integer REFERENCES `users` ON DELETE SET NULL,
  `status` varchar(255) DEFAULT('invited') NOT NULL,
  `admin` boolean DEFAULT(0) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
);
CREATE UNIQUE INDEX `memberships_team_id_user_id_index` ON `memberships`(
  `team_id`,
  `user_id`
);
CREATE INDEX `memberships_user_id_index` ON `memberships`(`user_id`);
CREATE TABLE `threads`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `team_id` integer NOT NULL REFERENCES `teams` ON DELETE CASCADE,
  `created_by_id` integer REFERENCES `users` ON DELETE SET NULL,
  `source_thread_id` integer REFERENCES `threads` ON DELETE SET NULL,
  `title` varchar(255) NOT NULL,
  `last_message_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL
  ,
  `pinned_at` timestamp
);
CREATE INDEX `threads_team_id_last_message_at_index` ON `threads`(
  `team_id`,
  `last_message_at`
);
CREATE TABLE `messages`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `thread_id` integer NOT NULL REFERENCES `threads` ON DELETE CASCADE,
  `user_id` integer REFERENCES `users` ON DELETE SET NULL,
  `linked_thread_id` integer REFERENCES `threads` ON DELETE SET NULL,
  `kind` varchar(255) DEFAULT('text') NOT NULL,
  `body` text DEFAULT('') NOT NULL,
  `created_at` timestamp NOT NULL
);
CREATE INDEX `messages_thread_id_id_index` ON `messages`(`thread_id`, `id`);
CREATE TABLE `mentions`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `message_id` integer NOT NULL REFERENCES `messages` ON DELETE CASCADE,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE
);
CREATE UNIQUE INDEX `mentions_user_id_message_id_index` ON `mentions`(
  `user_id`,
  `message_id`
);
CREATE TABLE `thread_states`(
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `thread_id` integer NOT NULL REFERENCES `threads` ON DELETE CASCADE,
  `user_id` integer NOT NULL REFERENCES `users` ON DELETE CASCADE,
  `level` varchar(255) DEFAULT('all') NOT NULL,
  `last_read_id` integer DEFAULT(0) NOT NULL
);
CREATE UNIQUE INDEX `thread_states_thread_id_user_id_index` ON `thread_states`(
  `thread_id`,
  `user_id`
);
CREATE INDEX `thread_states_user_id_index` ON `thread_states`(`user_id`);
INSERT INTO schema_migrations (filename) VALUES
('20261013140000_create_users_and_teams.rb'),
('20261013140100_create_threads_and_messages.rb'),
('20261013150000_add_pinned_at_to_threads.rb');
