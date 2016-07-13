#!/usr/bin/python
import sys
import numpy as np
import re
from scipy.cluster.vq import vq

def get_kmean_label(centroids_file_name='./centroids.txt'):
	data = np.loadtxt(sys.stdin, delimiter=',' ,dtype=np.float)

	centroids = np.loadtxt(centroids_file_name, dtype=np.float)
	a,_ = vq(data,centroids)
	res_str = "\n".join([str(p) for p in a])
	print res_str


if __name__ == "__main__":
	centroids_file = './centroids.txt'
	if len(sys.argv) > 1:
		centroids_file = sys.argv[1]
	
	get_kmean_label(centroids_file)
