#! /bin/bash
source ~/.bashrc
name1=( $(ldu list_repos ) )
name1=( $(ssh -p 29418 gerrit.ericsson.se gerrit ls-projects --match ERIClitp | egrep -v "\-testware|ERIClitpvirtualdevenv|ERIClitpjavaeeapi") )  
home_dir=/home/xnorhea/projworkspace
name1=( $(cat $home_dir/repo_list) )
cd $home_dir
#
# remove output file if exists
#
if [ -f "$home_dir/litp_iso_file.txt" ]; then
	rm $home_dir/litp_iso_file.txt
fi
#
#commit_line_length param to check for results from git query for repo
#
commit_line_length=0
#
#get the date from the LITP_iso repo
#
#temp_date=`date -dlast-friday +"%a %b %d %H:%M:%S"`
#mydate=`echo "$temp_date +0000"`
mydate="Fri Dec 05 11:54:59 +0000"
#
echo "Sorry, this output is not very pretty" >> $home_dir/litp_iso_file.txt
echo "This is the list of commits since the start of the sprint" >> $home_dir/litp_iso_file.txt
echo "Note that ERIClitpdocs is OMITTED" >> $home_dir/litp_iso_file.txt
echo "" >> $home_dir/litp_iso_file.txt 
echo "checking for changes since date " $mydate >> $home_dir/litp_iso_file.txt
echo "" >> $home_dir/litp_iso_file.txt
#
printf "\n%-20s | %-10s | %-30s | %-30s | %-10s | %-20s | %-30s\n" REPO_NAME \ COMMIT_ID \ COMMIT_USER \ COMMIT_TIME \ PUB_STATE \ PUB_VER \ COMMIT_COMMENT  >> $home_dir/litp_iso_file.txt
#
# now check each LITP repo for the list of checkins since the mydate
#
cd $home_dir
for repo in ${name1[@]}
do
                if [ -d "$repo/.git" ]; then
                        cd $repo
                        git clean -fdx
                        git fetch
                else
                        git clone ssh://xnorhea@gerritmirror.lmera.ericsson.se:29418/LITP/$repo
#                       git clone ssh://xnorhea@gerritmirror.lmera.ericsson.se:29418/LITP/$repo
                        cd $repo
                fi
		git fetch
		git reset --hard origin/master
#                echo "Repository is : " $repo >> $home_dir/litp_iso_file.txt
                IFS=";;"
                mycommit_info=( $(git log --after "$mydate" --pretty=format:"%h|%an|%cd|%s;;" | grep -v "LITP2_Jenkins_Release") )
                for commit_line in ${mycommit_info[@]}
                        do
                                commit_line_length=`echo $commit_line | wc -c`
                                if [ "$commit_line_length" -gt "1" ]; then
                                        mycommit_id=`echo $commit_line | awk '{split($0,a,"|"); print a[1]} ' | tr -d '\n'`
                                        mycommit_user=`echo $commit_line | tr -d ";;" | cut -d"|" -f2 | tr -d '\n'`
                                        mycommit_time=`echo $commit_line | cut -d"|" -f3 | tr -d '\n'`
                                        mycommit_comment=`echo $commit_line | cut -d"|" -f4 | tr -d '\n'`
                                        mycommit_Publish="not on Publish branch"
                                        my_publish_version="not published yet"
                                        mycommit_Publish=`git branch --r --contains $mycommit_id | grep Publish | cut -d"/" -f2`
                                        git checkout $mycommit_id pom.xml
                                        my_publish_version=`grep "version" pom.xml | grep "SNAPSHOT" | cut -d">" -f2 | cut -d"<" -f1`
#                                        echo $repo "|" $mycommit_id "|" $mycommit_user "|" $mycommit_time "|" $mycommit_comment "|" $mycommit_Publish "|" $my_publish_version >> $home_dir/litp_iso_file.txt
					printf "%-20s | %-10s | %-30s | %-30s | %-10s | %-20s | %-30s\n" $repo $mycommit_id $mycommit_user $mycommit_time $mycommit_Publish $my_publish_version $mycommit_comment >> $home_
dir/litp_iso_file.txt
                                fi
                        done

        cd $home_dir
        unset IFS
done
if  [ ! -f "$home_dir/litp_iso_file.txt" ]; then
  	echo "No changes found since last iso build: $mydate" >> $home_dir/litp_iso_file.txt
fi

