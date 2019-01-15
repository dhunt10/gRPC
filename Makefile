
GO_ENV := CGO_ENABLED=0
SERVICE_NAME := $(shell basename ${PWD})
VERSION ?= latest

.PHONY: build
build:
	@$(GO_ENV) go build \
		-ldflags "-X main.version=$(VERSION)" \
		-o build/$(SERVICE_NAME)

.PHONY: run
run:
	@$(GO_ENV) go run \
		-ldflags "-X main.version=$(VERSION)" \
		main.go

.PHONY: dep
dep:
	@go get github.com/golang/dep/cmd/dep
	@dep ensure -v

.PHONY: dep-update
dep-update:
	@dep ensure -update

.PHONY: test
test:
	@go test ./...

.PHONY: fmt
fmt:
	@find . -iname "*.go" -not -path "./vendor/**" | xargs gofmt -s -w

.PHONY: cover
cover:
	@go test -coverpkg=./... -coverprofile=coverage.txt ./...

.PHONY: docker
docker:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg SERVICE_NAME=$(SERVICE_NAME) \
		-t gcr.io/mercari-artifacts/$(SERVICE_NAME):$(VERSION) \
		.

.PHONY: submit
submit:
	@find vendor -type l -delete # remove symlink files
	gcloud builds submit . \
		--project=mercari-artifacts \
		--config=cloudbuild.yaml \
		--gcs-log-dir="gs://mercari-artifacts_cloudbuild_logs/logs" \
		--substitutions="_VERSION=$(VERSION),_SERVICE_NAME=$(SERVICE_NAME)"
