#!/bin/bash
# Script to ease the creation of different languages versions of existing Instruqt labs.
# Author/s: Raul Mahiques
# License: GPLv3
#
#  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>.


# Make it look nicer if possible
if [ -t 1 ] && command -v tput >/dev/null && [ "$(tput colors)" -ge 8 ]; then
  export ERROR='\033[0;31m'
  export SUCCESS='\033[0;32m'
  export WARNING='\033[1;33m'
  export PROGRESS='\033[1m'
  export NC='\033[0m'
else
  export ERROR='' SUCESS='' WARNING='' NC='' PROGRESS=''
fi

# Verification and parameters handling

git rev-parse --is-inside-work-tree &>/dev/null || { echo -e "${ERROR}ERROR${NC}: This command must run on inside the git repository folder" ; exit 1 ; }
[[ "$1" == "" ]] && { echo -e "${ERROR}ERROR${NC}: arguments not provided\n${PROGRESS}Example${NC}:\n\t$0 <lab folder> <language, 2 letters only>" ; exit 1 ; }
[[ "$2" == "" ]] && { echo -e "${ERROR}ERROR${NC}: Language not provided\n${PROGRESS}Example${NC}:\n\t$0 <lab folder> <language, 2 letters only>" ; exit 1 ; }

lab=${1//\.\/}
lab=${lab//\/}
lang=${2,,}


[[ -d "$lab" ]] || { echo -e "${ERROR}ERROR${NC}: lab folder \"${lab}\" not found or not a directory\n${PROGRESS}Example${NC}:\n\t$0 <lab folder> <language, 2 letters only>" ; exit 1 ; }
[[ ${#lang} -gt 2 ]] && { echo -e "${ERROR}ERROR${NC}: Language be only 2 characters, \"${lang}\" has ${#lang}\n${PROGRESS}Example${NC}:\n\t$0 ${lab} es" ; exit 1 ; }
[[ -d "${lab}-${lang}" ]] && { echo -e "${ERROR}ERROR${NC}: There is already a lab with the same language \"${lab}-${lang}\""; exit 1 ; }



# Start the process
mkdir ${lab}-${lang}


cp -r ${lab}/[0-9]* ${lab}-${lang}/

cd  ${lab}
find -type d |while read line
do
  mkdir -p "../${lab}-${lang}/$line"
done

find assets -type f |while read line
do
  ln "../${lab}/$line" "../${lab}-${lang}/$line"
done
find track_scripts -type f |while read line
do
  ln "../${lab}/$line" "../${lab}-${lang}/$line"
done

echo -e "${PROGRESS}Change all the text inside the following files:${NC}"
find [0-9][0-9]* -type d | while read line
do
  mkdir -p "../${lab}-${lang}/$line"
done
find [0-9][0-9]* -iname '*.md' | while read line
do
  cp $line "../${lab}-${lang}/$line"
  echo -e "\tvim ${lab}-${lang}/$line"
done

find [0-9][0-9]* -type f -not -iname '*.md' | while read line
do
  ln "../${lab}/$line" "../${lab}-${lang}/$line"
done

cd - >/dev/null

cp ${lab}/config.yml ${lab}-${lang}/
sed "s/^\(slug\)\(.*\)/\1\2-${lang}/;" -i ${lab}-${lang}/config.yml
cp ${lab}/track.yml ${lab}-${lang}/
if grep '^maintenance:' ${lab}-${lang}/track.yml >/dev/null
then
  sed 's/^maintenance:.*/maintenance: true/' -i ${lab}-${lang}/track.yml
else
  echo 'maintenance: true' >> ${lab}-${lang}/track.yml
fi


echo -e "${PROGRESS}Change the variables inside config.yml if you wish to personalize it, otherwise just copy it as it is${NC}
\tvim  ${lab}-${lang}/config.yml
${PROGRESS}Change the description and other text for the lab found inside track.yml file${NC}:
\tvim ${lab}-${lang}/track.yml"

echo -e "${PROGRESS}Adding it to git, please push your changes when they are ready for review${NC}"
git add ${lab}-${lang}
git commit ${lab}-${lang} -m "Added language \"${lang}\" for lab \"${lab}\", first commit"

