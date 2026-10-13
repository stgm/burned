# Creates the first admin, who can then invite everyone else from the People page.
#
#   ADMIN_EMAIL=you@example.com hanami db seed
#
# Safe to run more than once.
email = ENV["ADMIN_EMAIL"].to_s.strip.downcase

if email.empty?
  puts "Set ADMIN_EMAIL to create the first admin, for example: ADMIN_EMAIL=you@example.com hanami db seed"
else
  users = Hanami.app["repos.user_repo"]
  user, created = users.invite(email, admin: true)
  Hanami.app["relations.users"].dataset.where(id: user[:id]).update(admin: true) unless created
  puts "#{created ? "Created" : "Found"} admin #{email}. Sign in at #{Hanami.app["settings"].app_url}/login"
end
