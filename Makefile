# ==============================
# 💫 Foundry Project Makefile
# ==============================

# --- Load environment ---
include .env

# --- Default variables ---
RPC_URL := $(SEPOLIA_RPC_URL)
PRIVATE_KEY := $(PRIVATE_KEY)
ETHERSCAN_API_KEY := $(ETHERSCAN_API_KEY)
CONTRACT := FundMe
SCRIPT := DeployFundMe
SRC_PATH := script/DeployFundMe.s.sol:DeployFundMe
GAS_PRICE := 25000000000  # 25 gwei

# --- Targets ---

.PHONY: help build test deploy-sepolia verify clean gas

help:
	@echo ""
	@echo "🚀 Foundry Project Commands"
	@echo "-----------------------------------------"
	@echo "make build          → Compile contracts"
	@echo "make test           → Run Foundry tests"
	@echo "make gas            → Show live gas price (from Sepolia)"
	@echo "make deploy-sepolia → Deploy FundMe to Sepolia"
	@echo "make verify         → Verify deployed contract on Etherscan"
	@echo "make clean          → Clean out build artifacts"
	@echo ""

build:
	forge build

test:
	forge test -vvv

gas:
	@echo "🔹 Checking current Sepolia gas price..."
	cast gas-price --rpc-url $(RPC_URL)

deploy-sepolia:
	@echo "🚀 Deploying $(CONTRACT) to Sepolia..."
	forge script $(SRC_PATH) \
		--rpc-url $(RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--gas-price $(GAS_PRICE) \
		--broadcast -vvv

verify:
	@echo "🔍 Verifying $(CONTRACT) on Etherscan..."
	@read -p 'Enter deployed contract address: ' ADDR; \
	forge verify-contract \
		--chain sepolia \
		--compiler-version v0.8.21+commit.d9974bed \
		--num-of-optimizations 200 \
		$$ADDR \
		src/$(CONTRACT).sol:$(CONTRACT) \
		$(ETHERSCAN_API_KEY)

clean:
	forge clean
