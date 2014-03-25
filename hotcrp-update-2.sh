#!/bin/bash
# grab latest git source and link to hotcrp-latest.tar.gz
THISDATE="`date +%F`"
SRCDIR='/usr/local/src'
HCRPDIR="`find /mount/www/papers.usenix.org/hotcrp/ -maxdepth 1 -type d -name '*[0-9][0-9]'`"
IMGDIR="/usr/local/etc/hotcrp-usenix/custom-files/images/"

cd $SRCDIR
if [ `pwd` = $SRCDIR ]
then
  git clone  https://github.com/kohler/hotcrp.git hotcrp-git-$THISDATE
  tar -czvf hotcrp-git-`date +%F`.tar.gz hotcrp-git-$THISDATE/
  ln -sf hotcrp-git-$THISDATE.tar.gz hotcrp-latest.tar.gz
else
  echo "`pwd` is not $SRCDIR"
fi

for DIR in $HCRPDIR
do
  echo "========= $DIR =========="
  cd $DIR
  tar --strip=1 --owner www-data --group www-data -zxf $SRCDIR/hotcrp-latest.tar.gz
  cp -p $IMGDIR/* ./images/
  cp -p /usr/local/etc/hotcrp-usenix/custom-files/*.css .
  echo "========== $DIR DONE ========"
done
