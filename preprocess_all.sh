#!/bin/sh

# Pre-process all Aroll video assets

logfile=log.$(date +%y%m%d%H%M)

# for f in $(find ../../assets/Aroll -name "*maincam*.mov"); do
#   ./preprocess_maincam.sh "$f" | tee -a $logfile
# done

# for f in $(find ../../assets/Aroll/ -name "*sidecam*.mov"); do
#   ./preprocess_sidecam.sh "$f" | tee -a $logfile
# done

for f in $(find ../../assets/Aroll -name "*cam*.mov"); do
  echo $f
  case "$f" in
    *maincam*) ./preprocess_maincam.sh "$f" | tee -a $logfile ;;
    *sidecam*) ./preprocess_sidecam.sh "$f" | tee -a $logfile ;;
  esac
done
