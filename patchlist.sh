#!/bin/bash

#SC=sources/linux_ivi_dts-ql
#pslist=(575d6439025dc1f2d55d009ed000c4616d5b6dcb)

CPATH=~/sung/patchlist

#경로 입력받기
echo "source경로를 입력하세요 ex>sources/linux_ivi_dts-ql"
read SC

#commit id 입력받기
echo "commit id를 입력하세요 ex>1111 2222 3333 4444"
read -a pslist

cd ~/work/dmz/cockpit2022plus/4-es2_ql-0809/$SC

for lt in "${pslist[@]}";
 do
   git log -p $lt > ~/sung/patchlist/$lt.txt
   glog=$(sed -n -e '1,/commit /p' ~/sung/patchlist/$lt.txt)
   echo "$glog" > ~/sung/patchlist/$lt.txt
   sed -n 's/+++ b\///p' ~/sung/patchlist/$lt.txt > ~/sung/patchlist/"$lt"_list.txt
   rl=$(cat ~/sung/patchlist/"$lt"_list.txt | grep -v '.dts$' | grep -v '.dtsi$')
   echo "$rl" > ~/sung/patchlist/"$lt"_rl.txt
   exlist=$(cat ~/sung/patchlist/"$lt"_rl.txt | grep -v '^$')
   if [ -n "$exlist" ] ; then
      echo "file existence"
      mv ~/sung/patchlist/"$lt"_rl.txt ~/sung/patchlist/"$lt"_O.txt
      cl=("$lt"_O.txt)
	   tlist=$(cat $CPATH/$cl)
	   echo "tlist = $tlist"
	   for lt in ${tlist[*]};
	    do
	      echo "ls = $lt"
	      cd ~/work/dmz/cockpit2022plus/4-es2_ql-0809/$SC
	      git log -p $lt > ~/sung/patchlist/compare/dmz_$cl 2>/dev/null
	      if [ $? -eq 0 ];then
	         cd ~/work/vgit/cockpit2022/3-icas3eu_gp-preEs-QLA-0817/$SC
				git log -p $lt > ~/sung/patchlist/compare/vgit_$cl
				cd ~/sung/patchlist/compare
				diff dmz_$cl vgit_$cl > compare_$cl
				if [ -s compare_$cl ] ; then
				   echo "$lt" >> ~/sung/patchlist/compare/change_$cl
				   cat compare_$cl >>  ~/sung/patchlist/compare/conflict_$cl
				fi
			else
				echo "dmz file first renaming $cl"
				git log -p > ~/sung/patchlist/compare/tmp.txt
				dmzrn=$(cat ~/sung/patchlist/compare/tmp.txt | sed 's/ //g' | grep 'rename from '$lt ~/sung/patchlist/compare/tmp.txt -1 | grep -w 'rename to' | cut -c 11-)
				if [ -n "$dmzrn" ] ; then
				   git log -p $dmzrn > ~/sung/patchlist/compare/dmz_$cl 2>/dev/null
					if [ $? -eq 0 ];then
						cd ~/work/vgit/cockpit2022/3-icas3eu_gp-preEs-QLA-0817/$SC
						git log -p $dmzrn > ~/sung/patchlist/compare/vgit_$cl
						cd ~/sung/patchlist/compare
						diff dmz_$cl vgit_$cl > compare_$cl
						if [ -s compare_$cl ] ; then
							echo "$dmzrn" >> ~/sung/patchlist/compare/change_$cl
							cat compare_$cl >>  ~/sung/patchlist/compare/conflict_$cl
						fi
					else
						echo "dmz file secound renaming $cl"
						dmzrrn=$(cat ~/sung/patchlist/compare/tmp.txt | sed 's/ //g' | grep 'rename from '$dmzrn ~/sung/patchlist/compare/tmp.txt -1 | grep -w 'rename to' | cut -c 11-)
						if [ -n "$dmzrrn" ] ; then
						   git log -p $dmzrrn > ~/sung/patchlist/compare/dmz_$cl 2>/dev/null
							if [ $? -eq 0 ];then
								cd ~/work/vgit/cockpit2022/3-icas3eu_gp-preEs-QLA-0817/$SC
								git log -p $dmzrrn > ~/sung/patchlist/compare/vgit_$cl
								cd ~/sung/patchlist/compare
								diff dmz_$cl vgit_$cl > compare_$cl
								if [ -s compare_$cl ] ; then
								   echo "$dmzrrn" >> ~/sung/patchlist/compare/change_$cl
									cat compare_$cl >>  ~/sung/patchlist/compare/conflict_$cl
								fi
						   else
							   echo "file unknown"
							   exit 1
						   fi
					   fi 	 
				   fi
			   fi 
			   rm -rf ~/sung/patchlist/compare/tmp.txt
		   fi
	   done
   else
      echo "file empty"
		mv ~/sung/patchlist/"$lt"_rl.txt ~/sung/patchlist/"$lt"_X.txt
	fi
done
