#!/bin/bash
echo "[ INFO ] Start image uploading script...."
img="$(cat moh.jpeg | base64 -w 0)"
log_disabling=1
function restarting {
	[[ -z "$log_disabling" ]] && echo "[ INFO ] Start restarting"
	redis-cli KEYS "user:*" | xargs redis-cli DEL > /dev/null
	[[ -z "$log_disabling" ]] && echo "[ INFO ] restarting complete"
}
function creating {
	> created.txt
	for ((i = 1; i < maxval+1; i++)); do
		echo "SET user:${i} ${img}" >> created.txt
	done
}
function upload {
	cat created.txt | redis-cli --pipe > /dev/null
}
restarting
echo "Time for upload 1_000 string row"
echo "--------------------------"
maxval=1000
creating
time upload
echo "--------------------------"
echo ""

echo "Time for upload 100_000 string row"
maxval=100000
creating
time upload
echo "--------------------------"
echo ""

echo "Time for upload 1_000_000 string row"
maxval=500000
creating
time upload
echo "--------------------------"
echo ""

echo "[ INFO ] Script finished"
