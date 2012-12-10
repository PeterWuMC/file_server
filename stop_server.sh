for SELPID in $(ps aux|grep 'ruby server.rb -p 8087'|grep -v grep|awk '{print $2}'); do kill -9 $SELPID; done
