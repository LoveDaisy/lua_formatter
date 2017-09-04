#!/usr/bin/python
# -*- coding: utf-8 -*-


def uncomment_print(file_name):
    file_lines = []
    modified_lines = 0
    with open(file_name, "r") as f:
        for line in f:
            if line.strip().startswith("--") and line.split("--")[1].strip().startswith("print"):
                line = line.split("--")[1]
                modified_lines += 1
            file_lines.append(line)

    with open(file_name, "w") as f:
        f.writelines(file_lines)

    print("Modified {0} lines".format(modified_lines))

if __name__ == "__main__":
    from os import listdir
    import os, sys

    if len(sys.argv) != 2:
        print("USAGE: %s <path>".format(sys.argv[0]))
        sys.exit(-1)

    path = sys.argv[1]
    for f in listdir(path):
        full_name = os.path.join(path, f)
        if os.path.isfile(full_name) and f.endswith("lua"):
            uncomment_print(full_name)