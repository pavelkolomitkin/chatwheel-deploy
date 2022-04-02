#!/usr/bin/env bash

echo -n 'Building a new version of the backend application...'
echo -en '\n'
# Building the backend
  # Build the backend build tools by using the ./backend-app-build-tool.docker file
echo -n 'Building the backend-build tools...'
echo -en '\n'
docker build --no-cache -t wisecat/chatwheel-backend-build -f docker/backend-app-build-tool.docker .

  # Pull the latest version of the source code placed in the "main" branch
    # if there a directory 'backend_src' -> pull the latest version
    # else -> clone the repository from https://github.com/pavelkolomitkin/chatwheel-backend.git to ./backend_src
echo -en '\n'
echo 'Pull the source code...'
echo -en '\n'
if [[ ! -d ./backend_src/ ]]
then
    git clone https://github.com/pavelkolomitkin/chatwheel-backend.git backend_src
fi

cd ./backend_src && git pull origin main && cd ..

  # Build the backend app using the image built by the ./backend-app-build-tool.docker file
docker run --rm -v $(pwd)/backend_src/app:/app -w /app wisecat/chatwheel-backend-build npm install --production
docker run --rm -v $(pwd)/backend_src/app:/app -w /app wisecat/chatwheel-backend-build npm run build

  # Remove the existing image with the tag wisecat/chatwheel-backend
docker image rm wisecat/chatwheel-backend
  # Build the new version of the backend application with the ./docker/backend-app.docker getting it tagged with wisecat/chatwheel-backend
docker build --no-cache -t wisecat/chatwheel-backend -f docker/backend-app.docker .
    # It should copy the production-build result formed by the build tools(see the ./backend_src/dist directory)