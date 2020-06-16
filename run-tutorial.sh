#! /usr/bin/env bash
PROJECT_BASE_DIR=$(cd "$(dirname $BASH_SOURCE)/.." && pwd)

set -e
set -x

_main() {
  (cd "$PROJECT_BASE_DIR/laplacian-tutorial"
    git reset --hard e5c1b5f1888d4e26ea1c651215ef36e0ca2b780e
  )
  _040_generating_and_testing_api_service
}

main() {
  cleanup
  _010_creating_project_group
  _020_creating_application_domain_model
  _030_creating_application_api_model
#  _040_generating_and_testing_api_service
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
    cat <<'EOF' > ./src/model/entities/task-group.yaml
entities:
- name: task_group
  namespace: laplacian.tutorial

  properties:
  - name: id
    type: string
    primary_key: true

  - name: title
    type: string

  - name: color
    type: string
    optional: true
    default_value: |
      "transparent"

  relationships:
  - name: tasks
    reference_entity_name: task
    cardinality: '*'
    aggregate: true
EOF

    cat <<'EOF' > ./src/model/entities/task.yaml
entities:
- name: task
  namespace: laplacian.tutorial

  properties:
  - name: seq_number
    type: number
    primary_key: true

  - name: title
    type: string

  - name: description
    type: string
    optional: true

  - name: completed
    type: boolean
    optional: true
    default_value: |
      false

  relationships:
  - name: task_group
    cardinality: '1'
    reference_entity_name: task_group
    reverse_of: tasks
EOF
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
    cat <<EOF > src/model/datasources/tutorial-db.yaml
datasources:
- name: tutorial_db
  type: postgres
  db_user: test
  db_password: secret
  db_name: tutorial_db
  hostname: localhost
  entity_references:
  - entity_name: task_group
EOF
    mkdir -p src/model/services
    cat <<EOF > src/model/services/tutorial-api.yaml
services:
- name: tutorial_api
  version: '0.0.1'
  namespace: laplacian.tutorial.api
  datasource_name: tutorial_db
  resource_entries:
  - resource_name: task_group
EOF
    mkdir -p src/model/rest-resources
    cat <<EOF > src/model/rest-resources/task-group.yaml
rest_resources:
- name: task_group
  namespace: laplacian.tutorial.api.rest.resource
  operations:
  - method: GET
    response_body:
    - name: task_groups
      entity_name: task_group
      type: array
EOF
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
  git commit -m 'generate java stack implementation of the service.'
}

main