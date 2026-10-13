# Fills the development database with a few people, teams and threads.
#
#   hanami db reset && hanami run config/db/demo.rb
#
# Sign in as admin@example.com. The code is printed in the server log.
u = Hanami.app["repos.user_repo"]; t = Hanami.app["repos.team_repo"]; th = Hanami.app["repos.thread_repo"]
post = Hanami.app["chat.post_message"]
me, = u.invite("admin@example.com", admin: true); u.set_name(me[:id], "Martijn")
others = {"Eva de Vries" => "eva@example.com", "Jonas Berg" => "jonas@example.com", "Mo" => "mo@example.com"}.map { |n, e| x, = u.invite(e); u.set_name(x[:id], n) }
crew = t.create("Crew", me[:id]); side = t.create("Side project", me[:id])
others.each { |o| t.invite(crew[:id], o[:id], me[:id]); t.accept(t.membership(crew[:id], o[:id])) }
t.invite(side[:id], others[0][:id], me[:id]); t.accept(t.membership(side[:id], others[0][:id]))
a = th.create(team_id: crew[:id], user_id: others[0][:id], title: "Lunch on Friday")
b = th.create(team_id: crew[:id], user_id: others[1][:id], title: "Release checklist")
c = th.create(team_id: crew[:id], user_id: me[:id], title: "Random")
d = th.create(team_id: side[:id], user_id: others[0][:id], title: "Landing page copy")
post.call(thread: a, user: others[0], body: "Pizza or ramen?")
post.call(thread: a, user: others[1], body: "Ramen. I looked at https://example.com/ramen")
post.call(thread: a, user: others[2], body: "Pizza, obviously. @martijn you decide")
post.call(thread: b, user: others[1], body: "Who does the changelog?")
post.call(thread: b, user: others[0], body: "Me, after lunch")
post.call(thread: c, user: me, body: "Nothing here yet")
post.call(thread: d, user: others[0], body: "Draft is in the doc")
th.set_level(c[:id], me[:id], "never")
th.set_level(b[:id], me[:id], "mentions")
puts "ok"
