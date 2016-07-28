#!/bin/bash

if [ -z "$1" ]
  then
    echo "sh pysetup2bo.sh <bigobject container name>"
	exit
fi

echo '#!/bin/bash\nsudo apt-get update \nsudo apt-get install -y python python-dev python-pip \nsudo pip install --upgrade pip \nsudo pip install numpy \nsudo pip install scipy \nsudo pip install pandas' > ./pysetup.sh

bo_docker_name=$1
docker cp ./pysetup.sh $bo_docker_name:/
docker exec bo bash -c "chmod +x /pysetup.sh ; /pysetup.sh"
rm ./pysetup.sh
docker cp . bo:/usr/local/bin
