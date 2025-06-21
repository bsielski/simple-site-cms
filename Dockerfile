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

RUN gem install bundler:1.17.1

# Używamy konfiguracji Bundlera do pominięcia grup i ustawienia ścieżki
RUN bundle config set --local without 'development:test' && \
    bundle update --bundler && \
    bundle install --jobs $(nproc)


# KROK WERYFIKACYJNY: Zobaczmy, co jest w domyślnej ścieżce gemów
RUN echo "Zawartość /usr/local/bundle po bundle install:" && ls -la /usr/local/bundle
RUN echo "Zawartość /home/app po bundle install:" && ls -la /home/app

# Kopiujemy resztę aplikacji (już jako użytkownik app)
COPY --chown=app:app . .

# Kompilujemy assety
RUN bundle exec rails assets:precompile

# --- Etap 2: Finalny Obraz (Runner) ---
FROM ruby:2.7.2-alpine3.13

ARG USER_ID=${UID:-1001}
ARG GROUP_ID=${GID:-1001}
ARG IS_API=0

RUN apk add --no-cache postgresql-libs tzdata nodejs

RUN addgroup -g $GROUP_ID -S app && adduser -u $USER_ID -S app -G app
WORKDIR /home/app

ENV RAILS_ENV=production \
    IS_API=$IS_API \
    RAILS_SERVE_STATIC_FILES=true

# 1. Kopiujemy kod aplikacji (bez gemów, bez assetów, bez .bundle na razie)
COPY --from=builder --chown=app:app /home/app .

# 2. Kopiujemy zainstalowane gemy
COPY --from=builder --chown=app:app /usr/local/bundle /usr/local/bundle

# 3. Kopiujemy konfigurację Bundlera (nadpisze ewentualny pusty .bundle z kroku 1)
COPY --from=builder --chown=app:app /home/app/.bundle /home/app/.bundle

# 4. Kopiujemy skompilowane assety (nadpisze ewentualne puste public/assets z kroku 1)
COPY --from=builder --chown=app:app /home/app/public/assets ./public/assets

# 5. Kopiujemy entrypoint osobno
COPY entrypoint.sh .
RUN chmod u+x entrypoint.sh

USER app

EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
