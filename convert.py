#!/usr/bin/env python

import sys
import yaml
from pprint import pprint

fname = sys.argv[1]

stream = open(fname,'r')

yml = yaml.load(stream)

pprint(yml)
