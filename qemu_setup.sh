#!/usr/bin/env bash
mkdir qemu_extract
cd qemu_extract
echo "########## Downloading qemu... ##########"
apt-get download qemu-system-x86
echo "########## Extracting qemu... ##########"
dpkg -x qemu-system-*.deb .
mkdir -p qemu_packed/lib
cp usr/bin/qemu-system-x86_64 qemu_packed
echo "########## Copy libs... ##########"
ldd usr/bin/qemu-system-x86_64 | grep "=>" | grep -v "not found" | awk '{print "cp "$3" qemu_packed/lib/"}' | bash
mkdir not_found
cd not_found
echo "########## Get not found libs... ##########"
ldd ../usr/bin/qemu-system-x86_64 | grep "not found" | awk '{print $1}' > not_found.txt
echo "########## Download not found libs... ##########"
for lib in $(cat not_found.txt); do echo "=== Dealing with $lib ==="; apt-file search --regexp "/${lib}\$" | sed 's/:.*//' | xargs apt-get download; done
echo "########## Extracting not found libs... ##########"
ls *.deb | xargs -I{} dpkg -x "{}" .
echo "########## Copying not found libs... ##########"
find . | grep ".so" | xargs -I{} cp "{}" ../qemu_packed/lib
cd ..
echo "########## Getting pc-bios... ##########"
git clone https://github.com/qemu/qemu.git
cp -r qemu/pc-bios qemu_packed
echo "########## Finished !!! ##########"
echo "The output file should be in the folder qemu_extract/qemu_packed."
echo "Once you have a filesystem image, you can run it using:"
echo "$ LD_LIBRARY_PATH=$(pwd)/lib ./qemu-system-x86_64 -L pc-bios -no-kvm -m 256 -drive if=virtio,file=<your image>.qcow2,cache=none -display curses -k fr -redir tcp:22222::22"
echo "Don't forget to replace <your image>"
