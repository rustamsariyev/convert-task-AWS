#!/bin/bash
#
# This script converts JPG format to PNG format.
#  First checking convert program installed or not in Debian distribution. If the program not installed, you will start to install the "ImageMagick" program. 
printf "Checking convert program in Debian distribution.\n"

dpkg -s imagemagick &> /dev/null

if [[ $? -ne 0 ]]
then
	echo "Not Installed"
	echo "Installing process started..."
        sudo apt-get update &> /dev/null && sudo apt-get install imagemagick -y &> /dev/null
        echo "ImageMagick program installed"
        sleep 1

        else
            echo    "Program have been installed"
fi

# Second we will try to find .jpg files and later redirect to while loop.
# Set values

read -p 'Enter the IMAGES path:' IMAGE_PATH
read -p 'Enter the converted file path:' CONVERT_PATH
read -p 'Enter the LOG file name:' ERROR_LOG
read -p 'Eneter S3 Bucket name:' S3_BUCKET

# Create a directory for newly converted images.
mkdir "${CONVERT_PATH}"converted-dir 2> "${ERROR_LOG}".log

# List image files.
LIST_IMAGES=$(ls $IMAGE_PATH*.jpg 2>"${ERROR_LOG}".log)

# Checking file existence with if statement.

if [[ "$?" -eq "2" ]]
then
	printf "There no image files exist. Please Enter correct PATH\n"
        exit 1
        set -e #If exit 1 stop script execution
fi

# Display image file list.
printf "Image files list:\n$LIST_IMAGES"
echo ""
printf "\nConverting Proccess starting\n"


# While loop converting images.
for image in $LIST_IMAGES
do
   convert ${image} "${CONVERT_PATH}"converted-dir/${image%.*}.png
done

# If while loop  successful covert display  messages.

if [[ "$?" -eq "0" ]]
then
        printf "Image files successfully converted\n"
fi 

# Display uploading process.
printf "Image files started uploading to the $S3_BUCKET bucket\n"

# Upload all converted file to specific s3 bucket.
aws s3 cp "${CONVERT_PATH}"converted-dir s3://"${S3_BUCKET}" --recursive --exclude "*" --include "*.png" &>/dev/null


# If all new files  successfully uploaded S3 Bucket display  messages.
if [[ "$?" -eq "0" ]]
then
        printf "Image files successfully uploaded $S3_BUCKET S3 bucket\n"
else
	printf "Unsuccessefull uploaded. Maybe you entered wrong S3 Bucket Name\n"
fi

# Script end!
