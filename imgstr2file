#!/usr/bin/python
import base64
import sys

def base642image(datastr , save_file):
	fh = open(save_file, "wb")
	fh.write(datastr.decode('base64'))
	fh.close()

if __name__ == "__main__":
	save_file = sys.argv[1]
	data_str = sys.stdin.read()
	#print save_file
	base642image(data_str,save_file)

