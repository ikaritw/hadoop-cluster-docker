## remeber to set the dns-args of docker service
## ref https://stackoverflow.com/questions/24151129/docker-network-calls-fail-during-image-build-on-corporate-network/38103810#38103810
## check DNS: > nmcli device show | grep IP4.DNS
## add to service: > vim /lib/systemd/system/docker.service
## write to ExecStart
FROM ubuntu:16.04
MAINTAINER ikaritw <ikaritw@gmail.com>
WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update \
 && apt-get install -y openssh-server openjdk-8-jdk wget \
 && ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' \
 && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# install hadoop 2.7.3
RUN wget http://apache.stu.edu.tw/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz \
 && tar -xzvf hadoop-2.7.3.tar.gz \
 && mv hadoop-2.7.3 /usr/local/hadoop \
 && rm hadoop-2.7.3.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_HOME=/usr/local/hadoop \
    PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

RUN mkdir -p ~/hdfs/namenode \
 && mkdir -p ~/hdfs/datanode \
 && mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config \
 && mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh \
 && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
 && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml \
 && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml \
 && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml \
 && mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves \
 && mv /tmp/start-hadoop.sh ~/start-hadoop.sh \
 && mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh \
 && chmod +x ~/run-wordcount.sh \
 && chmod +x $HADOOP_HOME/sbin/start-dfs.sh \
 && chmod +x $HADOOP_HOME/sbin/start-yarn.sh

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

# More
RUN apt-get install -y vim vim-scripts ctags \
 && apt-get autoremove \
 && apt-get autoclean \
 && rm -rf /var/lib/apt/lists/* \
 && sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc

CMD [ "sh", "-c", "service ssh start; bash"]

