FLIX ?= flix
EX_SRC  = src/FpInFlix/Exercises
EX_TEST = test/FpInFlix/Exercises
SRC = $(shell find src -name '*.flix')

# `CH={章に対応するモジュール名}` が指定されたときだけファイル群を渡す(指定なしのときはプロジェクト全体)
CHAPTER = $(strip $(CH))
FILES  = $(if $(CHAPTER),$(SRC) $(wildcard $(EX_TEST)/$(CHAPTER)/*.flix))
guard  = $(if $(CHAPTER),$(if $(wildcard $(EX_SRC)/$(CHAPTER).flix),,$(error Chapter not found: $(CHAPTER))))

.PHONY: lint
lint: format-check

# flix formatには--checkがないため、その場で整形してから差分の有無を見る
# ℹ️ 未コミットの.flixファイルがあると、整形済みでも差分として検出される
.PHONY: format-check
format-check:
	@$(FLIX) format
	@git diff --exit-code -- '*.flix'

.PHONY: format
format:
	@$(FLIX) format

.PHONY: check
check:
	@$(FLIX) check

.PHONY: build
build:
	@$(FLIX) build

.PHONY: repl
repl:
	@$(FLIX) repl

.PHONY: test
test:
	$(guard)
	@$(FLIX) test $(FILES)

.PHONY: chapters
chapters:
	@ls $(EX_SRC)/*.flix | xargs -n1 basename | sed 's/\.flix$$//'
