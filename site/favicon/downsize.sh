#!/usr/bin/env bash

# I use this recipe for all sizes
convert favicon-rune.png \
        -gamma 0.454545 \
        -resize 16x16 \
        -gamma 2.1 \
        -unsharp 0x1+1.9+0.01 \
        favicon-rune16x16.png
