#!/usr/bin/env bash

# Install node_modules, if not already installed
if [ ! -r ./node_modules ]; then
    echo "Installing node_modules..."
    docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'npm ci'
fi

# Install m30mlTools/node_modules, if not already installed
if [ ! -r ./m30mlTools/node_modules ]; then
    echo "Installing m30mlTools/node_modules..."
    docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'cd m30mlTools && npm ci'
fi

# Install dof-helpers/node_modules, if not already installed
if [ ! -r ./dof-helpers/node_modules ]; then
    echo "Installing dof-helpers/node_modules..."
    docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'cd dof-helpers && npm ci'
fi

# Create dist/ directory, if none exists
if [ ! -r ./dist ]; then
    echo "Creating dist/ directory..."
    mkdir dist/
fi

# copy operating-mode-as-fsm.puml to dist/...
echo "copying operating-mode-as-fsm.puml to dist/..."
docker run --rm -v $PWD:/src -w /src node bash -c 'cp ./components/sealion-cubesat/components/sealion-obc/components/dilophos/fsw-architecture/operating-mode-as-fsm.puml dist/'

# generate dist/component.yaml & symlink to architecture/ directory
echo "generating dist/component.yaml & symlink to architecture/ directory..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node dof-helpers/parseComponent.js && mkdir architecture/4-Components && ln -srv dist/component.yaml architecture/4-Components'

# Build the unified model
echo "Building the unified model..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/buildUnifiedModel.js && cp dist/architecture.yaml dist/architecture.yml'

# generate stakeholder needs mapping
echo "generating stakeholder needs mapping..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/stakeholder-needs-mapping.puml.liquid --out=dist/stakeholder-needs-mapping.puml'

# generate user stories mapping
echo "generating user stories mapping..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/user-stories-mapping.puml.liquid --out=dist/user-stories-mapping.puml'

# generate use-case-diagrams.puml from liquid template
echo "generating use-case-diagrams.puml from liquid template..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/use-case-diagram.puml.liquid --out=dist/use-case-diagram.puml'

# generate data structure mapping
echo "generating data structure mapping..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/data-structures-mapping.puml.liquid --out=dist/data-structures-mapping.puml'

# generate sealion-mission-architecture.adoc from liquid template
echo "generating sealion-mission-architecture.adoc from liquid template..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/sealion-mission-architecture.adoc.liquid --out=dist/sealion-mission-architecture.adoc'

# generate pdf-theme.yml from liquid template
echo "generating pdf-theme.yml from liquid template..."
docker run --rm --volume "$PWD:/src" -w "/src" capsulecorplab/asciidoctor-extended:liquidoc 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'
#docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'bundle exec liquidoc -d dist/architecture.yml -t templates/pdf-theme.yml.liquid -o dist/pdf-theme.yml'

# generate index.html
echo "generating index.html..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-mission-architecture.adoc -r asciidoctor-diagram -o dist/index.html

# generate sealion-mission-architecture.pdf
echo "generating sealion-mission-architecture.pdf..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-mission-architecture.adoc -o dist/sealion-mission-architecture.pdf -r asciidoctor-pdf -r asciidoctor-diagram -b pdf -a pdf-theme=dist/pdf-theme.yml

# remove architecture/4-Components
echo "removing architecture/4-Components..."
docker run --rm --volume $PWD:/src -w "/src" node bash -c 'rm -rf architecture/4-Components'

# Generate presentation.html
echo "Generating presentation.adoc..."
docker run --rm -v $PWD:/src -w /src node node m30mlTools/generateDoc.js --unifiedModel=dist/architecture.yaml --template=templates/presentation.adoc.liquid --out=dist/presentation.adoc
echo "Generating presentation.html..."
docker run --rm -v $PWD:/documents asciidoctor/docker-asciidoctor bash -c "cd dist && asciidoctor-revealjs -r asciidoctor-diagram -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.8.0 -a revealjs_transition=slide -a revealjs_slideNumber=true -a revealjs_width=1100 -a revealjs_height=700 -D . 'presentation.adoc' -o 'presentation.html'"

# generate components/sealion-cubesat/dist/component.yaml
if [ ! -r ./components/sealion-cubesat/dist ]; then
    echo "Creating components/sealion-cubesat/dist/ directory..."
    mkdir components/sealion-cubesat/dist/
fi
echo "generating components/sealion-cubesat/dist/component.yaml..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'cd components/sealion-cubesat && node ../../dof-helpers/parseComponent.js'

# generate dist/sealion-cubesat-assembly-instructions.adoc
echo "generating dist/sealion-cubesat-assembly-instructions.adoc..."
docker run --rm -v $PWD:/src -w /src node bash -c 'cd components/sealion-cubesat && node ../../dof-helpers/generateAssemblyInstructions.js && mv dist/assemblyInstructions.adoc ../../dist/sealion-cubesat-assembly-instructions.adoc'

# generate dist/sealion-cubesat-assembly-instructions.html
echo "generating dist/sealion-cubesat-assembly-instructions.html..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-cubesat-assembly-instructions.adoc -o dist/sealion-cubesat-assembly-instructions.html

# generate dist/sealion-cubesat-assembly-instructions.pdf
echo "generating dist/sealion-cubesat-assembly-instructions.pdf..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-cubesat-assembly-instructions.adoc -o dist/sealion-cubesat-assembly-instructions.pdf -r asciidoctor-pdf -b pdf

# generate components/sealion-ground-station/dist/component.yaml
if [ ! -r ./components/sealion-ground-station/dist ]; then
    echo "Creating components/sealion-ground-station/dist/ directory..."
    mkdir components/sealion-ground-station/dist/
fi
echo "generating components/sealion-ground-station/dist/component.yaml..."
docker run --rm --volume "$PWD:/src" -w "/src" node bash -c 'cd components/sealion-ground-station && node ../../dof-helpers/parseComponent.js'

# generate dist/sealion-ground-station-assembly-instructions.adoc
echo "generating dist/sealion-ground-station-assembly-instructions.adoc..."
docker run --rm -v $PWD:/src -w /src node bash -c 'cd components/sealion-ground-station && node ../../dof-helpers/generateAssemblyInstructions.js && mv dist/assemblyInstructions.adoc ../../dist/sealion-ground-station-assembly-instructions.adoc'

# generate dist/sealion-ground-station-assembly-instructions.html
echo "generating dist/sealion-ground-station-assembly-instructions.html..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-ground-station-assembly-instructions.adoc -o dist/sealion-ground-station-assembly-instructions.html

# generate dist/sealion-ground-station-assembly-instructions.pdf
echo "generating dist/sealion-ground-station-assembly-instructions.pdf..."
docker run --rm --volume $PWD:/src -w "/src" asciidoctor/docker-asciidoctor asciidoctor dist/sealion-ground-station-assembly-instructions.adoc -o dist/sealion-ground-station-assembly-instructions.pdf -r asciidoctor-pdf -b pdf
