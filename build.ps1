$PLATFORM_IO_VERSION="6.1.5"
$PYTHON_URL_BASE="https://github.com/indygreg/python-build-standalone/releases/download"
$PYTHON_RELEASE="20230116"
$PYTHON_VERSION="3.11.1"
$PYTHON_ARCH="x86_64"
$PYTHON="$pwd\build\python\python.exe"
$PYTHON_ARCH="$PYTHON_ARCH-pc-windows-msvc-shared"

$PYTHON_URL="${PYTHON_URL_BASE}/${PYTHON_RELEASE}/cpython-${PYTHON_VERSION}+$PYTHON_RELEASE-$PYTHON_ARCH-install_only.tar.gz"
echo "downloading ${PYTHON_URL}"
mkdir build
cd build
Invoke-WebRequest -Uri $PYTHON_URL -OutFile python.tar.gz
tar -xzf python.tar.gz
Remove-Item -Recurse -Force python.tar.gz
& $PYTHON -m pip install pyusb
& $PYTHON -m pip install libusb_package
& $PYTHON -m pip install platformio==${PLATFORM_IO_VERSION}
$Env:PLATFORMIO_CORE_DIR="$pwd\platformio"
$Env:PYTHONUNBUFFERED=1
cd ..\Ardwiino
& $PYTHON -m platformio pkg install
Remove-Item -Recurse -Force .pio
Remove-Item -Recurse -Force ..\build\platformio\.cache
& $PYTHON -m platformio pkg install
cd ..\build
Remove-Item -Recurse -Force platformio\packages\framework-arduinopico\pico-sdk\lib\btstack\port
Remove-Item -Recurse -Force platformio\packages\framework-arduinopico\pico-sdk\lib\btstack\example
Remove-Item -Recurse -Force platformio\packages\framework-arduinopico\pico-sdk\lib\btstack\chipset
Remove-Item -Recurse -Force platformio\packages\framework-arduinopico\docs
Remove-Item -Recurse -Force platformio\packages\framework-arduino-avr\firmwares
Remove-Item -Recurse -Force platformio\packages\framework-arduino-avr\bootloaders
Remove-Item -Recurse -Force platformio\packages\framework-arduinoespressif32\tools\sdk\esp32c3
Remove-Item -Recurse -Force platformio\packages\framework-arduinoespressif32\tools\sdk\esp32s2
Remove-Item -Recurse -Force platformio\packages\framework-arduinoespressif32\tools\sdk\esp32s3
tar cf platformio.tar platformio python
cd ..\default
& $PYTHON -m platformio run
cd ..\build
New-Item -Name default_firmwares -ItemType "directory"
Get-ChildItem -Path '..\default\.pio' -Filter *.hex -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object { 
    $dir = Split-Path $_.DirectoryName -Leaf 
    Copy-Item $_ -Destination "default_firmwares\$dir.hex"
}
Get-ChildItem -Path '..\default\.pio' -Filter *.uf2 -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object { 
    $dir = Split-Path $_.DirectoryName -Leaf 
    Copy-Item $_ -Destination "default_firmwares\$dir.uf2"
}

Get-ChildItem -Path '..\uno_usb_firmwares' -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object { 
    Copy-Item $_ -Destination "default_firmwares"
}
tar rcf platformio.tar default_firmwares
7z.exe a -txz -mx9 platformio.tar.xz platformio.tar