#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"
GRADLE_PROJECT_DIR=$SCRIPT_BASE_DIR/laplacian
GRADLE_FILE=$GRADLE_PROJECT_DIR/build.gradle
GRADLE_PROPERTIES=$GRADLE_PROJECT_DIR/gradle.properties
SETTINGS_FILE=$GRADLE_PROJECT_DIR/settings.gradle
GRADLE_RUNTIME_DIR=$GRADLE_PROJECT_DIR/gradle/wrapper

LF=$'\n'
MODEL_FILES=()
TEMPLATE_FILES=()
TARGET_DIR=$PROJECT_BASE_DIR/generated
LOCAL_REPO_PATH=$PROJECT_BASE_DIR/../../../mvn-repo
REMOTE_REPO_PATH='https://raw.github.com/nabla-squared/mvn-repo/master'
RAW_HOST='https://raw.githubusercontent.com/nabla-squared/laplacian.generator/master'

HELP=
VERBOSE=
PLUGINS=
MODULES=
MODEL_SCHEMA=

main () {
  PLUGINS=$(plugin_def 'laplacian:laplacian.generator:1.0.0')
  MODULES=$(module_def implementation 'laplacian:laplacian.generator:1.0.0')
  mkdir -p $GRADLE_PROJECT_DIR

  while getopts 'hv-:' OPTION;
  do
    case $OPTION in
    -)
      case $OPTARG in
      target-dir)
        TARGET_DIR="$PROJECT_BASE_DIR/${!OPTIND}"; OPTIND=$(($OPTIND+1))
        ;;
      model-files)
        MODEL_FILES+=("${!OPTIND}"); OPTIND=$(($OPTIND+1))
        ;;
      template-files)
        TEMPLATE_FILES+=("${!OPTIND}"); OPTIND=$(($OPTIND+1))
        ;;
      plugin)
        PLUGINS="$PLUGINS$LF    $(plugin_def ${!OPTIND})"; OPTIND=$(($OPTIND+1))
        ;;
      template)
        MODULES="$MODULES$LF    $(module_def template ${!OPTIND})"; OPTIND=$(($OPTIND+1))
        ;;
      model)
        MODULES="$MODULES$LF    $(module_def model ${!OPTIND})"; OPTIND=$(($OPTIND+1))
        ;;
      model-schema)
        MODEL_SCHEMA="${!OPTIND}"; OPTIND=$(($OPTIND+1))
        ;;
      local-repo)
        LOCAL_REPO_PATH="$(normalize_path ${!OPTIND})"; OPTIND=$(($OPTIND+1))
        ;;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='help' ;;
    v) VERBOSE='verbose' ;;
    esac
  done

  [ ! -z $VERBOSE ] && set -x
  cd $SCRIPT_BASE_DIR
  [ ! -z $HELP ] && show_usage && exit 0
  trap clean EXIT
  gradle_file
  # gradle_properties
  settings_file
  install_gradle_runtime
  (
    cd $GRADLE_PROJECT_DIR
    ./gradlew \
      --stacktrace \
      --build-file $GRADLE_FILE \
      --settings-file $SETTINGS_FILE \
      --project-dir $GRADLE_PROJECT_DIR \
      laplacianGenerate \
      $([ -z "$VERBOSE" ] && echo '-q' || echo '-i')
  )
}

settings_file () {
  cat <<END > $SETTINGS_FILE
pluginManagement {
    repositories {
        maven {
            url '${LOCAL_REPO_PATH}'
        }
        maven {
            url '${REMOTE_REPO_PATH}'
        }
        gradlePluginPortal()
        jcenter()
    }
}
END
}

gradle_file () {
  cat <<END > $GRADLE_FILE
plugins {
    id 'org.jetbrains.kotlin.jvm' version '1.3.72'
    id 'maven-publish'
    id 'java-gradle-plugin'
    $PLUGINS
}
repositories {
    maven {
        url '${LOCAL_REPO_PATH}'
    }
    maven {
        url '${REMOTE_REPO_PATH}'
    }
    jcenter()
}
dependencies {
    $MODULES
}
laplacianGenerate {
    target.set(project.file('${TARGET_DIR}'))
$( set_model_schema )
$( set_model_files )
$( set_template_files )
}
END
}

gradle_properties() {
  local jvm_args="-XX:StartFlightRecording=settings=default,filename=/tmp/recording.jfr,dumponexit=true"
  cat <<EOF > $GRADLE_PROPERTIES
org.gradle.jvmargs=$jvm_args
org.gradle.daemon=false
EOF
}

set_model_schema () {
  [ -z "$MODEL_SCHEMA" ] || printf "    modelSpec.get().modelSchema('%s')" $(normalize_path $MODEL_SCHEMA)
}

set_model_files () {
  for path_entry in "${MODEL_FILES[@]}"
  do
    printf "    modelSpec.get().from('%s')\n" $(normalize_path $path_entry)
  done
}

set_template_files () {
  for path_entry in "${TEMPLATE_FILES[@]}"
  do
    printf "    templateSpec.get().from('%s')\n" $(normalize_path $path_entry)
  done
}

plugin_def () {
  IFS=':';
  local tokens=( $1 )
  echo "id '${tokens[1]}' version '${tokens[2]}'"
}

module_def () {
  local type=$1
  local module=$2
  echo "$type '$module'"
}

normalize_path () {
  local path=$1
  if [[ $path == /* ]]
  then
    echo $path
  else
    echo "${PROJECT_BASE_DIR}/$path"
  fi
}

show_usage () {
cat << END
Usage: $(basename "$0") [OPTION]...

  --model-dir PATH
    PATH of the directory where the model yaml files reside (default: \$PROJECT_BASE/model)

  --template-dir PATH
    PATH of the directory where the template files reside (default: \$PROJECT_BASE/template)

  --target-dir PATH
    PATH of the directory under which the generated resources are put (default: \$PROJECT_BASE/model)

  --local-repo PATH
    PATH of local repository where the maven modules are hosted. (default: \$PROJECT_BASE/../mvn-repo)

  -h
    Display this help message.

  -v
    Verbose output
END
}

install_gradle_runtime () {
  [ -f $GRADLE_PROJECT_DIR/gradlew ] || (
    mkdir -p $GRADLE_RUNTIME_DIR
    curl -Ls -o $GRADLE_PROJECT_DIR/gradlew $RAW_HOST/gradlew
    curl -Ls -o $GRADLE_RUNTIME_DIR/gradle-wrapper.jar $RAW_HOST/gradle/wrapper/gradle-wrapper.jar
    curl -Ls -o $GRADLE_RUNTIME_DIR/gradle-wrapper.properties $RAW_HOST/gradle/wrapper/gradle-wrapper.properties
    chmod 755 $GRADLE_PROJECT_DIR/gradlew
  )
}

clean() {
  rm -f $GRADLE_FILE $SETTINGS_FILE &> /dev/null || true
}

main "$@"
