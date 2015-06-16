#!/bin/bash
cd ~/Downloads
wget http://sourceforge.net/projects/bochs/files/bochs/2.6.2/bochs-2.6.2.tar.gz
tar -xvvzf bochs-2.6.2.tar.gz
cd bochs-2.6.2
./configure --enable-debugger --enable-disasm --disable-docbook --enable-readline --enable-debugger-gui LDFLAGS='-pthread' --prefix=/home/$USER/Downloads/bochs-2.6.2
rm bochs-2.6.2.tar.gz
make
make install
cd /home/$USER
echo "export PATH+=":/home/dsabarros/Downloads/bochs-2.6.2/bin/"">>.bashrc
echo "alias ORGA='cd /home/dsabarros/orga2/TP3/entregable/tp3-bundle.v1/src/'">>.bashrc

