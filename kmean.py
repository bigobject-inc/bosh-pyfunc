#!/usr/bin/python
from numpy import vstack,array
from numpy.random import rand
from scipy.cluster.vq import kmeans,vq

import sys
import numpy as np
def kmean_fun(k=2, tmp_file_name='./centroids.txt'):
	data = np.loadtxt(sys.stdin, delimiter=',' ,dtype=np.float)
	print data.shape
	centroids,_ = kmeans(data,int(k))
	print centroids
	np.savetxt(tmp_file_name, centroids)

if __name__ == "__main__":
	k = 2
	tmp_file='./centroids.txt'
	if len(sys.argv) > 1:
		k = sys.argv[1]
	if len(sys.argv) > 2:
		tmp_file = sys.argv[2]
	kmean_fun(k, tmp_file)
