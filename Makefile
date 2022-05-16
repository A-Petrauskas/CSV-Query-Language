BUILD_DIR := _build

.PHONY : csvql token clean test

csvql : grammar
	@ghc -i$(BUILD_DIR) -odir $(BUILD_DIR) -hidir $(BUILD_DIR) -o csvql Main.hs

token : Token.x $(BUILD_DIR)
	@alex Token.x -o $(BUILD_DIR)/Token.hs

grammar : token
	@happy Grammar.y -o $(BUILD_DIR)/Grammar.hs

$(BUILD_DIR) :
	$(info Creating build directory...)
	@mkdir -p $(BUILD_DIR)

clean :
	$(info Removing $(BUILD_DIR))
	@rm -rf $(BUILD_DIR)
