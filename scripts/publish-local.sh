#!/usr/bin/env bash
set -e
PROJECT_BASE_DIR=$(cd $"${BASH_SOURCE%/*}/../" && pwd)

SCRIPT_BASE_DIR="$PROJECT_BASE_DIR/scripts"


OPT_NAMES='hvr:-:'

ARGS=
HELP=
VERBOSE=
MAX_RECURSION=10
SKIP_GENERATION=
LOCAL_MODULE_REPOSITORY=


# @main@
main () {
  echo "The main() function should be overwritten. Create the template ./scripts/publish-local@main@.hbs.sh"
  return 1
}
# @main@

# @+additional-declarations|laplacian.generator.project-template-1.0.0!scripts/publish-local_additional-declarations_.hbs.sh@
GRADLE_DIR=${SCRIPT_BASE_DIR}/laplacian
GRADLE="./gradlew"
GRADLE_BUILD_FILE="$GRADLE_DIR/build.gradle"
GRADLE_SETTINGS_FILE="$GRADLE_DIR/settings.gradle"
DEST_DIR="$PROJECT_BASE_DIR/dest"

generate() {
  $SCRIPT_BASE_DIR/generate.sh
}

publish_local() {
  local module_dir="$1"
  trap clean EXIT
  set_local_module_repo
  create_build_dir
  create_settings_gradle
  create_build_gradle $module_dir
  run_gradle
}

set_local_module_repo() {
  LOCAL_MODULE_REPOSITORY=${LOCAL_MODULE_REPOSITORY:-"$PROJECT_BASE_DIR/../mvn-repo"}
}


create_build_dir() {
  mkdir -p $GRADLE_DIR
}

run_gradle() {
  (cd $GRADLE_DIR
    $GRADLE \
      --stacktrace \
      --build-file build.gradle \
      --settings-file settings.gradle \
      --project-dir $GRADLE_DIR \
      publish
  )
}

create_settings_gradle() {
  cat <<EOF > $GRADLE_SETTINGS_FILE
pluginManagement {
    repositories {
        maven {
            url '${LOCAL_MODULE_REPOSITORY}'
        }
        maven {
            url '${REMOTE_REPO_PATH}'
        }
        gradlePluginPortal()
        jcenter()
    }
}
rootProject.name = "laplacian.tutorial"
EOF
}

create_build_gradle() {
  local module_dir="$1"
  cat <<EOF > $GRADLE_BUILD_FILE
plugins {
    id 'maven-publish'
    id 'org.jetbrains.kotlin.jvm' version '1.3.70'
}

group = 'laplacian'
version = '1.0.0'

repositories {
    maven {
        url '${LOCAL_MODULE_REPOSITORY}'
    }
    maven {
        url '${REMOTE_REPO_PATH}'
    }
    jcenter()
}

task moduleJar(type: Jar) {
    from '${DEST_DIR}/${module_dir}'
}

publishing {
    repositories {
        maven {
            url '${LOCAL_MODULE_REPOSITORY}'
        }
    }
    publications {
        mavenJava(MavenPublication) {
            artifact moduleJar
        }
    }
}
EOF
}

clean() {
  rm -f $GRADLE_BUILD_FILE $GRADLE_SETTINGS_FILE 2> /dev/null || true
}
# @additional-declarations|laplacian.generator.project-template-1.0.0!scripts/publish-local_additional-declarations_.hbs.sh@
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
      max-recursion)
        MAX_RECURSION=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      skip-generation)
        SKIP_GENERATION='yes';;
      local-module-repository)
        LOCAL_MODULE_REPOSITORY=("${!OPTIND}"); OPTIND=$(($OPTIND+1));;
      *)
        echo "ERROR: Unknown OPTION --$OPTARG" >&2
        exit 1
      esac
      ;;
    h) HELP='yes';;
    v) VERBOSE='yes';;
    r) MAX_RECURSION="$OPTARG";;
    esac
  done
  ARGS=$@
}

show_usage () {
cat << 'END'
Usage: ./scripts/publish-local.sh [OPTION]...
  -h, --help
    Displays how to use this command.
  -v, --verbose
    Displays more detailed command execution information.
  -r, --max-recursion [VALUE]
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>). (Default: 10)
  --skip-generation
    This option is the same as the option of the same name in [generate.sh](<./scripts/generate.sh>).
  --local-module-repository [VALUE]
    The path to the local repository where the built module will be stored.
    If the repository does not exist in the specified path, it will be created automatically.
END
}

parse_args "$@"

! [ -z $VERBOSE ] && set -x
! [ -z $HELP ] && show_usage && exit 0
main