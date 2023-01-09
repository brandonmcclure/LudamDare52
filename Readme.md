# LudamDare 52 - The Harvesting

This is my (did not finish on time) project for Ludam Dare 52. I call it `The Harvesting`. The game is a elixir liveView project were each player has a farm with multiple plot and unique game session, then click on their plots to harvest, and gain points.

My stretch goals were multiple crop types, seasons based on the server time, and graphics. I am happy with my progress, but am dismayed at my inability to deploy it and start getting feedback early on. There is a major lack of polish for the game development.

## How to play

You click the button that says click me. Try to get a big number. run xdotool or another auto-clicker and try to crash your computer!

Each new game gets a unique id that is part of the URL. Share games with your friends and see who can harvest the most food!

## How to Build

I used vscode and the `.devcontainer` setup in this repo to develop this game. Checkout the devcontainer, which should have everything you need to build and debug the phoenix app. After you are in the dev container, run `make elixir_deps elixir_migrate elixir_run elixir_run` and you will soon have the app running on `http://localhost:8080`

*note you have to `make elixir_run` twice... bugs am'i right?

## Lessons learned

I underestimated the amount of time it would take for me to deploy. This was complicated by me starting the project with an old version of phoenix and spending too long investigating a new service, instead of sticking with fundamentals for deploying it to a VPS