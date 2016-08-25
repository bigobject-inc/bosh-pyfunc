# bosh-pyfunc
python plugin functions for BigObject

## install to a BigObject docker container
The installation script will install python and some python library in your bigobject container.
```
docker run -td -p 9090:9090 -p 3306:3306 --name bo bigobject/bigobject:demo-1.61a
git clone https://github.com/bigobject-inc/bosh-pyfunc.git
sh pysetup2bo.sh bo
```

## run pandas Dataframe function : pandas, pandas_print
pandas_print : fine print, for testing, cannnot to be used to "receive" and "return to".

pandas : csv format, for "receive" and "return to" case

Usage : pandas | pandas_print  \<function name\> [arguments]

known issues:  int argument only now.

ex. Compute pairwise correlation of Customer.id, Product.id, qty columns (**corr**)
```
bosh>send "select Customer.id, Product.id, qty from sales" to "pandas_print corr"
          col1      col2      col3
col1  1.000000 -0.003237 -0.007502
col2 -0.003237  1.000000  0.005097
col3 -0.007502  0.005097  1.000000

```

ex. Trim values at input threshold(s). (**clip**)  min : 999, max : 5000
```
bosh>send "select Customer.id, Product.id from sales limit 5" to "pandas_print clip 999 5000"
   col1  col2
0  3226  2557
1  5000  2631
2  5000  1833
3  4138  1626
4  4138   999
```
ex. cumulative sum
```
bosh>send "select Customer.id, Product.id, qty from sales limit 10" to "pandas_print cumsum"
    col1   col2  col3
0   3226   2557     8
1   9917   5188    12
2  16608   7021    13
3  20746   8647    18
4  24884   9022    24
5  29022  12358    32
6  33160  13094    38
7  34452  17528    44
8  40048  21663    54
9  45644  25191    63
```

ex. use pandas to save the result to a table
```
bosh>create table cumsum (col1 INT32, col2 INT32 , col3 INT32)
bosh>send "select Customer.id, Product.id, qty from sales limit 100" to "pandas cumsum" return to cumsum
bosh>select * from cumsum limit 5
3226,2557,8
9917,5188,12
16608,7021,13
20746,8647,18
24884,9022,24
=============
total row : 5
```

Please refer http://pandas.pydata.org/pandas-docs/stable/api.html#api-dataframe-stats for more available functions (DataFrame).


## Kmean : kmean , getKmeanCent , getKmeanLabel

**kmean**: compute k mean clustering

**getKmeanCent**: receive k mean clustering centroids result 

**getKmeanLabel**: use the centroids to tag a label

ex. use BigObject sample data (100k rows)

1.use the first 99990 rows (Customer.id, Product.id) as data to compute k-mean (k=5)
```
bosh>send "select Customer.id , Product.id from sales limit 99990" to "kmean 5"
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
bosh>receive cent from "getKmeanCent"
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
bosh>send "select Customer.id , Product.id from sales limit 10 offset 99990" to "getKmeanLabel" return to label
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

## remote 
**remote**: perform statements to a remote BigObject server 

ex. show remote server (192.168.1.184:9090) data by the query "select * from sales limit 5"
```
bosh>receive _print from "remote 192.168.1.184:9090 'select * from sales limit 5'"
1,3226,2557,am/pm,2013-01-01 01:11:11,8,52.24
2,6691,2631,am/pm,2013-01-01 02:23:27,4,39.72
2,6691,1833,am/pm,2013-01-01 02:49:09,1,6.9
3,4138,1626,am/pm,2013-01-01 04:11:16,5,42.1
3,4138,375,am/pm,2013-01-01 04:15:26,6,67.26
```

The table name "_print" is used to print the result in screen. 

You can add an alias for a remote server.

**remote add_alias \<name\> \<BigObject ip:port\>** 

**remote del_alias \<name\>** 

**remote list_alias** 

```
bosh>receive _print from "remote add_alias rpi2 192.168.1.184:9090"
alias added : rpi2 = 192.168.1.184:9090

bosh>receive _print from "remote add_alias rpi 192.168.1.194:9090"
alias added : rpi = 192.168.1.194:9090

bosh>receive _print from "remote list_alias "
{'rpi': '192.168.1.194:9090', 'rpi2': '192.168.1.184:9090'}

bosh>receive _print from "remote del_alias rpi "
alias delete : rpi

bosh>receive _print from "remote list_alias "
{'rpi2': '192.168.1.184:9090'}
```

After an alias added, you can use this name to access the remote BigObject server. 

```
bosh>receive _print from "remote rpi2 'select * from sales last 3' "
5127,3284,3674,amazon,2013-12-29 00:00:42,3,20.76
5127,3284,2642,am/pm,2013-12-29 01:11:12,3,43.74
5127,3284,1091,7-11,2013-12-29 02:08:20,5,46.05
```

The table name also can be set a general table name to save the remote table to the local machine.
ex.
```
bosh>receive tmp_table from "remote rpi2 'select * from sales last 3' "
```

## distance
**distance**: compute the distance between the argument feature vector and feature vectors in a table and then show the rows which less than a preset threshold.

arguments : \<threshold\> , \<feature start col\> , \<feature end col\> , \<distance function\> , \<query data\>

Refer http://docs.scipy.org/doc/scipy/reference/spatial.distance.html#module-scipy.spatial.distance for the available distance functions. 

PS. only support the function with 2 arguments. ex. euclidean, cosine, ...

ex. the feature vector [9 51], compute euclidean distance and show the rows which distance is less than 30, the features placed in the 1~2 columns

```
bosh>send "select qty, total_price from sales limit 10" to "distance 30 1 2 euclidean 9 51"
8,52.24,1.59298462014
4,39.72,12.3384926146
5,42.1,9.7575611707
6,67.26,16.5344367911
8,41.68,9.37349454579
6,56.4,6.17737808459
10,50.1,1.34536240471

```
ex. the feature vector [9 51], compute cosine distance and show the rows which distance is less than 0.001, the features placed in the 6~7 columns

```
bosh>send "select * from sales limit 10" to "distance 0.001 6 7 cosine 9 51"
1,3226,2557,am/pm,2013-01-01 00:04:05,8,52.24,0.00025793815211
2,6691,1833,am/pm,2013-01-01 00:21:03,1,6.9,0.000472644069336
3,4138,3336,am/pm,2013-01-01 00:45:12,8,41.68,0.000111900443786
5,5596,4135,7-11,2013-01-01 01:08:42,10,50.1,0.000249515888964

```

## eval
**eval**: run a given python string

arguments : \<print source data\> \<eval_string\> 

\<print source data\> : True or False

Input data will be formed as an **string** array named "a". You can use index to access data; for example, a[0] is the first column of the input data.

ex. string concat : Customer.id + Date + '~~~~~~~' + total_price

```
bosh>send "select * from sales limit 5" to "eval True a[1] + a[4] + '~~~~~~~' + a[6]"
1,3226,2557,am/pm,2013-01-01 00:04:05,8,52.24,32262013-01-01 00:04:05~~~~~~~52.24
2,6691,2631,am/pm,2013-01-01 00:11:27,4,39.72,66912013-01-01 00:11:27~~~~~~~39.72
2,6691,1833,am/pm,2013-01-01 00:21:03,1,6.9,66912013-01-01 00:21:03~~~~~~~6.9
3,4138,1626,am/pm,2013-01-01 00:30:22,5,42.1,41382013-01-01 00:30:22~~~~~~~42.1
3,4138,375,am/pm,2013-01-01 00:35:44,6,67.26,41382013-01-01 00:35:44~~~~~~~67.26

``` 

ex. Arithmetic equation. (You need to convert the type)

( Product.id + total_price ) / qty

```
bosh>send "select Product.id, qty, total_price from sales limit 5" to "eval False (float(a[0]) + float(a[2]) / float(a[1]) ) "
2563.53
2640.93
1839.9
1634.42
386.21

```

The basic python and the functions of the "math" module can be used to in eval

ex. (square root of ( Product.id - qty ))  + 1
```
bosh>send "select Product.id, qty, total_price from sales limit 5" to "eval True math.sqrt( float(a[0]) - float(a[2])) + 1"
2557,8,52.24,51.0475773639
2631,4,39.72,51.9046166865
1833,1,6.9,43.7328913134
1626,5,42.1,40.7982411672
375,6,67.26,18.5425197734
```

Please refer https://docs.python.org/2/library/math.html for the "math" module


==================================================================================
## DNN demo

## install to a BigObject docker container
The installation script will install python and some python library in your bigobject container.
the script tfsetup2bo.sh only work on ubuntu now.
```
docker run -td -p 9090:9090 -p 3306:3306 --name bo bigobject/bigobject:demo-1.61a
git clone https://github.com/bigobject-inc/bosh-pyfunc.git
sh tfsetup2bo.sh bo
```

The demo use tensorflow DNNclassifier to demonstrate how to use BigObject as a data source to train a deep neural network and then predict by the trained model.

1. create a feature table. Since the sample data is not a feature vector, we use the above-mentioned 'eval' function to normalize the data to similar a feature vector dataset. 

The Product.id, Customer.id and total_price are normalized to a float point data. and the qty column is set as a label for training.
```
bosh>create table feature (f1 FLOAT, f2 FLOAT, f3 FLOAT , lab INT32)
bosh>send 'select Product.id, Customer.id, total_price, qty from sales limit 100' to 'eval False str(float(a[0])/1000)+ "," + str(float(a[1]) / 1000) + "," + str(float(a[2])/10) + "," +a[3]' return to feature

```
The processed feature table :
```
bosh>select * from feature limit 5
2.557,3.226,5.224,8
2.631,6.691,3.972,4
1.833,6.691,0.69,1
1.626,4.138,4.21,5
0.375,4.138,6.726,6
```

2. set the first 90 rows as a trainning set
```
bosh>send 'select * from feature limit 90' to 'DNNset'
feature inserted : 90 rows
```

3. Since the range of qty is 1~10, we set 10 classes in the DNNclassifer. the model is 3 layer DNN with 100, 200, 100 units and trained 2000 steps.
```
bosh>receive _print from 'DNNtrain 10'
```

4. use the trained model to predict the last 10 rows to test the trained model. and then check the real label (qty)
```
bosh>send 'select f1,f2,f3 from feature last 10' to 'DNNpredict 10'
Predictions: [2 8 2 5 2 2 2 8 8 2]
bosh>select lab from feature last 10
2
3
1
5
2
2
4
10
10
2
```


==================================================================================
These following functions does not include in installation script
==================================================================================

## Load images : loadImage, loadImagePath, imgstr2file (use base64 coding)

**loadImage**: load an image into a BigObject table

ex. load pic/tree.jpg into the "image" table. 

Note: since the VARSTRING max length is limited, you can only load small images into a column

```
bosh>CREATE TABLE images ('filename' STRING(63), 'content' VARSTRING(32766))
bosh>receive images from "loadImage pic/tree.jpg"
```

**loadImagePath**: load images in a diretory into a BigObject table

ex. load pic/* into the "image" table. 

```
bosh>receive images from "loadImagePath pic"
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
bosh>send "select content from images where filename='cat.jpg'" to "imgstr2file tmp.jpg"
```

##Tensorflow image recognition demo : tf_image

use pip to install tensorflow (Ubuntu/Linux 64-bit, CPU only, Python 2.7)
```
sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl 
```
Please refer https://www.tensorflow.org/versions/r0.9/get_started/os_setup.html#pip-installation for detail

**tf_image** : read the image stored in BigObject table and then run tensorflow image recognition

```
bosh>send "select content from images where filename='cat.jpg'" to "tf_image"
W tensorflow/core/framework/op_def_util.cc:332] Op BatchNormWithGlobalNormalization is deprecated. It will cease to work in GraphDef version 9. Use tf.nn.batch_normalization().
tiger cat (score = 0.54326)
tabby, tabby cat (score = 0.27918)
Egyptian cat (score = 0.10635)
lynx, catamount (score = 0.01014)
tiger, Panthera tigris (score = 0.00103)
```
