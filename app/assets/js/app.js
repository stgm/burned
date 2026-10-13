import "../css/app.css";
// Behavior for the chat pages. Every form also works without this file.

const shell = document.getElementById("shell");

// ---------- Local times ----------

function formatTimes(root = document) {
  const now = new Date();
  root.querySelectorAll("time.when").forEach((el) => {
    const date = new Date(el.getAttribute("datetime"));
    if (isNaN(date)) return;
    const clock = date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    const sameDay = date.toDateString() === now.toDateString();
    el.textContent = sameDay && !el.classList.contains("full")
      ? clock
      : `${date.toLocaleDateString([], { month: "short", day: "numeric" })}, ${clock}`;
  });
}

formatTimes();

if (shell) {
  const csrf = shell.dataset.csrf;
  const threadId = shell.dataset.threadId;
  const teamId = shell.dataset.teamId;
  const messages = document.getElementById("messages");

  // ---------- Teams drawer on phones ----------

  const closeTeams = () => shell.classList.remove("teams-open");
  document.getElementById("teams-toggle").addEventListener("click", () => shell.classList.toggle("teams-open"));
  document.getElementById("scrim").addEventListener("click", closeTeams);
  document.addEventListener("keydown", (event) => { if (event.key === "Escape") closeTeams(); });

  // ---------- Scrolling ----------

  const nearBottom = () => !messages || messages.scrollHeight - messages.scrollTop - messages.clientHeight < 120;
  const scrollToBottom = () => { if (messages) messages.scrollTop = messages.scrollHeight; };

  if (messages) {
    const divider = messages.querySelector(".new-divider");
    if (divider) divider.scrollIntoView({ block: "start" });
    else scrollToBottom();
  }

  // ---------- Polling ----------

  let busy = false;

  async function refresh() {
    if (busy || document.hidden) return;
    busy = true;
    try {
      const params = new URLSearchParams();
      if (threadId) {
        params.set("thread_id", threadId);
        params.set("after", document.getElementById("thread").dataset.lastId);
        params.set("read", "1");
      } else if (teamId) {
        params.set("team_id", teamId);
      }
      const response = await fetch(`/updates?${params}`, { headers: { "X-Requested-With": "fetch" }, credentials: "same-origin" });
      if (response.status === 401 || response.redirected) { window.location.reload(); return; }
      if (!response.ok) return;
      apply(new DOMParser().parseFromString(await response.text(), "text/html"));
    } catch (_) {
      // The network is gone for now. The next poll tries again.
    } finally {
      busy = false;
    }
  }

  function slot(doc, name) {
    return doc.querySelector(`template[data-slot="${name}"]`);
  }

  // Swaps the content of a slot, but only when it changed, and keeps its scroll position.
  const seen = new Map();

  function swap(doc, name) {
    const incoming = slot(doc, name);
    const target = document.querySelector(`[data-slot="${name}"]`);
    if (!incoming || !target || seen.get(name) === incoming.innerHTML) return;
    seen.set(name, incoming.innerHTML);
    const scroller = target.closest(".list-pane, .teams") || target;
    const top = scroller.scrollTop;
    const left = target.scrollLeft;
    target.innerHTML = incoming.innerHTML;
    scroller.scrollTop = top;
    target.scrollLeft = left;
  }

  function apply(doc) {
    swap(doc, "recent");
    swap(doc, "list");
    swap(doc, "teams");

    const dot = slot(doc, "toggle-dot");
    if (dot) document.querySelector('[data-slot="toggle-dot"]').hidden = dot.dataset.active !== "true";

    const incoming = slot(doc, "messages");
    if (incoming && messages) {
      const stick = nearBottom();
      let added = false;
      incoming.content.querySelectorAll(".msg").forEach((node) => {
        if (messages.querySelector(`.msg[data-id="${node.dataset.id}"]`)) return;
        messages.appendChild(document.importNode(node, true));
        added = true;
      });
      const lastId = doc.querySelector("[data-last-id]").dataset.lastId;
      document.getElementById("thread").dataset.lastId = lastId;
      if (added) {
        formatTimes(messages);
        if (stick) scrollToBottom();
      }
    }
    formatTimes();
  }

  setInterval(refresh, threadId ? 3000 : 8000);
  document.addEventListener("visibilitychange", refresh);

  // ---------- Composer ----------

  const composer = document.getElementById("composer");
  if (composer) {
    const body = document.getElementById("body");
    const grow = () => {
      body.style.height = "auto";
      body.style.height = `${Math.min(body.scrollHeight, 160)}px`;
      body.style.overflowY = body.scrollHeight > 160 ? "auto" : "hidden";
    };

    async function send() {
      const text = body.value.trim();
      if (!text) return;
      body.disabled = true;
      try {
        const response = await fetch(composer.action, {
          method: "POST",
          headers: { "X-CSRF-Token": csrf, "X-Requested-With": "fetch", "Content-Type": "application/x-www-form-urlencoded" },
          body: new URLSearchParams({ body: text }),
          credentials: "same-origin",
        });
        if (!response.ok) throw new Error("not sent");
        body.value = "";
        grow();
        busy = false;
        await refresh();
        scrollToBottom();
      } catch (_) {
        alert("The message was not sent. Try again.");
      } finally {
        body.disabled = false;
        body.focus();
      }
    }

    composer.addEventListener("submit", (event) => { event.preventDefault(); send(); });
    body.addEventListener("input", grow);

    // Enter sends on devices with a keyboard. Phones keep Enter for new lines.
    const hasKeyboard = window.matchMedia("(pointer: fine)").matches;

    // ---------- @mention suggestions ----------

    const menu = document.getElementById("mention-menu");
    const members = JSON.parse(messages.dataset.members || "[]");
    let choices = [];
    let active = 0;

    const closeMenu = () => { menu.hidden = true; choices = []; };

    function openMenu() {
      const upto = body.value.slice(0, body.selectionStart);
      const match = upto.match(/(?:^|\s)@([a-z0-9_]*)$/i);
      if (!match) return closeMenu();
      const query = match[1].toLowerCase();
      choices = members.filter((m) => m.handle && (m.handle.startsWith(query) || (m.name || "").toLowerCase().startsWith(query))).slice(0, 6);
      if (!choices.length) return closeMenu();
      active = 0;
      menu.innerHTML = "";
      choices.forEach((m, index) => {
        const item = document.createElement("button");
        item.type = "button";
        item.className = index === active ? "on" : "";
        item.textContent = `@${m.handle}  ${m.name || ""}`;
        item.addEventListener("mousedown", (event) => { event.preventDefault(); choose(index); });
        menu.appendChild(item);
      });
      menu.hidden = false;
    }

    function choose(index) {
      const member = choices[index];
      const cursor = body.selectionStart;
      const before = body.value.slice(0, cursor).replace(/@[a-z0-9_]*$/i, `@${member.handle} `);
      body.value = before + body.value.slice(cursor);
      body.selectionStart = body.selectionEnd = before.length;
      closeMenu();
      body.focus();
    }

    body.addEventListener("input", openMenu);
    body.addEventListener("keydown", (event) => {
      if (!menu.hidden) {
        if (event.key === "ArrowDown" || event.key === "ArrowUp") {
          event.preventDefault();
          active = (active + (event.key === "ArrowDown" ? 1 : -1) + choices.length) % choices.length;
          [...menu.children].forEach((el, i) => el.classList.toggle("on", i === active));
          return;
        }
        if (event.key === "Enter" || event.key === "Tab") { event.preventDefault(); choose(active); return; }
        if (event.key === "Escape") { closeMenu(); return; }
      }
      if (event.key === "Enter" && !event.shiftKey && !event.isComposing && hasKeyboard) {
        event.preventDefault();
        send();
      }
    });
    body.addEventListener("blur", () => setTimeout(closeMenu, 100));
  }

  // ---------- Turn messages into a new thread ----------

  const toggle = document.getElementById("select-toggle");
  if (toggle) {
    const form = document.getElementById("split-form");
    const count = document.getElementById("split-count");
    const go = document.getElementById("split-go");

    const picked = () => messages.querySelectorAll(".pick:checked").length;

    function update() {
      const n = picked();
      count.textContent = `${n} selected`;
      go.disabled = n === 0;
    }

    function setSelecting(on) {
      shell.classList.toggle("selecting", on);
      form.hidden = !on;
      toggle.setAttribute("aria-pressed", String(on));
      if (!on) messages.querySelectorAll(".pick:checked").forEach((box) => { box.checked = false; box.closest(".msg").classList.remove("picked"); });
      update();
    }

    toggle.addEventListener("click", () => setSelecting(!shell.classList.contains("selecting")));
    document.getElementById("split-cancel").addEventListener("click", () => setSelecting(false));

    messages.addEventListener("click", (event) => {
      if (!shell.classList.contains("selecting")) return;
      const msg = event.target.closest(".msg");
      const box = msg && msg.querySelector(".pick");
      if (!box) return;
      if (event.target.closest("a")) event.preventDefault();
      if (event.target !== box) box.checked = !box.checked;
      msg.classList.toggle("picked", box.checked);
      update();
    });

    update();
  }
}
