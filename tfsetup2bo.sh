#!/bin/bash

if [ -z "$1" ]
  then
    echo "sh tfsetup2bo.sh <bigobject container name>"
	exit
fi

echo '#!/bin/bash\nsudo apt-get update \nsudo apt-get install -y python python-numpy python-scipy python-pandas python-requests python-pkg-resources python-pip\nsudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl ' > ./pysetup.sh

bo_docker_name=$1
docker cp ./pysetup.sh $bo_docker_name:/
docker exec $bo_docker_name bash -c "chmod +x /pysetup.sh ; /pysetup.sh"
rm ./pysetup.sh

docker cp ./DNNset $bo_docker_name:/usr/local/bin
docker cp ./DNNtrain $bo_docker_name:/usr/local/bin
docker cp ./DNNpredict $bo_docker_name:/usr/local/bin
