#!/bin/sh

git checkout master && git branch -r --merged | grep -v master | sed "s/origin\/\(\.*\)/\1/" | xargs -I {} git push origin --delete {}