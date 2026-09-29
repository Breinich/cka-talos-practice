SHELL := /usr/bin/env bash
.PHONY: test check-metadata setup score teardown restore reset

test:
	./tests/static.sh

check-metadata:
	./tests/static.sh

setup:
	./scripts/setup.sh

score:
	./scripts/validate.sh

teardown:
	./scripts/teardown.sh

restore:
	./scripts/restore.sh

reset:
	./scripts/reset.sh
