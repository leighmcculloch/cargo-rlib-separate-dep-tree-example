build:
	cd rlib1 && cargo build --release
	cd rlib2 && cargo build --release
	cd bridge && cargo build --release

clean:
	rm -fr bridge/target
	rm -fr rlib1/target
	rm -fr rlib2/target

test: build
	./bridge/target/release/bridge
