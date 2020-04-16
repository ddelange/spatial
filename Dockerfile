FROM missinglink/spatialite as spatialite

# --- base ---
FROM alpine:3.10 as base
COPY --from=spatialite /usr/lib/ /usr/lib
COPY --from=spatialite /usr/bin/ /usr/bin
COPY --from=spatialite /usr/share/proj/proj.db /usr/share/proj/proj.db

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories

RUN apk update && \
  apk --no-cache --update upgrade musl && \
  apk add --upgrade --force-overwrite apk-tools@edge && \
  apk add --update --force-overwrite gcc g++ musl-dev icu-dev icu-libs make sqlite python curl unzip jq nodejs npm bash && \
  rm -rf /var/cache/apk/*

RUN spatialite ':memory:' 'SELECT sqlite_version()'
RUN spatialite ':memory:' 'SELECT spatialite_version()'
RUN sqlite3 :memory: 'SELECT load_extension("mod_spatialite")'

# create working dir
RUN mkdir /code /data
WORKDIR /code

# --- release ---
FROM base
WORKDIR /code

# configure npm
RUN npm set progress=false && npm config set depth

# copy source files
COPY . /code
RUN npm i --unsafe-perm

# run tests
RUN npm t

# entrypoint
ENTRYPOINT ["node", "bin/spatial.js"]
