SCRIPT_FOLDER=$(dirname "$0")
for file in ${SCRIPT_FOLDER}/*/*.sh
do {
  echo "Sourcing ${file}"
  . $file
}
done
