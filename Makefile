all: pdfa-gs-converter.sh

.PHONY: all clean

clean:
	rm -fr build pdfa-gs-converter.sh

pdfa-gs-converter.sh: src/main.sh src/files/PDFA_bu.ps src/files/srgb.icc
	rm -fr build
	mkdir -p build
	cd src/files && tar zcf ../../build/files.tar.gz *
	cat src/main.sh build/files.tar.gz > "$@"
	chmod 755 "$@"
	rm -fr build
