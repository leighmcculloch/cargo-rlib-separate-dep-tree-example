build:
	cd rlib1 && cargo build --release
	cd rlib2 && cargo build --release
	cd bridge && cargo rustc --release -- \
		--extern rlib1=../rlib1/target/release/librlib.rlib \
		--extern rlib2=../rlib2/target/release/librlib.rlib \
		-L dependency=../rlib1/target/release/deps \
		-L dependency=../rlib2/target/release/deps

clean:
	rm -fr bridge/target
	rm -fr rlib1/target
	rm -fr rlib2/target

test: build
	./bridge/target/release/bridge
