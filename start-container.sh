#!/bin/bash

HADOOP_IMAGE_NAME=kiwenlau/hadoop:1.0
NETWORK_HADOOP_NAME=$NETWORK_HADOOP_NAME
NETWORK_HADOOP=$(docker network ls|grep "$NETWORK_HADOOP_NAME")
if [ "$NETWORK_HADOOP" == "" ]; then
	echo -e "Create docker network with Name:$NETWORK_HADOOP_NAME"
	docker network create $NETWORK_HADOOP_NAME
else
	echo -e "Docker network Name:$NETWORK_HADOOP_NAME have exists."
fi

# the default node number is 3
N=${1:-3}

# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd --net=$NETWORK_HADOOP_NAME -p 50070:50070 -p 8088:8088 --name hadoop-master --hostname hadoop-master $HADOOP_IMAGE_NAME &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=$NETWORK_HADOOP_NAME \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                $HADOOP_IMAGE_NAME &> /dev/null
	i=$(( $i + 1 ))
done 


# the default client number is 2
M=${1:-2}

# start hadoop client container
i=1
while [ $i -lt $M ]
do
	#sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-client$i container..."
	sudo docker run -itd --net=$NETWORK_HADOOP_NAME --name hadoop-client$i --hostname hadoop-client$i -p 220$i:22 $HADOOP_IMAGE_NAME &> /dev/null
	sudo docker exec hadoop-client$i USER_ACCOUNT=user0$i && useradd --create-home --shell /bin/bash $USER_ACCOUNT && echo -e "$USER_ACCOUNT\n$USER_ACCOUNT" | passwd $USER_ACCOUNT
	i=$(( $i + 1 ))
done 


# get into hadoop master container
sudo docker exec -it hadoop-master bash
