# Journal

Lets keep a journal of my development experience!

## 1/7 16:20

I have not worked on it since noon today. I spent too much time on fly.io. Alternative is to host a VM on azure via terraform. 

I also need to work on the css grid, and the pubsub and passage of time mechanic.

## 1/7 12:00

Spent the morning working on getting fly.io deployment working via [pr 3](https://github.com/brandonmcclure/LudamDare52/pull/3) no luck. Did get it to run on my Arch linux laptop!

Wrote a ServerState struct/ecto changeset that will hold how many game hours have passed.

## 1/7 00:00

I know more about GenServer now, which is helping me conceptualize phoenix better I think. setup a periodically module that will keep track of time passed on the server. The growth rate from each game will be tied to this server value. 

Tried to deploy to fly.io. I think it is having issues because I am running inside a devcontainer, and it cannot communicate over ipv6 to the postgres db instance it deploys. 

remove tailwind. makes the page ugly, but there were several errors that prevented fly.io from building

started making some moon graphics for use to indicate the passage of time.

## 1/6 22:00

A few distractions, but I got a bunch of dbg logging through out. And I got the game session management working. For some reason I cannot run this in firefox anymore. The websocket will fail to connect, and the session reset. Edge works great.

## 1/6 19:00

Install tailwind css. Setup a basic liveview, following [this](https://elixirprogrammer.com/learn/elixir-phoenix-liveview-counter-with-tailwind-css)

tests are all happy

I will keep the [live dashboard](localhost:4000/dashboard) for now.


start with adding in gamestate and individual user sessions


## 1/6 17:30

Done with work and family responsibilities. Officially starting the jam now. Theme is Harvest.

I mean stardew valley clone as a elixir clicker? I think a game where you choose what you plant, and then over time the crop is affected and how much you harvest will change. I would like to evolve the `harvest` concepts some more. We will start with growing corn, then add more fruits/vegtables.
I think a leaderboard for all the game sessions would be cool. People could easily "visit" other people's games.
Art style will be basic images made by me in gimp.

<https://github.com/da-coda/elixir-clicker> is the technical inspiration.

Forget documenting more, I just want to code!

## 1/6 10:00

Created a new empty pheonix project. Setup make targets to test/build the app.
