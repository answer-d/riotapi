#/bin/bash

echo "はじまり"

uid_chk=`id | sed 's/uid=\([0-9]*\)(.*/\1/'`
if [ $uid_chk -ne 0 ]
then
  echo "rootで実行してね"
  exit 1
fi

echo "ゴミ掃除"
rm -rf /var/www/scripts
rm -rf /var/www/conf
rm -rf /var/www/data
rm -rf /var/www/html/img

echo "りりーす"
cp -r ./scripts /var/www/scripts
cp -r ./conf /var/www/conf
cp -r ./img /var/www/html/img
mkdir /var/www/data

echo "しょきか"
ruby /var/www/scripts/champion.rb | tee /var/www/data/champion.csv
ruby /var/www/scripts/mastery.rb | tee /var/www/data/mastery.csv
ruby /var/www/scripts/summoner_list.rb | tee /var/www/data/summoner_list.csv

echo "かくにん"
ls -laR /var/www/*

echo "おしまい"

