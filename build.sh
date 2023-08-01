BUILD_DIR=./build

if [ -d $BUILD_DIR ]
then
    rm -r $BUILD_DIR
fi

mkdir build

echo "Compiling the scanner .."
flex -o $BUILD_DIR/scanner.c scanner.l
gcc $BUILD_DIR/scanner.c -lfl -o $BUILD_DIR/scanner.o
rm $BUILD_DIR/scanner.c

echo "Done."