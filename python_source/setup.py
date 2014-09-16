from distutils.core import setup
import py2exe

setup(console=['run_server.py'], options={'py2exe':{"bundle_files":1}})
