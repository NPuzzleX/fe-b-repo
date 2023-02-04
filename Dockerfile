FROM node:18-alpine AS build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./palette
COPY . ./
RUN npm install

# Akari
RUN sed -i 's|"fe-app"|"fe-akari-edit"|' ./package.json
RUN npm run build --puzzle=akari --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-akari-play"|' ./package.json
RUN npm run build --puzzle=akari --type=play

# Sudoku
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-sudoku-edit"|' ./package.json
RUN npm run build --puzzle=sudoku --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-sudoku-play"|' ./package.json
RUN npm run build --puzzle=sudoku --type=play

# Slitherlink
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-slitherlink-edit"|' ./package.json
RUN npm run build --puzzle=slitherlink --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-slitherlink-play"|' ./package.json
RUN npm run build --puzzle=slitherlink --type=play

# Nurikabenurikabe
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-nurikabe-edit"|' ./package.json
RUN npm run build --puzzle=nurikabe --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-nurikabe-play"|' ./package.json
RUN npm run build --puzzle=nurikabe --type=play

# Kakuro
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-kakuro-edit"|' ./package.json
RUN npm run build --puzzle=kakuro --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-kakuro-play"|' ./package.json
RUN npm run build --puzzle=kakuro --type=play

# Hashi
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-hashi-edit"|' ./package.json
RUN npm run build --puzzle=hashi --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-hashi-play"|' ./package.json
RUN npm run build --puzzle=hashi --type=play

# Futoshiki
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-futoshiki-edit"|' ./package.json
RUN npm run build --puzzle=futoshiki --type=edit
COPY ./package.json ./
RUN sed -i 's|"fe-app"|"fe-futoshiki-play"|' ./package.json
RUN npm run build --puzzle=futoshiki --type=play

FROM lipanski/docker-static-website:latest

COPY --from=build /app/dist .

CMD ["/busybox", "httpd", "-f", "-v", "-p", "3000", "-c", "httpd.conf"]