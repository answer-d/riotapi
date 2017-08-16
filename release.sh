#/bin/bash

echo "はじまり"

uid_chk=`id | sed 's/uid=\([0-9]*\)(.*/\1/'`
if [ $uid_chk -ne 0 ]
then
  echo "rootで実行してね"
  exit 1
fi

echo "ゴミ掃除"
rm -rf /var/www/script
rm -rf /var/www/conf
rm -rf /var/www/data
rm -rf /var/www/html
rm -rf /var/www/cgi-bin

echo "りりーす"
cp -r ./script /var/www/script
cp -r ./conf /var/www/conf
cp -r ./html /var/www/html
cp -r ./cgi-bin /var/www/cgi-bin
mkdir /var/www/data
mkdir /var/www/log
chown apache. /var/www/html/overlay
chmod 666 /var/www/log

echo "しょきか"
#ruby /var/www/script/champion.rb | tee /var/www/data/champion.csv
#ruby /var/www/script/mastery.rb | tee /var/www/data/mastery.csv
cp -p ./data/champion.csv /var/www/data/champion.csv
cp -p ./data/mastery.csv /var/www/data/mastery.csv

echo "かくにん"
ls -laR /var/www/*

echo "おしまい"

