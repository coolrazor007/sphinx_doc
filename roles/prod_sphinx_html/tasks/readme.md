


1) Link: https://hub.docker.com/r/sphinxdoc/sphinx-latexpdf

2) Usage after installed:

Create a Sphinx project::

$ docker run -it --rm -v /path/to/document:/docs sphinxdoc/sphinx sphinx-quickstart

Build HTML document::

$ docker run --rm -v /path/to/document:/docs sphinxdoc/sphinx make html
