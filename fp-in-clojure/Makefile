.PHONY: lint
lint: cljstyle-check clj-kondo-lint joker-lint

.PHONY: cljstyle-check
cljstyle-check:
	@cljstyle check

.PHONY: cljstyle-fix
cljstyle-fix:
	@cljstyle fix

.PHONY: clj-kondo-lint
clj-kondo-lint:
	@clj-kondo --lint src

.PHONY: joker-lint
joker-lint:
	@joker --lint --working-dir .

.PHONY: test
test:
	@clojure -T:build test

.PHONY: test-and-build
test-and-build:
	@clojure -T:build ci
