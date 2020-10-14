#!/bin/bash

folder=${1?Error: no dir given (ie zizi-data/results/lilly-full/fiveyears-ruby-full)}

# song="$((basename $folder) | head -n1 | cut -d "-" -f1)".m4a
name="$((basename $folder) | head -n1 | cut -d "-" -f1)"-"$((basename $folder) | head -n1 | cut -d "-" -f2)"
# name="$((basename $folder) | head -n1 | cut -d "-" -f1)"
newname="$((basename $folder) | head -n1 | cut -d "-" -f1)"-"$(basename $(dirname $folder) | head -n1 | cut -d "-" -f1)"
dirFull="$(dirname $(dirname $folder))"/"$(basename $(dirname $folder) | head -n1 | cut -d "-" -f1)"-full
dirClose="$(dirname $(dirname $folder))"/"$(basename $(dirname $folder) | head -n1 | cut -d "-" -f1)"-close

# if [ ! -d Output/web/$name ] && [[ $name != hosting* ]] && [[ $name != aintro* ]]
if [[ $name != hosting* ]] && [[ $name != aintro* ]]
then
	mkdir Output/web/$newname
	cp Output/playlist.m3u8 Output/web/$newname/playlist.m3u8


	ffmpeg -y  -i $dirFull/$name-full/%06d.jpg -i $dirClose/$name-close/%06d.jpg \
  -filter_complex '[0:v][1:v]hstack=inputs=2[v]' -map [v] \
  -an \
  -pix_fmt yuv420p  -c:v libx264 \
  -crf 23 \
  -maxrate 3500k -bufsize 7000k  \
  -sc_threshold 0 -g 25 -keyint_min 25 -hls_time 2 -hls_playlist_type vod \
  -hls_segment_filename Output/web/$newname/high_%05d.ts \
  Output/web/$newname/high.m3u8 \
	  -filter_complex '[0:v][1:v]hstack=inputs=2[db];[db]scale=-1:600[v]' -map [v] \
  -an \
  -pix_fmt yuv420p  -c:v libx264 \
  -crf 24 \
  -maxrate 1500k -bufsize 3000k  \
  -sc_threshold 0 -g 25 -keyint_min 25 -hls_time 2 -hls_playlist_type vod \
  -hls_segment_filename Output/web/$newname/mid_%05d.ts \
  Output/web/$newname/mid.m3u8 \
	  -filter_complex '[0:v][1:v]hstack=inputs=2[db];[db]scale=-1:350[v]' -map [v] \
  -an \
  -pix_fmt yuv420p  -c:v libx264 \
  -crf 28 \
  -maxrate 500k -bufsize 1000k  \
  -sc_threshold 0 -g 25 -keyint_min 25 -hls_time 2 -hls_playlist_type vod \
  -hls_segment_filename Output/web/$newname/low_%05d.ts \
  Output/web/$newname/low.m3u8
fi




________________ SHADOW SCRIPT

folder=${1?Error: no dir given (ie zizi-data/datasets/acts/full/test_shadow/*)}

name="$((basename $folder) | head -n1 | cut -d "-" -f1)"-shadow
closeName="$((basename $folder) | head -n1 | cut -d "-" -f1)"-"$((basename $folder) | head -n1 | cut -d "-" -f2)"-close

mkdir Output/web/$name
cp Output/playlist-shadow.m3u8 Output/web/$name/playlist.m3u8

ffmpeg -y \
  -i $folder/%06d.png \
  -i zizi-data/datasets/acts/close/test_shadow/$closeName/%06d.png \
-filter_complex '[0:v][1:v]hstack=inputs=2[db];[db]scale=-1:832[v]' -map [v] \
  -an \
  -pix_fmt yuv420p  -c:v libx264 \
  -crf 25 \
  -maxrate 350k -bufsize 700k  \
  -sc_threshold 0 -g 25 -keyint_min 25 -hls_time 2 -hls_playlist_type vod \
  -hls_segment_filename Output/web/$name/high_%05d.ts \
  Output/web/$name/high.m3u8 \
-filter_complex '[0:v][1:v]hstack=inputs=2[db];[db]scale=-1:350[v]' -map [v] \
  -an \
  -pix_fmt yuv420p  -c:v libx264 \
  -crf 28 \
  -maxrate 80k -bufsize 160k  \
  -sc_threshold 0 -g 25 -keyint_min 25 -hls_time 2 -hls_playlist_type vod \
  -hls_segment_filename Output/web/$name/low_%05d.ts \
  Output/web/$name/low.m3u8
