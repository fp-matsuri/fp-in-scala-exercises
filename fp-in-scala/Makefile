.PHONY: lint
lint: scalafmt-check scalafix-lint

.PHONY: scalafmt-check
scalafmt-check:
	@scalafmt --check src

.PHONY: scalafmt-fix
scalafmt-fix:
	@scalafmt src

.PHONY: scalafix-lint
scalafix-lint:
	@scalafix --check src

.PHONY: compile
compile:
	@sbt compile

.PHONY: test
test:
	@sbt test
