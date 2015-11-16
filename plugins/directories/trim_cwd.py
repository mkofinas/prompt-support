#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Trim the current working directory by showing only the last 3 folders leading
# up to it, as well as whether we are in a home directory or not; using the '~'
# and '/' symbols, respectively.

import os
import sys

def trim_cwd(num_trailing_directories=3):
    current_directory = os.getcwd()
    home_directory = os.path.expanduser('~')
    current_directory = current_directory.replace(home_directory, '~', 1)
    directories = current_directory.split('/')
    if len(directories) <= (num_trailing_directories + 1):
        print(current_directory)
    else:
        added_ellipses = '/...'
        # added_ellipses = '/' + str(len(directories) - num_trailing_directories)
        path_trail = ''
        for ii in range(-num_trailing_directories, 0):
            path_trail += '/' + str(directories[ii])
        trimmed_directory = directories[0] + added_ellipses + path_trail
        print(trimmed_directory)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        trim_cwd(int(sys.argv[1]))
    else:
        trim_cwd()
