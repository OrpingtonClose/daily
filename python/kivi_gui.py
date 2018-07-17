#sudo add-apt-repository ppa:kivy-team/kivy
#sudo apt-get update
#sudo apt-get install python3-kivy
#sudo -H pip3 install cython==0.23
#the above doesn't work on Ubuntu 17.10

#sudo pip3 install pygments docutils
#sudo apt-get install python3-setuptools python3-pygame python3-opengl python3-enchant python3-dev build-essential python3-pip libgl1-mesa-dev libgles2-mesa-dev zlib1g-dev
#sudo apt-get install freeglut3-dev #for "gl.h"
#sudo pip install --upgrade Cython==0.28.3
#git clone http://github.com/kivy/kivy
#cd kivy
#make
#export PYTHONPATH=~/code/kivy:$PYTHONPATH
#DOESNT WORK IN UBUNTU 17 AS WELL AS IT SHOULD, which means not at all
"""
some python versions are compiled with the the flag --with-fpectl
cython somehow is sensitive to this setting
the solution was here:
https://github.com/pytoolz/cytoolz/issues/120

sudo -H pip3 install --no-cache-dir pygame
sudo -H pip3 install --no-cache-dir kivy
"""

import kivy
kivy.require('1.9.0')
from kivy.app import App
from kivy.uix.label import Label

class MyApp(App):
  def build(self):
    return Label(text='Hello World')

MyApp().run()
