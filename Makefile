.PHONY: lint
lint:
	dart fix --dry-run lib
	dart fix --dry-run test
	dart format --set-exit-if-changed lib test
	flutter analyze lib test
