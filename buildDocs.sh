#!/usr/bin/env bash

# Install node_modules, if not already installed
if [ ! -r ./node_modules ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'cd m30mlTools && npm ci'
fi

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    mkdir dist/
fi

# Build the unified model
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node m30mlTools/buildUnifiedModel.js && mv dist/architecture.yaml dist/architecture.yml'

# generate architecture.adoc from liquid template
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/mission-conops.adoc.liquid -o dist/architecture.adoc'

# generate pdf-theme.yml from liquid template
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'

# generate index.html
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'asciidoctor dist/architecture.adoc -r asciidoctor-diagram -o dist/index.html'

# generate mission-conops.pdf
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy 'asciidoctor dist/architecture.adoc -o dist/mission-conops.pdf -r asciidoctor-pdf -r asciidoctor-diagram -b pdf -a pdf-theme=dist/pdf-theme.yml'
