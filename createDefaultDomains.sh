#!/bin/sh

mkdir ./data/www/svn.osom/bob.osom &&
mkdir ./data/www/svn.osom/bob.osom/.devilbox &&
cp ./templates/vhost-gen/* ./data/www/svn.osom/bob.osom/.devilbox &&
cd ./data/www/svn.osom/bob.osom &&
ln -s ../trunk/bob/public htdocs &&
mkdir ./data/www/svn.osom/alice.osom &&
mkdir ./data/www/svn.osom/alice.osom/.devilbox &&
cp ./templates/vhost-gen/* ./data/www/svn.osom/alice.osom/.devilbox &&
cd ./data/www/svn.osom/alice.osom &&
ln -s ../trunk/alice/public htdocs
