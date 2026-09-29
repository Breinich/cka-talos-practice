SHELL := /usr/bin/env bash
.PHONY: test check-metadata setup score teardown restore reset

test:
	./tests/static.sh

check-metadata:
	./tests/static.sh

setup:
	./scripts/setup.sh $(ID)

score:
	./scripts/score.sh $(ID)

teardown:
	./scripts/teardown.sh $(ID)

restore:
	./scripts/restore.sh $(ID)

reset:
	./scripts/reset.sh $(ID)
