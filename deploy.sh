#! /bin/bash
export GOOS=linux
export GOARCH=amd64
# without the build on Linux will result in "no such file or directory" error
export CGO_ENABLED=0
# change into the directory of the script itself instead of using the position of the callee
cd $(dirname "$0")
helpFunction()
{
  echo ""
  echo "Usage: $0 -s service_name -p gcp_project_id"
  echo -e "\t-s Service Name (Folder Name) listed in ./cmd/ dir"
  echo -e "\t-p GCP Project ID. Ether of:
            \t data-integration-development
            \t data-integration-staging
            \t data-integration-production"
  exit 1
}

SERVICE=""
CMD_DIR="cmd"
GCP_REGION="europe-west4"
GCP_DEV="terraform-github-actions"
GCP_STAG="terraform-github-actions"
GCP_PROD="terraform-github-actions"
GCP_PROJECT=""

# Check for args
while getopts "s:p:h:" opt
do
  case "$opt" in
    s ) ARG_SERVICE="$OPTARG" ;;
    p ) ARG_PROJECT="$OPTARG" ;;
    h ) helpFunction ;;
    ? ) helpFunction ;;
  esac
done

# Check if optional Service Name arg is set
if [ -z "$ARG_SERVICE" ];
then
  cd $CMD_DIR || { echo "Unexpected error: $SERVICES_DIR not exists!" >&2; exit 1; }

  echo Please select a Service to deploy
  select d in */;
  do
    # Checks if input exists
    test -n "$d" && break;
    echo ">>> Invalid Selection";
  done

  cd ..

  # awk removes last character from string
  # Listing directories from select command
  # prints for e.g. customs/ so here we need to remove / character
  SERVICE=$(echo "$d" | awk '{ print substr( $0, 1, length($0)-1 ) }')

else
  if [ ! -d "$CMD_DIR/$ARG_SERVICE" ];
  then
    echo "Provided Service Name: $ARG_SERVICE does not exist in cmd/ directory" >&2;
    exit 1;
  fi
  SERVICE=$ARG_SERVICE
fi

# From here we are sure the service specified to deploy really exists.
echo "BIS Service to deploy: $SERVICE"

# Set GCP Project
case "$ARG_PROJECT" in
  "$GCP_DEV")
    GCP_PROJECT=$GCP_DEV ;;
  "$GCP_STAG")
    GCP_PROJECT=$GCP_STAG ;;
  "$GCP_PROD")
    GCP_PROJECT=$GCP_PROD ;;
  *)
    echo "Please select a valid GCP Project"
    select project in "$GCP_DEV" "$GCP_STAG" "$GCP_PROD";
    do
      if [[ ! "$project" = "" ]]; then
          GCP_PROJECT=$project;
          break;
      fi
      echo ">>> Invalid Selection";
    done
    ;;
esac

# From here we are sure that we have configured the correct GCP Project
echo "GCP Project configured: $GCP_PROJECT"

# Check if docker or podman is installed
CMD_CONTAINER=podman
if ! [ -x "$(command -v podman)" ]; then
  if ! [ -x "$(command -v docker)" ]; then
    echo 'Error: docker or podman is not installed.' >&2;
    exit 1;
  else
    CMD_CONTAINER="$(command -v docker)"
  fi
fi

# Check if go is installed
if ! [ -x "$(command -v go)" ]; then
  echo "Error: go is not installed" >&2;
  exit 1;
fi

echo "Compile service"
go build -o ./build/"$SERVICE" ./cmd/"$SERVICE"

echo "Build container"
$CMD_CONTAINER build -t "$SERVICE" -f ./build/Dockerfile --build-arg APP="$SERVICE" ./build --platform "$GOOS"/"$GOARCH"
DOCKER_SERVICE="$SERVICE"
if [ "$SERVICE" = dsv ]; then
   DOCKER_SERVICE="bis-dsv";
fi
echo "Tag local container image"
$CMD_CONTAINER tag "$SERVICE" "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$DOCKER_SERVICE-docker/$SERVICE"

echo "Push to remote GCP Artifact Repository"
$CMD_CONTAINER push "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$DOCKER_SERVICE-docker/$SERVICE"

# This regex matches for the output of gcloud artifacts docker tags list command.
# The second regex group is needed because its represents the sha256 value of the container image.
# To have a more specific regex \w* would be better for the second group instead of .* but this somehow don't work.
GCLOUD_REGEX="(latest. $GCP_REGION-docker.pkg.dev\/$GCP_PROJECT\/$DOCKER_SERVICE-docker\/$SERVICE  sha256:)(.*)"

# Get out of image with :latest Tag deployed
LATEST_SHA=$(gcloud artifacts docker tags list "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$DOCKER_SERVICE-docker/$SERVICE")

# Match regex
if [[ "$LATEST_SHA" =~ $GCLOUD_REGEX ]]; then
  LATEST_IMAGE="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$DOCKER_SERVICE-docker/$SERVICE@sha256:${BASH_REMATCH[2]}"
fi

echo "Successfully deployed Image to Artifact Registry"
echo "Latest Image for Terraform:"
echo "$LATEST_IMAGE"
echo "$LATEST_IMAGE" > ./file.txt
exit 0
