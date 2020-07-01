#! /usr/bin/env bash
PROJECT_BASE_DIR=$(cd "$(dirname $BASH_SOURCE)/.." && pwd)

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

  local test_data_yaml='subprojects/java-stack-service/model/task_groups/test-data.yaml'
  mkdir -p $(dirname $test_data_yaml)
  cat <<'EOF' > "$test_data_yaml"
task_groups:
- id: 66e3d018-f188-4bfe-8edc-2bccfec9456f
  title: My To Do List
  tasks:
  - seq_number: 1
    title: Hit the gym
  - seq_number: 2
    title: Pay bills
    completed: true
  - seq_number: 3
    title: Organize office
    description: |
      Start with a purge!
- id: 65b7ffa0-e35f-49c1-8695-487c3e4798cc
  title: An Empty To Do List
  color: gray
EOF

  ./subprojects/java-stack-service/scripts/generate.sh
  ./subprojects/java-stack-service/scripts/deploy-on-local-containers.sh
}

$MAIN