$PLATFORM_IO_VERSION=6.1.5
$PYTHON_URL_BASE="https://github.com/indygreg/python-build-standalone/releases/download/"
$PYTHON_RELEASE="20230116"
$PYTHON_VERSION="3.11.1"
$PYTHON_ARCH="x86_64"
$PYTHON="$pwd/build/python/bin/python3"
$PYTHON_ARCH="$PYTHON_ARCH-pc-windows-msvc-shared"

$PYTHON_URL="${PYTHON_URL_BASE}/${PYTHON_RELEASE}/cpython-${PYTHON_VERSION}+$PYTHON_RELEASE-$PYTHON_ARCH-install_only.tar.gz"
echo "downloading ${PYTHON_URL}"
mkdir build
cd build
Invoke-WebRequest -Uri $PYTHON_URL -OutFile python.tar.gz
tar -xzf python.tar.gz
Remove-Item -Recurse -Force python.tar.gz
& $PYTHON -m pip install platformio==$PLATFORM_IO_VERSION
$Env:PLATFORMIO_CORE_DIR="$pwd\\platformio"
$Env:PYTHONUNBUFFERED=1
cd ..\\Ardwiino
& $PYTHON -m platformio pkg install
Remove-Item -Recurse -Force .pio
Remove-Item -Recurse -Force ..\\build\\platformio\\.cache
& $PYTHON -m platformio pkg install
cd ..\\build
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinopico\\pico-sdk\\lib\\btstack\\port
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinopico\\pico-sdk\\lib\\btstack\\example
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinopico\\pico-sdk\\lib\\btstack\\chipset
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinopico\\docs
Remove-Item -Recurse -Force platformio\\packages\\framework-arduino-avr\\firmwares
Remove-Item -Recurse -Force platformio\\packages\\framework-arduino-avr\\bootloaders
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinoespressif32\\tools\\sdk\\esp32c3
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinoespressif32\\tools\\sdk\\esp32s2
Remove-Item -Recurse -Force platformio\\packages\\framework-arduinoespressif32\\tools\\sdk\\esp32s3
7z.exe a -ttar -so platformio.tar.xz platformio | 7z.exe a -txz -si platformio.tar.xz -mx9