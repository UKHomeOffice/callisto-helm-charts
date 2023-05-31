#!/usr/bin/env bash
set -e

root_path=${BASH_SOURCE[0]%/*}
. $root_path/topic-utils.sh

bootstrap_server=$1
keystore_password=$2
topics=/scripts/topics.txt
properties_file=kafka.properties

cp scripts/$properties_file tmp/
cd /tmp

#put password in $properties_file
if sed 's/#/'$keystore_password'/g' $properties_file > temp-$properties_file && mv temp-$properties_file $properties_file
then
  echo "Properties file updated"
else
  echo "Properties file failed to update"
  exit 1
fi

#for loop round topics
IFS=$'\n' topic_list=( $(grep --color=never "^[^#].*" $topics ) )

for line in "${topic_list[@]}"
do
   # skip empty lines
   if [ -z "$line" ]; then continue; fi
   topic=($line)
   create_topic_if_not_exists $topic
done

apply_permissions