# fp-in-sml: Functional Programming in Scala の演習を Standard ML で解く
#
# Usage:  make test          演習を MLton でビルドして全てのテストを実行 (未実装のものは todo 表示)
#         make answers       解答を MLton でビルドして全てのテストを実行 (すべてパスすることを期待)
#         make test CH=ch03  章ごとのフィルタ (テスト名の部分一致)
#         make repl          SML/NJ の REPL を起動 (CM.make の読み込み後に Test.run を実行)
#         make nj-test       演習を SML/NJ で非対話実行 (CI で利用)
#         make nj-answers    解答を SML/NJ で非対話実行 (CI で利用)
#         make fmt           smlfmt でコードを整形
#         make clean         ビルド生成物の削除

MLTON ?= mlton
SML   ?= sml
SMLFMT ?= smlfmt

BUILD := build
CH    ?=

EXE_EXERCISES := $(BUILD)/run-exercises
EXE_ANSWERS   := $(BUILD)/run-answers

.PHONY: test answers repl nj-test nj-answers fmt clean

test:
	$(MLTON) -output $(EXE_EXERCISES) $(BUILD)/exercises.mlb
	./$(EXE_EXERCISES) $(CH)

answers:
	$(MLTON) -output $(EXE_ANSWERS) $(BUILD)/answers.mlb
	./$(EXE_ANSWERS) $(CH)

repl:
	@echo '== SML/NJ REPL =='
	@echo '演習側のビルドとテスト:  CM.make "$(BUILD)/exercises.cm"; Test.run ();'
	@echo '解答側のビルドとテスト:  CM.make "$(BUILD)/answers.cm";   Test.run ();'
	@if command -v rlwrap >/dev/null 2>&1; then \
		rlwrap $(SML); \
	else \
		$(SML); \
	fi

# SML/NJ で非対話実行．(CM.make → Test.run の終了コードで成否を返す)
# OS.Process.exit は戻り型が 'a なので，トップレベル式のままだと値制限の警告が出ます．
nj-test:
	@printf 'CM.make "$(BUILD)/exercises.cm";\nval _ = OS.Process.exit (Test.run ());\n' | $(SML)

nj-answers:
	@printf 'CM.make "$(BUILD)/answers.cm";\nval _ = OS.Process.exit (Test.run ());\n' | $(SML)

fmt:
	$(SMLFMT) --force $(BUILD)/exercises.mlb $(BUILD)/answers.mlb

clean:
	rm -f $(EXE_EXERCISES) $(EXE_ANSWERS)
