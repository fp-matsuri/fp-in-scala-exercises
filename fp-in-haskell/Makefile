.PHONY: lint
lint: format-check hlint

.PHONY: hlint
hlint:
	@hlint src

.PHONY: format-check
format-check:
	@fourmolu --mode check src test

.PHONY: format
format:
	@fourmolu --mode inplace src test

.PHONY: build
build:
	@cabal build

.PHONY: test
test:
	@cabal test
