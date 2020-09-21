#!/bin/bash

folder=${1?Error: no dir given (ie folder=lilly-full/fiveyears-ruby-full)}
#folder=lilly-full/fiveyears-ruby-full


name="$((basename $folder) | head -n1 | cut -d "-" -f1)"-"$(basename $(dirname $folder))"


cp $folder/000003.png $folder/000001.png
cp $folder/000003.png $folder/000002.png

ffmpeg -y -an -i zizi-data/results/$folder/%06d.jpg -crf 10 Output/full/$name.mp4
ffmpeg -y -an -i zizi-data/results/$folder/%06d.jpg -b 4000k -vcodec libx264 -pix_fmt yuv420p -strict -2 Output/web/$name.mp4



# shadow 2500k video 4000k
# could do '-crf 20' instead of '-b'
# Constant rate factor (CRF) is an encoding mode that adjusts the file data rate up or down to achieve a selected quality level rather than a specific data rate. 