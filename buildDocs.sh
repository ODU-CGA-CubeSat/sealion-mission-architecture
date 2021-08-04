#!/usr/bin/env bash

# Install node_modules, if not already installed
if [ ! -r ./node_modules ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'cd m30mlTools && npm ci'
fi

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'mkdir dist/'
fi

# Build the unified model
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node m30mlTools/buildUnifiedModel.js && mv dist/architecture.yaml dist/architecture.yml'

# generate architecture.adoc from (liquid) template
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/mission-conops.adoc.liquid -o dist/architecture.adoc'

# generate html & pdf documents
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'asciidoctor dist/architecture.adoc -r asciidoctor-diagram -o dist/index.html'
