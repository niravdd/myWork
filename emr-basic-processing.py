#!/usr/bin/env python

import sys
import json

if __name__ == "__main__"
	dump = json.dumps(sys.stdin)
	core = json.loads(dump)
	print "------------------"
	print core
	print "------------------"
	for i in core:
		print core['playerid'], core['result'], core['squadelementmap']