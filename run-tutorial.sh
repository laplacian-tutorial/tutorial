#! /usr/bin/env bash
BASE_DIR=$(cd "$(dirname $BASH_SOURCE)" && pwd)
PROJECT_BASE_DIR=$(cd "$BASE_DIR/.." && pwd)

set -e
set -x

HASH=7bcda6e402d9def4515be09b1c955600c6e8c6bf
MAIN='main'

_main() {
  (cd "$PROJECT_BASE_DIR/laplacian-tutorial"
    git reset --hard $HASH
  )
  _040_generating_and_testing_api_service
}

main() {
  cleanup
  _010_creating_project_group
  _020_creating_application_domain_model
  _030_creating_application_api_model
  _040_generating_and_testing_api_service
}

cleanup() {
  cd $PROJECT_BASE_DIR
  rm -rf laplacian-tutorial
}

git_config() {
  git config user.name iwauo
  git config user.email iwauo.tajima@gmail.com
}

_010_creating_project_group() {
  cd $PROJECT_BASE_DIR
  mkdir laplacian-tutorial
  cd laplacian-tutorial
  git init
  git_config
  curl -Ls 'https://raw.githubusercontent.com/laplacian-arch/projects/master/scripts/install.sh' | bash
  cat model/project.yaml
  ./scripts/generate.sh
  git add .
  git commit -m 'initial commit'
}

_020_creating_application_domain_model() {
  cd $PROJECT_BASE_DIR
  cd laplacian-tutorial
  ./scripts/create-new-domain-model-project.sh
  ./scripts/generate-domain-model.sh
  git add .
  git commit -m 'add domain-model subproject.'

  (cd ./subprojects/domain-model/
    mkdir -p ./src/model/entities
    cp -r $BASE_DIR/resources/entities/*.yaml ./src/model/entities
    mkdir -p ./src/model/value-domain-types
    cp -r $BASE_DIR/resources/value-domain-types/*.yaml ./src/model/value-domain-types
  )
  ./scripts/generate-domain-model.sh
  git add .
  git commit -m 'add domain models.'
  ./scripts/publish-local-domain-model.sh
}

_030_creating_application_api_model() {
  cd $PROJECT_BASE_DIR
  cd laplacian-tutorial
  ./scripts/create-new-function-model-project.sh
  cat <<'EOF' > 'model/project/subprojects/function-model.yaml'
_description: &description
  en: |
    The function-model project.

_project: &project
  group: laplacian-tutorial
  type: function-model
  name: function-model
  namespace: laplacian.tutorial
  description: *description
  version: '0.0.1'
  # Insert the following lines into your project file.
  # From here...
  plugins:
  - group: laplacian-tutorial
    name: domain-model-plugin
    version: '0.0.1'
  models:
  - group: laplacian-tutorial
    name: domain-model
    version: '0.0.1'
  # ... to here.
project:
  subprojects:
  - *project
EOF
  ./scripts/generate.sh
  ./scripts/generate-function-model.sh
  git add .
  git commit -m 'add function-model subproject.'
  (cd ./subprojects/function-model/
    mkdir -p src/model/datasources
    cp -r $BASE_DIR/resources/datasources/*.yaml src/model/datasources/
    mkdir -p src/model/services
    cp $BASE_DIR/resources/services/*.yaml src/model/services/
    mkdir -p src/model/rest-resources
    cp $BASE_DIR/resources/rest-resources/*.yaml src/model/rest-resources/
    mkdir -p src/model/graphql-types
    cp $BASE_DIR/resources/graphql-types/*.yaml src/model/graphql-types/
  )
  ./scripts/generate-function-model.sh
  git add .
  git commit -m 'Add function models concerning the api service.'
  ./scripts/publish-local-function-model.sh
}

_040_generating_and_testing_api_service() {
  cd $PROJECT_BASE_DIR
  cd laplacian-tutorial
  ./scripts/create-new-java-stack-service-project.sh
  cat <<'EOF' > 'model/project/subprojects/java-stack-service.yaml'
_description: &description
  en: |
    The api-service project.

_project: &project
  group: laplacian-tutorial
  type: java-stack-service
  name: java-stack-service
  namespace: laplacian.tutorial
  description: *description
  version: '0.0.1'
  # Insert the following lines into your project file.
  # From here...
  plugins:
  - group: laplacian-tutorial
    name: domain-model-plugin
    version: '0.0.1'
  models:
  - group: laplacian-tutorial
    name: domain-model
    version: '0.0.1'
  - group: laplacian-tutorial
    name: function-model
    version: '0.0.1'
  # ... to here.
project:
  subprojects:
  - *project
EOF

  ./scripts/generate.sh
  ./scripts/generate-java-stack-service.sh
  git add .
  git commit -m 'add a project for a java stack implementation of the service.'

  local test_data_dir='subprojects/java-stack-service/model/test-data'
  mkdir -p $test_data_dir
  cp -r $BASE_DIR/resources/test-data/*.yaml $test_data_dir

  ./subprojects/java-stack-service/scripts/generate.sh
  git add .
  git commit -m 'add test data.'
  ./subprojects/java-stack-service/scripts/deploy-on-local-dev.sh
}

$MAIN