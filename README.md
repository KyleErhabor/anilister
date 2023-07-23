# AniLister

Replace anime & manga descriptions on [AniList](https://anilist.co/) with synopses from [MyAnimeList](https://myanimelist.net/).

## Rationale

[AniList relies on "credible sources" for its descriptions on anime & manga pages.](https://submission-manual.anilist.co/Description-bd6471ad8eae4d5199c73aff773b8edd) As of July 23, 2023, this list accepts four types of sources:
1. Official English licensors (e.g. [Crunchyroll](http://crunchyroll.com/))
2. Reputable English news outlets (e.g. [Anime News Network](http://animenewsnetwork.com/))
3. The Japanese publisher (e.g. [Kodansha](https://kodansha.us/))
4. Community-led projects which are considered "reliable enough" (e.g. [MAL Rewrite](https://myanimelist.net/clubs.php?cid=6498))

While allowing multiple sources allows for almost all pages to have a description, MAL Rewrite's club page best summarizes the problem this creates:
> Most synopses on MAL are copy/pasted descriptions from other sites and vary dramatically in quality.

From my own personal experience, synopses on MyAnimeList from the MAL Rewrite project are virtually always the best in quality. While MyAnimeList descriptions are better, AniList provides a better interface for navigating and managing my list, and AniLister aims to make up for that limitation.

## Screenshot

An example using the [Alien 9](https://anilist.co/anime/1177/Alien-9) anime.

<details>
  <img src="Documentation/Example.png">
</details>

## Limitations

### API

For AniLister to retrieve synopses from MyAnimeList, it requires a MyAnimeList API Client ID—of which must be created by the user (you!). There are instructions on how to create one in the app, but this is not always desirable, since it requires a MyAnimeList account and setup process. It would be possible to use the [Jikan API](https://jikan.moe/), which acts as a proxy between the end user and MyAnimeList without the need for a client ID (at the cost of stability).

### Descriptions

AniLister replaces *all* anime & manga descriptions on AniList with MyAnimeList synopses. This may not always be desired, since not all MyAnimeList synopses are great (specifically those which aren't written by MAL Rewrite). In the future, I may provide a setting to only use certain synopses matching a criteria.
