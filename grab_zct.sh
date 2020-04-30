#!/bin/bash -e

FILE="tests-by-zcta.csv"
for commit in $(git rev-list master $FILE)
do
    datestamp=$(git log -n1 --pretty='format:%cd' --date=format:'%Y-%m-%d' $commit)
    echo $datestamp
    git show $commit:$FILE > /tmp/zcta-history/$datestamp.csv
done
