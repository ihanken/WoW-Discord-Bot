#!/bin/bash

#Constants
DOCKER_LOGIN=`aws ecr get-login --region us-west-2 --no-include-email`
REGION=us-west-2
REPOSITORY_NAME=wow-bot
CLUSTER=discord-bots
ENVIRONMENT=dev
FAMILY=${REPOSITORY_NAME}-${ENVIRONMENT}
NAME=${REPOSITORY_NAME}-${ENVIRONMENT}
SERVICE_NAME=${NAME}-service
SERVICES=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq .failures[]`
BUILD_NUMBER=${TRAVIS_BUILD_NUMBER}

# Login to ECR.
${DOCKER_LOGIN}

#Store the Repository URI as a variable
REPOSITORY_URI=`aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${REGION} | jq .repositories[].repositoryUri | tr -d '"'`

# Build the container.
docker build -t ${NAME} .

# Tag the new container
docker tag ${NAME} ${REPOSITORY_URI}:${ENVIRONMENT}-v_${BUILD_NUMBER}

# Push the new container.
docker push ${REPOSITORY_URI}:${ENVIRONMENT}-v_${BUILD_NUMBER}

# Replace the build number and respository URI placeholders with the constants above..
sed -e "s;%NAME%;${NAME};g" \
-e "s;%ENVIRONMENT%;${ENVIRONMENT};g" \
-e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" \
-e "s;%REPOSITORY_URI%;${REPOSITORY_URI};g" \
-e "s;%WOW_BOT_TOKEN%;${WOW_BOT_DEVELOPMENT_TOKEN};g" \
-e "s;%WOW_API_TOKEN%;${WOW_API_TOKEN};g" \
-e "s;%WARCRAFT_LOGS_API_TOKEN%;${WARCRAFT_LOGS_API_TOKEN};g" \
./travis/DevelopmentTaskDefinition.json > ${NAME}-v_${BUILD_NUMBER}.json

# Register the task definition in the repository
aws ecs register-task-definition --family ${FAMILY} \
--cli-input-json file://${NAME}-v_${BUILD_NUMBER}.json --region ${REGION}

# Check whether the service exists and store the result as a variable.
SERVICES=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq .failures[]`

# Get latest revision
REVISION=`aws ecs describe-task-definition --task-definition ${NAME} --region ${REGION} | jq .taskDefinition.revision`

# Create or update service
if ["$SERVICES" == ""]; then # The service exists. Update it.
  echo "entered existing service"

  # Grab the desired count for the service.
  DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq .services[].desiredCount`

  if [${DESIRED_COUNT} = "0"]; then # If the desired count is 0, set it to 1.
    DESIRED_COUNT="1"
  fi

  # Update the service.
  aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}
else # Otherwise, the service does not exist, so create it.
  echo "entered new service"

  # Create the service.
  aws ecs create-service --service-name ${SERVICE_NAME} --desired-count 1 --task-definition ${FAMILY} --cluster ${CLUSTER} --region ${REGION}
fi