#!/usr/bin/python
# a reference to openscad must exist
# sudo ln -sf /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD /usr/local/bin/openscad

import subprocess
import math
import time
import os
import sys

# render the stl
def scad(part):
	cwd = os.getcwd()
	project = os.path.basename(cwd)
	stl = project + "-" + part + ".stl"
	print 'Starting render of', stl
	partarg = 'PART=\"' + part + '\"'
	return subprocess.Popen(['openscad','-D', partarg, 'parts.scad', '-o', stl])

def render(parts):
	# render each part in a thread, so it all goes faster
	print 'Rendering', str(len(parts)), 'parts'
	start = time.time()

	threads = []

	# start the openscad threads
	for p in parts:
		threads.append(scad(p))

	# wait for all threads to finish, so we know we're done
	for s in threads:
		s.wait()

	elapsed = round(time.time() - start, 1)
	# bell
	sys.stdout.write('\a')
	sys.stdout.flush()
	print 'Done rendering', str(len(parts)), 'parts in', elapsed, 'seconds!'

def main():
	parts = [
	"wall_bracket",
	"engine_blank"
	 ]
	render(parts)

main()
