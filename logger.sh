log_file_path="/dev/null"
# Input 1 - log message
# Input 2 - log level
log(){
  dt=`date +"%d-%m-%Y %H:%M:%S.%3N"`
  log_level=${2:-INFO}
  logfile_suffix=`date +"%d-%m-%Y"`
  log_file_path=${log_file_path:-/dev/null}
  log_file_dated="${log_file_path}"
  if [ "${log_file_path}" != "/dev/null" ]; then  log_file_dated="${log_file_path}_${logfile_suffix}"  ; fi  
  printf "%s\t- %s\t- %s\n" "$dt" "$log_level" "$1" | tee -a ${log_file_dated}
}
