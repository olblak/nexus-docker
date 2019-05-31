NEXUS_VERSION=$(shell cat VERSION)
IMAGE="olblak/nexus"
TAG="$(NEXUS_VERSION)"

version:
	@echo $(NEXUS_VERSION)

build:
	docker build --no-cache -t $(IMAGE):$(TAG) -t $(IMAGE):latest --build-arg VERSION=$(NEXUS_VERSION) .

logs:
	docker logs -f nexus_nexus_1

run:
	docker run -i -t $(IMAGE):$(TAG)

shell:
	docker run --entrypoint /bin/bash -i -t $(IMAGE):$(TAG)

ldap:
	docker-compose up -d ldap

ldap.restore: ldap
	docker exec -i -t nexus_ldap_1 /entrypoint/restore

ldap.check: ldap
	docker exec -i -t nexus_ldap_1 /entrypoint/healthcheck

publish:
	docker push $(IMAGE):$(TAG)
