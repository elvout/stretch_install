#!/bin/bash
set -e

REDIRECT_LOGDIR="$HOME/stretch_user/log"
CATKIN_WSDIR="$HOME/catkin_ws"
while getopts l:w: opt; do
    case $opt in
        l)
            if [[ -d $OPTARG ]]; then
                REDIRECT_LOGDIR=$OPTARG
            fi
            ;;
        w)
            CATKIN_WSDIR=$OPTARG
            ;;
    esac
done
REDIRECT_LOGFILE="$REDIRECT_LOGDIR/stretch_create_catkin_workspace.`date '+%Y%m%d%H%M'`_redirected.txt"

echo "###########################################"
echo "CREATING NOETIC CATKIN WORKSPACE at $CATKIN_WSDIR"
echo "###########################################"

echo "Ensuring correct version of ROS is sourced..."
if [[ $ROS_DISTRO && ! $ROS_DISTRO = "noetic" ]]; then
    echo "Cannot create workspace while a conflicting ROS version is sourced. Exiting."
    exit 1
fi
source /opt/ros/noetic/setup.bash

echo "Deleting $CATKIN_WSDIR if it already exists..."
sudo rm -rf $CATKIN_WSDIR
echo "Creating the workspace directory..."
mkdir -p $CATKIN_WSDIR/src
echo "Cloning the workspace's packages..."
cd $CATKIN_WSDIR/src
vcs import --input ~/stretch_install/factory/20.04/stretch_ros_noetic.repos >> $REDIRECT_LOGFILE
echo "Fetch ROS packages' dependencies (this might take a while)..."
cd $CATKIN_WSDIR/
rosdep install --from-paths src --ignore-src -r -y &>> $REDIRECT_LOGFILE
echo "Make the workspace..."
catkin_make &>> $REDIRECT_LOGFILE
echo "Source setup.bash file..."
source $CATKIN_WSDIR/devel/setup.bash
echo "Index ROS packages..."
rospack profile >> $REDIRECT_LOGFILE
# TODO:
#echo "Install ROS packages..."
#catkin_make install >> $REDIRECT_LOGFILE
echo "Update ~/.bashrc dotfile to source workspace..."
echo "source $CATKIN_WSDIR/devel/setup.bash" >> ~/.bashrc
echo "Updating meshes in stretch_ros to this robot's batch..."
. /etc/hello-robot/hello-robot.conf
export HELLO_FLEET_ID HELLO_FLEET_ID
export HELLO_FLEET_PATH=${HOME}/stretch_user
# TODO: will print to stderr but report exit code 0 for prebatch meshes not present, it should exit 1 and mitigate missing batch meshes within script
$CATKIN_WSDIR/src/stretch_ros/stretch_description/meshes/update_meshes.py &>> $REDIRECT_LOGFILE
echo "Setup uncalibrated robot URDF..."
bash -i $CATKIN_WSDIR/src/stretch_ros/stretch_calibration/nodes/update_uncalibrated_urdf.sh >> $REDIRECT_LOGFILE
echo "Setup calibrated robot URDF..."
# TODO: will print to stderr but report exit code 0 for precalibrated robots, it should exit 1 and mitigate precalibration within script
bash -i $CATKIN_WSDIR/src/stretch_ros/stretch_calibration/nodes/update_with_most_recent_calibration.sh &>> $REDIRECT_LOGFILE
echo "Compiling FUNMAP's Cython code..."
cd $CATKIN_WSDIR/src/stretch_ros/stretch_funmap/src/stretch_funmap
./compile_cython_code.sh &>> $REDIRECT_LOGFILE
