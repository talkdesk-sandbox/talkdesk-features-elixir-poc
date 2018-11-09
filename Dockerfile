FROM elixir:1.7.3-alpine

ENV APP_HOME /talkdesk-features-elixir-poc/
ARG MIX_ENV
ENV MIX_ENV ${MIX_ENV:-test}
ENV SPLIT_ENV "Staging"

WORKDIR $APP_HOME

RUN apk add --update git

COPY mix.* $APP_HOME

RUN mix local.hex --force && mix local.rebar --force 

RUN mix deps.get 

COPY . $APP_HOME

RUN mix compile 

CMD sh -c "mix format --check-formatted && mix test"
