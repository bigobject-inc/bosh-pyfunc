#!/usr/bin/python
import base64	
import sys
from os import listdir
from os.path import isfile, join

def image2base64(filename):
	with open(filename, "rb") as imageFile:
		str = base64.b64encode(imageFile.read())
		return str

def list_file(path):
	onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]
	return onlyfiles

def base642image(datastr , save_file):
	fh = open(save_file, "wb")
	fh.write(datastr.decode('base64'))
	fh.close()

def load_image_path(path):
	file_list = list_file(path)
	for f_i in file_list:
		print f_i + " " + image2base64(path + "/" + f_i)

if __name__ == "__main__":
	pic_path = sys.argv[1]
	load_image_path(pic_path)
#	image_convert("pic/Screenshot-1.png")
# 	list_file("pic")
	#print "done"
