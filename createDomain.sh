#!/bin/sh

mkdir ./data/www/svn.osom/$1 &&
mkdir ./data/www/svn.osom/$1/.devilbox &&
cp ./templates/vhost-gen/* ./data/www/svn.osom/$1/.devilbox &&
cd ./data/www/svn.osom/$1 &&
ln -s ../trunk/alice/public htdocs
