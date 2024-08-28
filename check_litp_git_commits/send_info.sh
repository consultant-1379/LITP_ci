#! /bin/bash
home_dir=/home/xnorhea

if [ -f "$home_dir/run_log.txt" ]; then
        rm $home_dir/run_log.txt
fi

if ( source /home/xnorhea/projworkspace/pretty_newcommit.sh ); then
mail -s "commits since start of sprint" -a /home/xnorhea/projworkspace/litp_iso_file.txt nora.hearty@ammeon.com < /home/xnorhea/projworkspace/prelim_msg.txt
fi

