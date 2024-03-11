#!/usr/bin/env bash
 
git fetch upstream
 
git merge upstream/master

 
git push origin HEAD:main

