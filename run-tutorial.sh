#! /usr/bin/env bash
PROJECT_BASE_DIR=$(cd "$(dirname $BASH_SOURCE)/.." && pwd)

set -e
set -x

main() {
  cleanup
  _010_creating_project_group
  _020_creating_application_domain_model
  _030_creating_application_api_model
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
  git commit -m 'Initial commit'
}

_020_creating_application_domain_model() {
  cd $PROJECT_BASE_DIR
  cd laplacian-tutorial
  ./scripts/create-new-domain-model-project.sh
  git add .
  git commit -m 'add domain-model subproject.'

  (cd ./subprojects/laplacian-tutorial.domain-model/
    mkdir -p ./src/entities
    echo <<'EOF' > ./src/entities/task-group.yaml
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

    echo <<'EOF' > ./src/entities/task.yaml
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
  ./scripts/generate.sh
  git add .
  git commit -m 'Add domain models.'
  ./scripts/publish-local.sh
  ./scripts/generate-domain-model.sh
  ./scripts/publish-local-domain-model.sh
  git add .
  git commit -m 'Add domain-model-plugin'
}

_030_creating_application_api_model() {
  cd $PROJECT_BASE_DIR
  cd laplacian-tutorial
  ./scripts/create-new-function-model-project.sh
  git add .
  git commit -m 'add function-model subproject.'
  (cd ./subprojects/laplacian-tutorial.function-model/
    mkdir -p src/datasources
    echo <<EOF > src/datasources/tutorial-db.yaml
datasources:
- name: tutorial_db
  type: postgres
  user: test
  password: secret
  db_name: tutorial_db
  hostname: localhost
  entity_references:
  - entity_name: task_group
EOF
    mkdir -p src/services
    echo <<EOF > src/services/tutorial-api.yaml
services:
- name: tutorial_api
  version: '0.0.1'
  namespace: laplacian.tutorial.api
  datasource_name: tutorial_db
  resource_entries:
  - resource_name: task_group
EOF
    mkdir -p src/rest-resources
    echo <<EOF > src/rest-resources/task-group.yaml
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
  ./scripts/generate.sh
  git add .
  git commit -m 'Add function models concerning the api service.'
  ./scripts/publish-local.sh
}
main
