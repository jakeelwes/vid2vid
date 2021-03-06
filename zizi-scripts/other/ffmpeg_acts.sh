#!/bin/bash

folder=${1?Error: no dir given (ie zizi-data/results/lilly-full/fiveyears-ruby-full)}

song="$((basename $folder) | head -n1 | cut -d "-" -f1)".m4a
name="$((basename $folder) | head -n1 | cut -d "-" -f1)"-"$(basename $(dirname $folder))"


cp $folder/000003.png $folder/000001.png
cp $folder/000003.png $folder/000002.png

ffmpeg -y -an -i $folder/%06d.png -i Output/songs/$song -crf 5 -vcodec libx264 -pix_fmt yuv420p Output/full/$name.mp4
ffmpeg -y -an -i $folder/%06d.png -b 4000k -vcodec libx264 -pix_fmt yuv420p -strict -2 Output/web/$name.mp4



# shadow 2500k video 4000k
# could do '-crf 20' instead of '-b'
# Constant rate factor (CRF) is an encoding mode that adjusts the file data rate up or down to achieve a selected quality level rather than a specific data rate. 






# write open pose & desnsepose (if doesn't exist)

fc="$((basename $folder) | head -n1 | cut -d "-" -f3)"

ffmpeg -n -an -i zizi-data/datasets/acts/$fc/test_openpose_img/$(basename $folder)/%06d_rendered.jpg -i Output/songs/$song -crf 5 -vcodec libx264 -pix_fmt yuv420p Output/full/$name.mp4
ffmpeg -n -an -i zizi-data/datasets/acts/$fc/test_openpose_img/$(basename $folder)/%06d_rendered.jpg -b 4000k -vcodec libx264 -pix_fmt yuv420p -strict -2 Output/web/$name.mp4

ffmpeg -n -an -i zizi-data/datasets/acts/$fc/test_densepose/$(basename $folder)/%06d_IUV.png -i Output/songs/$song -crf 5 -vcodec libx264 -pix_fmt yuv420p Output/full/$name.mp4
ffmpeg -n -an -i zizi-data/datasets/acts/$fc/test_densepose/$(basename $folder)/%06d_IUV.png -b 4000k -vcodec libx264 -pix_fmt yuv420p -strict -2 Output/web/$name.mp4
