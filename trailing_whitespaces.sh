#!/bin/bash

find . -print0 |xargs -0 perl -pi -e 's/ +$//'
