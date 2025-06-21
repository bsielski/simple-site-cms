#!/bin/sh
set -e

# Stara logika z Gemfile.lock nie jest już potrzebna, bo `bundle install` w Dockerfile
# tworzy poprawny Gemfile.lock w obrazie.
# Kompilacja assetów została przeniesiona do Dockerfile.

# Można tu dodać oczekiwanie na bazę danych, jeśli chcesz (opcjonalne)
# np. za pomocą skryptu wait-for-it.sh

# Uruchom główne polecenie przekazane do kontenera (CMD z Dockerfile)
exec "$@"
