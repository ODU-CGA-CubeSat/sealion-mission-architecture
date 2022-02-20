#!/usr/bin/env bash

# Install node_modules, if not already installed
if [ ! -r ./node_modules ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'npm ci'
fi

# Install m30mlTools/node_modules, if not already installed
if [ ! -r ./m30mlTools/node_modules ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'cd m30mlTools && npm ci'
fi

# Install dof-helpers/node_modules, if not already installed
if [ ! -r ./dof-helpers/node_modules ]; then
    docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'cd dof-helpers && npm ci'
fi

# Make dist/ directory, if none exists
if [ ! -r ./dist ]; then
    mkdir dist/
fi

# generate dist/component.yaml & symlink to architecture/ directory
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node dof-helpers/parseComponent.js && mkdir architecture/4-Components && ln -srv dist/component.yaml architecture/4-Components'

# Build the unified model
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node m30mlTools/buildUnifiedModel.js && cp dist/architecture.yaml dist/architecture.yml'

# generate use-case-diagrams.puml from liquid template
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/use-case-diagram.puml.liquid --out=dist/use-case-diagram.puml'

# generate sealion-mission-architecture.adoc from liquid template
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/sealion-mission-architecture.adoc.liquid --out=dist/sealion-mission-architecture.adoc'

# generate pdf-theme.yml from liquid template
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'
#docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'

# generate index.html
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:2.0.10-alpine 'asciidoctor dist/sealion-mission-architecture.adoc -r asciidoctor-diagram -o dist/index.html'

# generate sealion-mission-architecture.pdf
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:2.0.10-alpine 'asciidoctor dist/sealion-mission-architecture.adoc -o dist/sealion-mission-architecture.pdf -r asciidoctor-pdf -r asciidoctor-diagram -b pdf -a pdf-theme=dist/pdf-theme.yml'

# remove architecture/4-Components
docker run --rm --volume $PWD:/src -w "/src" capsulecorplab/asciidoctor-extended:asciidocsy-nodejs 'rm -rf architecture/4-Components'

# Generate presentation.html
echo "Generating presentation.adoc..."
docker run --rm -v $PWD:/src -w /src node node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/presentation.adoc.liquid --out=dist/presentation.adoc
echo "Generating presentation.html..."
docker run --rm -v $PWD:/documents asciidoctor/docker-asciidoctor bash -c "cd dist && asciidoctor-revealjs -r asciidoctor-diagram -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 -D . 'presentation.adoc' -o 'presentation.html'"
