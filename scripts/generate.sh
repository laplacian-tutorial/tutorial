#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"


OPT_NAMES='hvdr:-:'

ARGS=
HELP=
VERBOSE=
DRY_RUN=
MAX_RECURSION=10
LOCAL_MODULE_REPOSITORY=
UPDATES_SCRIPTS_ONLY=


# @main@
NEXT_CONTENT_DIR_NAME='.NEXT'
NEXT_CONTENT_DIR="$PROJECT_BASE_DIR/$NEXT_CONTENT_DIR_NAME"
PREV_CONTENT_DIR_NAME='.PREV'
PREV_CONTENT_DIR="$PROJECT_BASE_DIR/$PREV_CONTENT_DIR_NAME"
DEST_DIR_NAME='dest'
SRC_DIR_NAME='src'

CONTENT_DIRS=$([ -z $UPDATES_SCRIPTS_ONLY ] && echo 'src template model' || echo 'model')
UPDATABLE_DIRS=$([ -z $UPDATES_SCRIPTS_ONLY ] && echo 'dest scripts doc .vscode' || echo 'scripts')
CONTENT_FILES=$([ -z $UPDATES_SCRIPTS_ONLY ] && echo '.editorconfig .gitattributes .gitignore README.md README_*.md model-schema-*.json' || echo '')

RECURSION_COUNT=1

main() {
  create_next_content_dir
  update_file_index
  while ! has_settled
  do
    (( $RECURSION_COUNT > $MAX_RECURSION )) && echo "Exceeded the maximum recursion depth: $MAX_RECURSION" && exit 1
    rm -rf $PREV_CONTENT_DIR
    cp -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
    generate
    RECURSION_COUNT=$(($RECURSION_COUNT + 1))
  done
  if [ -z $DRY_RUN ]
  then
    trap apply_next_content EXIT
  else
    git diff --no-index $NEXT_CONTENT_DIR $PROJECT_BASE_DIR
  fi
}

create_next_content_dir() {
  rm -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
  mkdir -p $NEXT_CONTENT_DIR
  (cd $PROJECT_BASE_DIR
    dirs=$(for each in $CONTENT_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    [ -z "$dirs" ] || cp -rf $dirs $NEXT_CONTENT_DIR
    [ -z "$files" ] || cp -f $files $NEXT_CONTENT_DIR
  )

  local src_dir="$NEXT_CONTENT_DIR/$SRC_DIR_NAME"
  local dest_dir="$NEXT_CONTENT_DIR/$DEST_DIR_NAME"

  rm -rf $dest_dir
  if [ -d $src_dir ]
  then
    cp -rf $src_dir $dest_dir
  else
    mkdir -p $dest_dir
  fi
}

normalize_path() {
  local path=$1
  if [[ $path == ./* ]]
  then
    echo "${PROJECT_BASE_DIR}/$path"
  elif [[ $path == /* ]]
  then
    echo $path
  else
    echo "$NEXT_CONTENT_DIR/$path"
  fi
}

update_file_index() {
  local index_dir="$NEXT_CONTENT_DIR/model/project"
  mkdir -p $index_dir
  cat <<EOF > "$index_dir/sources.yaml"
project:
  sources:$(file_list | sort -d)
EOF
}

file_list() {
  (cd "$PROJECT_BASE_DIR"
    local separator="\n  - "
    local dirs=
    [ -d ./model ] && dirs="$dirs ./model"
    [ -d ./template ] && dirs="$dirs ./template"
    [ -d ./src ] && dirs="$dirs ./src"
    find $dirs -type f | while read -r file
    do
      printf "$separator\"${file:2}\""
    done
    printf "\n"
  )
}

generate() {
  LOCAL_MODULE_REPOSITORY=${LOCAL_MODULE_REPOSITORY:-"$PROJECT_BASE_DIR/../mvn-repo"}
  local generator_script="$PROJECT_BASE_DIR/scripts/laplacian-generate.sh"
  local schema_file_path="$(normalize_path 'model-schema-partial.json')"
  local schema_option=
  if [ -f $schema_file_path ]
  then
    schema_option="--model-schema $(normalize_path 'model-schema-partial.json')"
  fi
  $generator_script ${VERBOSE:+'-v'} \
    --plugin 'laplacian:laplacian.metamodel-plugin:1.0.0' \
    --plugin 'laplacian:laplacian.project.domain-model-plugin:1.0.0' \
    --plugin 'laplacian:laplacian.common-model-plugin:1.0.0' \
    --template 'laplacian:laplacian.generator.project-template:1.0.0' \
    --model 'laplacian:laplacian.project.project-types:1.0.0' \
    --model 'laplacian:laplacian.project.domain-model:1.0.0' \
    --model 'laplacian:laplacian.common-model:1.0.0' \
    $schema_option \
    --model-files $(normalize_path 'model/') \
    --template-files $(normalize_path 'template/') \
    --target-dir "$NEXT_CONTENT_DIR_NAME" \
    --local-repo "$LOCAL_MODULE_REPOSITORY"
}

has_settled() {
  [ $RECURSION_COUNT == 1 ] && return 1
  [ -d $NEXT_CONTENT_DIR ] || return 1
  [ -d $PREV_CONTENT_DIR ] || return 1
  diff -r $NEXT_CONTENT_DIR $PREV_CONTENT_DIR > /dev/null
}

apply_next_content() {
  (cd $PROJECT_BASE_DIR
    dirs=$(for each in $UPDATABLE_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    [ -z "$dirs" ] || rm -rf $dirs
    [ -z "$files" ] || rm -f $files
  )

  (cd $NEXT_CONTENT_DIR
    dirs=$(for each in $UPDATABLE_DIRS; do [ -d $each ] && echo $each || true; done)
    files=$(for each in $CONTENT_FILES; do [ -f $each ] && echo $each || true; done)
    [ -z "$dirs" ] || cp -rf $dirs $PROJECT_BASE_DIR
    [ -z "$files" ] || cp -f $files $PROJECT_BASE_DIR
  )

  rm -rf $NEXT_CONTENT_DIR $PREV_CONTENT_DIR
}
# @main@

# @+additional-declarations@
# @additional-declarations@

parse_args() {
  while getopts $OPT_NAMES OPTION;
  do
    case $OPTION in
    -)
      case $OPTARG in
      help)
        HELP='yes';;
      verbose)
        VERBOSE='yes';;
      dry-run)
        DRY_RUN='yes';;
      max-recursion)
        MAX_RECURSION=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      local-module-repository)
        LOCAL_MODULE_REPOSITORY=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      updates-scripts-only)
        UPDATES_SCRIPTS_ONLY='yes';;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='yes';;
    v) VERBOSE='yes';;
    d) DRY_RUN='yes';;
    r) MAX_RECURSION="$OPTARG";;
    esac
  done
  ARGS=$@
}

show_usage () {
cat << 'END'
Usage: ./scripts/generate.sh [OPTION]...
  -h, --help
    Displays how to use this command.
  -v, --verbose
    Displays more detailed command execution information.
  -d, --dry-run
    After this command is processed, the generated files are output to the `.NEXT` directory
    without reflecting to the folders of `dest/` `doc/` `scripts/`.
    In addition, the difference between the contents of the `.NEXT` directory and the current files.
    This directory also contains any intermediate files created during the generation.
  -r, --max-recursion [VALUE]
    The upper limit of the number of times to execute recursively
    when the contents of the `model/` `template/` directory are updated
    during the generation process. (Default: 10)
  --local-module-repository [VALUE]
    The repository path to store locally built modules.
    The modules in this repository have the highest priority.
  --updates-scripts-only
    Updates script files only.
    This option is used to generate the generator script itself
    when the project is initially generated.
END
}

parse_args "$@"

! [ -z $VERBOSE ] && set -x
! [ -z $HELP ] && show_usage && exit 0
main