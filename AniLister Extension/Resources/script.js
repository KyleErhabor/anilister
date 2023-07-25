const second = 1000;
const query = `
query($id: Int) {
  Media(id: $id) {
    idMal
  }
}
`;

function getDescription() {
  return document.getElementsByClassName("description")[0];
}

async function replaceDescription(page) {
  const response = await fetch("https://graphql.anilist.co/", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      query: query,
      variables: {
        // Even though this should be a number (according to the GraphQL type), AniList doesn't seem to care... less
        // work for us!
        id: page.id
      }
    })
  });

  const body = await response.json();
  const malId = body.data.Media.idMal;

  // CORS
  safari.extension.dispatchMessage("MALQuery", {
    type: page.type,
    id: malId
  });
}

function getPage() {
  const path = location.pathname.match(/^\/(\w+)\/(\d+)/);

  if (path === null) {
    // Definitely not the right page (e.g. /user/KlayLay).
    return;
  }

  const type = path[1];

  if (type !== "anime" && type !== "manga") {
    return;
  }

  return {
    type,
    id: path[2]
  };
}

const observer = new MutationObserver((_, observer) => {
  // The description *should* exist on the first call to this callback.
  observer.disconnect();

  replaceDescription(getPage());
});

function activate() {
  const page = getPage();

  if (!page) {
    return;
  }

  // If the description exists here, it's likely that the interval's callback was called after the description was set.
  // This can happen due to the naive method being used to check for navigation coupled with the delay (currently a
  // second). If we didn't have this check, the description would sometimes not be updated due to the observer not
  // being notified of any changes (which is also why, if the user scrolls down a bit, the description will update).
  if (getDescription()) {
    replaceDescription(page);

    return;
  }

  const app = document.getElementById("app");

  observer.observe(app, {
    subtree: true,
    childList: true
  });
}

document.addEventListener("DOMContentLoaded", (event) => {
  activate();

  let previousLoc = location.href;

  // I'd rather listen for the "popstate" event, but AniList doesn't seem to trigger it.
  setInterval(() => {
    let loc = location.href;

    // Did the page URL change?
    if (loc !== previousLoc) {
      previousLoc = loc;

      activate();
    }
  }, second);
});

safari.self.addEventListener("message", ({ name, message }) => {
  if (name !== "MALResponse") {
    console.log(`Unknown message response: ${name}`);

    return;
  }

  const synopsis = message.synopsis;
  const desc = getDescription();

  desc.innerText = synopsis;
});
