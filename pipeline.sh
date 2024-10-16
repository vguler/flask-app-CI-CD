#!/bin/bash

function build() {
    dockerfilePath="."
    imageName="flask-app"
    imageTag="latest"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dockerfilePath=*) dockerfilePath="${1#*=}"; shift ;;
            --imageName=*) imageName="${1#*=}"; shift ;;
            --imageTag=*) imageTag="${1#*=}"; shift ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
    done

    echo "Building Docker image..."
    echo "Dockerfile Path: $dockerfilePath"
    echo "Image Name: $imageName"
    echo "Image Tag: $imageTag"

    docker build -f "$dockerfilePath/Dockerfile" -t "$imageName:$imageTag" "$dockerfilePath"
}

function push() {
    containerRegistryUsername=""
    imageName=""
    imageTag="latest"

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --containerRegistryUsername=*) containerRegistryUsername="${1#*=}"; shift ;;
            --imageName=*) imageName="${1#*=}"; shift ;;
            --imageTag=*) imageTag="${1#*=}"; shift ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
    done

    if [[ -z "$containerRegistryUsername" || -z "$imageName" ]]; then
        echo "Error: Missing required arguments."
        echo "Usage: ./pipeline.sh push --containerRegistryUsername=<username> --imageName=<image> --imageTag=<tag>"
        exit 1
    fi

    echo "Logging into Docker Hub as $containerRegistryUsername..."
    docker login -u "$containerRegistryUsername"

    fullImageName="$containerRegistryUsername/$imageName:$imageTag"

    echo "Pushing Docker image $fullImageName to Docker Hub..."
    docker tag "$imageName:$imageTag" "$fullImageName"
    docker push "$fullImageName"

    echo "Docker image pushed successfully: $fullImageName"
}


function test() {
    endpoint="http://localhost:5000/liveness" 

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --endpoint=*) endpoint="${1#*=}"; shift ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
    done

    echo "Testing the endpoint $endpoint..."

    response=$(curl -v -s -o /dev/null -w "%{http_code}" "$endpoint")

    if [[ "$response" -eq 200 ]]; then
        echo "Our application is officially live"
    else
        echo "Error: The app has errors. We have this http response: $response"
        exit 1
    fi
}

function deploy() {
    flavour="docker"
    manifestType=""
    manifestFile=""
    imageName=""
    imageTag="latest"
    containerName="flask-app-container"
    port="5000"
    nodePort=""

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --flavour=*) flavour="${1#*=}"; shift ;;
            --manifestType=*) manifestType="${1#*=}"; shift ;;
            --manifestFile=*) manifestFile="${1#*=}"; shift ;;
            --imageName=*) imageName="${1#*=}"; shift ;;
            --imageTag=*) imageTag="${1#*=}"; shift ;;
            --containerName=*) containerName="${1#*=}"; shift ;;
            --port=*) port="${1#*=}"; shift ;;
            *) echo "Unknown parameter passed: $1"; exit 1 ;;
        esac
    done

    fullImageName="$imageName:$imageTag"

    if [[ "$flavour" == "kubernetes" ]]; then
        echo "Deploying to Kubernetes cluster with manifest file $manifestFile..."

        kubectl apply -f "$manifestFile"

        if [[ "$manifestType" == "deployment" ]]; then
            echo "Setting image for deployment..."
            kubectl set image deployment/flask-app-deployment "$containerName"="$fullImageName"
        fi

        if [[ "$manifestType" == "service" ]]; then
            nodePort=$(kubectl get service flask-app-service -o=jsonpath='{.spec.ports[0].nodePort}')
            
            if [[ -n "$nodePort" ]]; then
                echo "Port to access application is: $nodePort"
            else
                echo "Service does not have a nodePort set."
            fi
        fi

    elif [[ "$flavour" == "docker" ]]; then
        echo "Deploying Docker container with image $fullImageName..."

        if [[ $(docker ps -a -q -f name="$containerName") ]]; then
            echo "Stopping and removing existing container: $containerName"
            docker rm -f "$containerName"
        fi

        docker run -d --name "$containerName" -p "$port:$port" "$fullImageName"
        echo "Container $containerName deployed successfully and running on port $port!"

    else
        echo "Unknown deployment flavour: $flavour. Supported flavours: docker, kubernetes."
        exit 1
    fi
}



command=$1
shift

case $command in
    build)
        build "$@"
        ;;
    push)
        push "$@"
        ;;
    deploy)
        deploy "$@"
        ;;
    test)
        test "$@"
        ;;
    *)
        echo "Unknown command: $command"
        exit 1
        ;;
esac
