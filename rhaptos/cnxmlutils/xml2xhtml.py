# -*- coding: utf-8 -*-
import os
import sys
import tempfile
import argparse
import shutil
import zipfile
import urllib.request
import urllib.parse
import urllib.error
from copy import deepcopy
from io import StringIO

import pkg_resources
from lxml import etree, html
from .utils import (
    NAMESPACES,
    XHTML_INCLUDE_XPATH as INCLUDE_XPATH,
    XHTML_MODULE_BODY_XPATH as MODULE_BODY_XPATH,
    PACKAGE,
    make_xsl,
    )

dirname = os.path.dirname(__file__)


def makeXsl(filename):
    """A backward compatible shim to create XSLT stylesheet object."""
    package = '.'.join([PACKAGE, 'cnxml2html'])
    return make_xsl(filename, package=package)

def transform_collxml(collxml_file):
    """ Given a collxml file (collection.xml) this returns an HTML version of it
        (including "include" anchor links to the modules) """

    xml = etree.parse(collxml_file)
    xslt = makeXsl('collxml2xhtml.xsl')
    xml = xslt(xml)
    return xml

def transform_cnxml(cnxml_file):
    """ Given a module cnxml file (index.cnxml) this returns an HTML version of it """

    xml = etree.parse(cnxml_file)
    xslt = makeXsl('cnxml2xhtml.xsl')
    xml = xslt(xml)
    return xml

def transform_collection(collection_dir):
    """ Given an unzipped collection generate a giant HTML file representing
        the entire collection (including loading and converting individual modules) """

    collxml_file = open(os.path.join(collection_dir, 'collection.xml'))
    collxml_html = transform_collxml(collxml_file)

    # For each included module, parse and convert it
    for node in INCLUDE_XPATH(collxml_html):
        href = node.attrib['href']
        module = href.split('@')[0]
        # version = None # We don't care about version
        module_dir = os.path.join(collection_dir, module)

        # By default, use the index_auto_generated.cnxml file for the module
        module_path = os.path.join(module_dir, 'index_auto_generated.cnxml')
        if not os.path.exists(module_path):
          module_path = os.path.join(module_dir, 'index.cnxml')

        module_html = transform_cnxml(module_path)

        # Replace the include link with the body of the module
        module_body = MODULE_BODY_XPATH(module_html)

        node.getparent().replace(node, module_body[0])
    return collxml_html


def main():
    parser = argparse.ArgumentParser(description='Convert a Connexions XML markup to HTML (cnxml, collxml, and mdml)')
    parser.add_argument('-d', dest='collection_dir', help='Convert an unzipped collection to a single HTML file. Provide /path/to/collection')
    parser.add_argument('-c', dest='collection', help='The file being converted is a collxml document (collection definition)', type=argparse.FileType('r'))
    parser.add_argument('-m', dest='module', help='The file being converted is a cnxml document (module)', type=argparse.FileType('r'))
    parser.add_argument('html_file', help='/path/to/outputfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
    args = parser.parse_args()

    if args.collection_dir:
      html = transform_collection(args.collection_dir)
    elif args.collection:
      html = transform_collxml(args.collection)
    elif args.module:
      html = transform_cnxml(args.module)
    else:
      print("Must specify either -d -c or -m", file=sys.stderr)
      return 1

    args.html_file.write(etree.tostring(html))

if __name__ == '__main__':
    sys.exit(main())
