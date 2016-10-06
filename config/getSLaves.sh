#!/bin/bash
$HADOOP_HOME/bin/hdfs dfsadmin -report|grep "Name:"
cat $HADOOP_HOME/etc/hadoop/slaves
