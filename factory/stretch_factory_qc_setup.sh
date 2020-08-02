#!/bin/bash

#####################################################
echo "To be run prior to system bringup at the factory "

read -p "Proceed with installation (y/n)?" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

sudo apt install --yes chromium-browser
sudo snap install pycharm-community --classic
pip2 install hello-robot-stretch-factory
pip2 install gspread
pip2 install gspread-formatting
pip2 install oauth2client

#pip uninstall stretch-body
echo "Cloning repos."
cd ~/repos/
git clone https://github.com/hello-robot/stretch_fleet.git
git clone https://github.com/hello-robot/stretch_fleet_tools.git
echo "Done."
echo ""

