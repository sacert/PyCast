from setuptools import setup

setup(
	name = 'PyCast',
	version = '0.1',
	description = 'Searches and downloads podcasts to the user\'s liking',
	author = 'Stephen Kang',
	author_email = 'stephenkang9@gmail.com',
	url = 'https://github.com/sacert/PyCast',
    packages = [ 'PyCast' ],
    scripts=['bin/PyCast'],
    zip_safe=True
)
