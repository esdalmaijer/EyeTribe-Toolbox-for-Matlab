from distutils.core import setup
import py2exe

setup(console=['EyeTribe_Matlab_server.py'], options={'py2exe':{"bundle_files":1}}, zipfile=None)
