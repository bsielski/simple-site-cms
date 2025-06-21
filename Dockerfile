# --- Etap 1: Budowanie (Builder) ---
# Używamy wersji Ruby i Alpine z Twojego .env
FROM ruby:2.7.2-alpine3.13 AS builder

# Argumenty potrzebne tylko na tym etapie
ARG USER_ID=${UID:-1001} # Domyślne wartości, jeśli nie podane
ARG GROUP_ID=${GID:-1001}
# APP_SRC_DIR nie jest już potrzebny, bo kopiujemy z bieżącego katalogu

# Instalujemy tylko to, co potrzebne do `bundle install` i `assets:precompile`
RUN apk add --no-cache build-base git postgresql-dev nodejs yarn tzdata

# Tworzymy użytkownika i katalog roboczy
RUN addgroup -g $GROUP_ID -S app && adduser -u $USER_ID -S app -G app
WORKDIR /home/app

# Kopiujemy pliki Gemfile, instalujemy gemy
COPY Gemfile Gemfile.lock ./
RUN chown -R app:app .

USER app
# Używamy konfiguracji Bundlera do pominięcia grup i ustawienia ścieżki
RUN bundle config set --local without 'development:test' && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install --jobs $(nproc)

# Kopiujemy resztę aplikacji (już jako użytkownik app)
COPY --chown=app:app . .

# Kompilujemy assety
RUN bundle exec rails assets:precompile

# --- Etap 2: Finalny Obraz (Runner) ---
FROM ruby:2.7.2-alpine3.13

# Argumenty potrzebne w finalnym obrazie
ARG USER_ID=${UID:-1001}
ARG GROUP_ID=${GID:-1001}
ARG IS_API=0 # Z Twojego .env

# Instalujemy tylko te pakiety, które są niezbędne do uruchomienia aplikacji
RUN apk add --no-cache postgresql-libs tzdata nodejs

# Tworzymy użytkownika (musi mieć to samo ID co w builderze)
RUN addgroup -g $GROUP_ID -S app && adduser -u $USER_ID -S app -G app
WORKDIR /home/app

# Ustawiamy zmienne środowiskowe
ENV RAILS_ENV=production \
    IS_API=$IS_API \
    RAILS_SERVE_STATIC_FILES=true \
    # Dodajemy ścieżkę do gemów, bo są w vendor/bundle
    BUNDLE_PATH=/home/app/vendor/bundle

# Kopiujemy zainstalowane gemy, skompilowane assety i kod aplikacji z etapu "builder"
COPY --from=builder --chown=app:app /home/app/vendor/bundle ./vendor/bundle
COPY --from=builder --chown=app:app /home/app/public/assets ./public/assets
COPY --from=builder --chown=app:app /home/app .

# Kopiujemy i ustawiamy uprawnienia dla entrypointa
COPY entrypoint.sh .
RUN chmod u+x entrypoint.sh

USER app

EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
