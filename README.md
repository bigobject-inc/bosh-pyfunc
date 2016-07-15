# bosh-pyfunc
python functions for BigObject python bosh

requirement: bosh 0.2.18+ , numpy, scipy
```
sudo pip install --upgrade pip
sudo pip install numpy
sudo pip install scipy
sudo pip install bosh
chmod +x *.py
```

## Kmean : kmean.py , getKmeanCent.py , getKmeanLabel.py

kmean.py: compute k mean clustering

getKmeanCent.py: receive k mean clustering centroids result 

getKmeanLabel.py: use the centroids to tag a label

ex. use BigObject sample data (100k rows)

1.use the first 99990 rows (Customer.id, Product.id) as data to compute k-mean (k=5)
```
bosh>send "select Customer.id , Product.id from sales limit 99990" to "./kmean.py 5"
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
bosh>receive cent from "./getKmeanCent.py"
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
bosh>send "select Customer.id , Product.id from sales limit 10 offset 99990" to "./getKmeanLabel.py" return to label
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

## Load images : loadImagePath.py , imgstr2file.py (use base64 coding)

loadImagePath.py : load images in a diretory into a BigObject table

ex. load ./pic/* into the image_table. 

Note: since the VARSTRING max length is limited, you can only load small images into a column
```
bosh>CREATE TABLE images_table ('filename' STRING(63), 'content' VARSTRING(32766))
bosh>receive images_table from "./loadImagePath.py ./pic"
bosh>select filename from images_table
Screenshot-1.png
Screenshot.png
Screenshot-2.png
```

imgstr2file.py : write a image string in BigObject table into a file

ex. write the image content (Screenshot-2.png) to the file "test.png"
```
bosh>send "select content from images_table where filename='Screenshot-2.png' " to "./imgstr2file.py test.png"
```
