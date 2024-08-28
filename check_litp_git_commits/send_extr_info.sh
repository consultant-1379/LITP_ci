#! /bin/bash
home_dir=/home/xnorhea

if [ -f "$home_dir/run_extr_log.txt" ]; then
        rm $home_dir/run_extr_log.txt
fi

if ( source /home/xnorhea/projworkspace/extr_newcommit.sh ); then
mail -s "extr commits since start of sprint" -a /home/xnorhea/projworkspace/extr_changes.txt nora.hearty@ammeon.com < /home/xnorhea/projworkspace/prelim_extr_msg.txt
fi

