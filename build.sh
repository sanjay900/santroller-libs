#!/usr/bin/env bash
PLATFORM_IO_VERSION=6.1.5
PYTHON_URL_BASE="https://github.com/indygreg/python-build-standalone/releases/download/"
PYTHON_RELEASE="20230116"
PYTHON_VERSION="3.11.1"
PYTHON_ARCH="x86_64"
PYTHON="`pwd`/build/python/bin/python3"
case "$OSTYPE" in
  linux*)   PYTHON_ARCH="$PYTHON_ARCH-unknown-linux-gnu" ;;
  darwin*)  PYTHON_ARCH="$PYTHON_ARCH-apple-darwin" ;; 
  *)        echo "unknown: $OSTYPE" ;;
esac

PYTHON_URL="$PYTHON_URL_BASE/$PYTHON_RELEASE/cpython-$PYTHON_VERSION+$PYTHON_RELEASE-$PYTHON_ARCH-install_only.tar.gz"
echo downloading $PYTHON_URL
mkdir build
cd build
wget $PYTHON_URL -O python.tar.gz
tar -xzf python.tar.gz
rm -rf python.tar.gz
$PYTHON -m pip install pyusb
$PYTHON -m pip install libusb_package
$PYTHON -m pip install platformio==$PLATFORM_IO_VERSION
export PLATFORMIO_CORE_DIR=`pwd`/platformio
export PYTHONUNBUFFERED=1
cd ../Ardwiino
$PYTHON -m platformio pkg install
rm -rf .pio
rm -rf ../build/platformio/.cache
$PYTHON -m platformio pkg install
cd ../build
rm -rf platformio/packages/framework-arduinopico/pico-sdk/lib/btstack/port
rm -rf platformio/packages/framework-arduinopico/pico-sdk/lib/btstack/example
rm -rf platformio/packages/framework-arduinopico/pico-sdk/lib/btstack/chipset
rm -rf platformio/packages/framework-arduinopico/docs
rm -rf platformio/packages/framework-arduino-avr/firmwares
rm -rf platformio/packages/framework-arduino-avr/bootloaders
export XZ_OPT="-T0 -9"
tar cf platformio.tar platformio python
cd ../default
$PYTHON -m platformio run
cd ../build
mkdir default_firmwares
cp ../uno_usb_firmwares/*.hex default_firmwares
for filename in ../default/.pio/build/**/*.hex; do
    dir=$(basename $(dirname $filename))
    cp $filename default_firmwares/$dir.hex
done

for filename in ../default/.pio/build/**/*.uf2; do
    dir=$(basename $(dirname $filename))
    cp $filename default_firmwares/$dir.uf2
done
tar rf platformio.tar default_firmwares
xz -z -9 -T0 platformio.tar