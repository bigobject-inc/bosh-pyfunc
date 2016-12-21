#!/bin/bash

if [ -z "$1" ]
  then
    echo "sh pysetup2bo.sh <bigobject container name>"
	exit
fi

echo -e '#!/bin/bash\nsudo apt-get update \nsudo apt-get install -y python python-numpy python-scipy python-pandas python-requests python-pkg-resources' > ./pysetup.sh

bo_docker_name=$1
docker cp ./pysetup.sh $bo_docker_name:/
docker exec $bo_docker_name bash -c "chmod +x /pysetup.sh ; /pysetup.sh"
rm ./pysetup.sh
docker cp ./addConcatCol $bo_docker_name:/usr/local/bin
docker cp ./getKmeanCent $bo_docker_name:/usr/local/bin
docker cp ./getKmeanLabel $bo_docker_name:/usr/local/bin
docker cp ./kmean $bo_docker_name:/usr/local/bin
docker cp ./pandas $bo_docker_name:/usr/local/bin
docker cp ./pandas_print $bo_docker_name:/usr/local/bin
docker cp ./remote $bo_docker_name:/usr/local/bin
docker cp ./distance $bo_docker_name:/usr/local/bin
docker cp ./eval $bo_docker_name:/usr/local/bin

