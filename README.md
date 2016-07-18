# bosh-pyfunc
python functions for BigObject python bosh

requirement: bosh 0.2.18+ , numpy, scipy
```
sudo pip install --upgrade pip
sudo pip install numpy
sudo pip install scipy
sudo pip install bosh
```

## Kmean : kmean , getKmeanCent , getKmeanLabel

**kmean**: compute k mean clustering

**getKmeanCent**: receive k mean clustering centroids result 

**getKmeanLabel**: use the centroids to tag a label

ex. use BigObject sample data (100k rows)

1.use the first 99990 rows (Customer.id, Product.id) as data to compute k-mean (k=5)
```
bosh>send "select Customer.id , Product.id from sales limit 99990" to "./kmean 5"
(99990, 2)
[[ 1855.87585289  1062.72896211]
 [ 8251.09389935  3361.39229688]
 [ 8132.9635468   1052.72873563]
 [ 5032.42945336  2278.14705143]
 [ 1759.97057683  3352.3180584 ]]
```
2.receive the k-mean centroids result 
```
bosh>create table cent(col1 FLOAT, col2 FLOAT)
bosh>receive cent from "./getKmeanCent"
bosh>select * from cent
1855.88,1062.73
8251.09,3361.39
8132.96,1052.73
5032.43,2278.15
1759.97,3352.32
=============
total row : 5
```

3.use the centroids result to label the last 10 rows

```
bosh>create table label(label INT32)
bosh>send "select Customer.id , Product.id from sales limit 10 offset 99990" to "./getKmeanLabel" return to label
bosh>select * from label
0
3
3
4
0
4
0
0
4
0
=============
total row : 10

```

## Load images : loadImage, loadImagePath, imgstr2file (use base64 coding)

**loadImage**: load an image into a BigObject table

ex. load pic/tree.jpg into the "image" table. 

Note: since the VARSTRING max length is limited, you can only load small images into a column

```
bosh>CREATE TABLE images ('filename' STRING(63), 'content' VARSTRING(32766))
bosh>receive images from "./loadImage pic/tree.jpg"
```

**loadImagePath**: load images in a diretory into a BigObject table

ex. load pic/* into the "image" table. 

```
bosh>receive images from "./loadImagePath pic"
bosh>select filename from images
pic/tree.jpg
tree.jpg
notebook.jpg
dog.jpg
cat.jpg
rabbit.jpg
=============
total row : 5
```

**imgstr2file**: write a image string in BigObject table into a file

ex. write the image content (cat.jpg) to the file "tmp.jpg"
```
bosh>send "select content from images where filename='cat.jpg'" to "./imgstr2file tmp.jpg"
```

##Tensorflow image recognition demo : tf_image

use pip to install tensorflow (Ubuntu/Linux 64-bit, CPU only, Python 2.7)
```
sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl 
```
Please refer https://www.tensorflow.org/versions/r0.9/get_started/os_setup.html#pip-installation for detail

**tf_image** : read the image stored in BigObject table and then run tensorflow image recognition

```
send "select content from images where filename='cat.jpg'" to "./tf_image"
W tensorflow/core/framework/op_def_util.cc:332] Op BatchNormWithGlobalNormalization is deprecated. It will cease to work in GraphDef version 9. Use tf.nn.batch_normalization().
tiger cat (score = 0.54326)
tabby, tabby cat (score = 0.27918)
Egyptian cat (score = 0.10635)
lynx, catamount (score = 0.01014)
tiger, Panthera tigris (score = 0.00103)
```
