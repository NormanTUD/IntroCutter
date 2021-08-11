from pprint import pprint
import os
from sys import exit
import sys
from PIL import Image
import imagehash
import re

def die (string):
    pprint(string)
    sys.exit(1)

class REMatcher(object):
    def __init__(self, matchstring):
        self.matchstring = matchstring

    def match(self,regexp):
        self.rematch = re.match(regexp, self.matchstring)
        return bool(self.rematch)

    def group(self,i):
        return self.rematch.group(i)

hash_to_image = {}

tmpdir = os.path.abspath(sys.argv[1])

for directory in os.listdir(tmpdir):
    for filename in os.listdir(tmpdir + "/" + directory):
        if filename.endswith(".png"):
            filepath = os.path.join(tmpdir + "/" + directory, filename)
            this_hash = imagehash.average_hash(Image.open(filepath))
            if not str(this_hash) in hash_to_image:
                hash_to_image[str(this_hash)] = []

            if str(this_hash) != "0000000000000000":
                hash_to_image[str(this_hash)].append(filepath)

last_file_to_frame = {}
for k in sorted(hash_to_image, key=lambda k: len(hash_to_image[k]), reverse=True):
    for item in hash_to_image[k]:
        m = REMatcher(item)
        if m.match(tmpdir + r"/(.*)/output_(\d*).png"):
            thisfile = m.group(1)
            thisframe = m.group(2)
            if not thisfile in last_file_to_frame:

                last_file_to_frame[thisfile] = thisframe
            else:
                if last_file_to_frame[thisfile] < thisframe:
                    last_file_to_frame[thisfile] = thisframe
    for md5hash in last_file_to_frame:
        print("%s ::: %s" % (md5hash, last_file_to_frame[md5hash]))
    exit(0)
