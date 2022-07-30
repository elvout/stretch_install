#!/bin/bash
set -e

REDIRECT_LOGFILE="$HOME/stretch_user/log/stretch_install_dev_tools.`date '+%Y%m%d%H%M'`_redirected.txt"

echo "#############################################"
echo "INSTALLATION OF DEV TOOLS FOR HELLO ROBOT INTERNAL PRODUCTION"
echo "#############################################"

echo "Install Typora"
wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
sudo add-apt-repository 'deb https://typora.io/linux ./'
sudo apt-get update >> $REDIRECT_LOGFILE
sudo apt-get install --yes typora >> $REDIRECT_LOGFILE

echo "Install Chromium"
sudo apt-get install --yes chromium-browser >> $REDIRECT_LOGFILE

echo "Install Arduino CLI"
cd ~/stretch_install/factory/20.04/
./stretch_install_arduino.sh >> $REDIRECT_LOGFILE

echo "Install PyCharm"
sudo snap install pycharm-community --classic >> $REDIRECT_LOGFILE

echo "Install tools for system QC and bringup"
pip3 install -q twine
pip3 install -q gspread
pip3 install -q gspread-formatting
pip3 install -q oauth2client rsa==3.4
pip3 install -q mkdocs mkdocs-material mkdocstrings==0.17.0 pytkdocs[numpy-style] jinja2=3.0.3

echo "Cloning repos"
cd ~/repos/
git clone https://github.com/hello-robot/stretch_install.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_factory.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_body.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_firmware.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_fleet.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_fleet_tools.git >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/hello-robot.github.io >> $REDIRECT_LOGFILE
git clone https://github.com/hello-robot/stretch_docs >> $REDIRECT_LOGFILE

# update .bashrc to add body code directory to the Python path

#echo "export PATH=\${PATH}:~/repos/stretch_body/python/bin" >> ~/.bashrc
#echo "export PATH=\${PATH}:~/repos/stretch_factory/python/tools" >> ~/.bashrc

#echo "export PYTHONPATH=\${PYTHONPATH}:~/repos/stretch_factory/python/tools" >> ~/.bashrc
#echo "export PYTHONPATH=\${PYTHONPATH}:~/repos/stretch_body/python" >> ~/.bashrc

#echo "Source new bashrc now...Done."
#echo ""
