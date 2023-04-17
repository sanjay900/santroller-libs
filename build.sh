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
rm -rf platformio/packages/framework-arduinoespressif32/tools/sdk/esp32c3
rm -rf platformio/packages/framework-arduinoespressif32/tools/sdk/esp32s2
rm -rf platformio/packages/framework-arduinoespressif32/tools/sdk/esp32s3
export XZ_OPT="-T0 -9"
tar cfJ platformio.tar.xz platformio python