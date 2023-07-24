const second = 1000
const query = `
query($id: Int) {
  Media(id: $id) {
    idMal
  }
}
`;

const observer = new MutationObserver(async (_, observer) => {
  // The element with the "message" class is available now (at least, when I tested it); but we're not going to use it
  // just yet, as we need a response to even consider rewriting the description.
  observer.disconnect();

  const path = document.location.pathname.match(/\/(\w+)\/(\d+)/);

  if (path === null) {
    // Definitely not the right page (e.g. /user/KlayLay).
    return;
  }

  const type = path[1];

  if (type !== "anime" && type !== "manga") {
    // We don't care about other pages.
    return;
  }

  const id = path[2];
  const response = await fetch("https://graphql.anilist.co/", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      query: query,
      variables: {
        id: id // Even though this should be a number, AniList doesn't care.
      }
    })
  });

  const body = await response.json();
  const malId = body.data.Media.idMal;

  // CORS
  safari.extension.dispatchMessage("MalQuery", {
    type,
    id: malId
  });
});

safari.self.addEventListener("message", ({ name, message }) => {
  if (name !== "MALResponse") {
    console.log(`Unknown message response: ${name}`);

    return;
  }

  const synopsis = message.synopsis;
  const desc = document.getElementsByClassName("description")[0];

  // Add a delay in case the description isn't updated by AniList in time.
  setTimeout(() => {
    desc.innerText = synopsis;
  }, second)
});

function activate() {
  const app = document.getElementById("app");

  observer.observe(app, {
    subtree: true,
    childList: true
  });
}

document.addEventListener("DOMContentLoaded", function(event) {
  activate()

  let location = document.location.href

  setInterval(() => {
    let loc = document.location.href

    if (loc !== location) { // Did the page URL change?
      location = loc

      activate()
    }
  }, second)
});
