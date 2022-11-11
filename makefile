buildc:
	cd circuits && nargo build && cd ..

compc:
	cd circuits && nargo compile test && cd ..

provec:
	cd circuits && nargo prove test && cd ..

test:
	npx hardhat test
