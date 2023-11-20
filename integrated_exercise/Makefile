AWS_ECR_ACCOUNT ?= 299641483789
CONTAINER_REGISTRY ?= $(AWS_ECR_ACCOUNT).dkr.ecr.eu-west-1.amazonaws.com
docker_repo := $(CONTAINER_REGISTRY)/niels-integrated-exercise

docker-push:
	docker buildx create --bootstrap --name conveyor || true
	docker buildx use conveyor
	docker buildx build --platform linux/amd64 . -t "$(docker_repo):latest" --push --cache-to type=inline
