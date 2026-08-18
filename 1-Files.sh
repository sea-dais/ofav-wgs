#Download Illumina Basespace Command line interface
wget "https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs" -O $HOME/bin/bs

#make it executable
chmod u+x $HOME/bin/bs
#Authenticate
bs auth

idev -t 0:30:00
cd /scratch/08717/dmflores/ofav-wgs/files
bs list projects
bs -v download project --name JA26126 --extension fastq.gz 

cd $SCRATCH/ofav-wgs
find files -mindepth 2 -type f -name "*.fastq.gz" -exec mv {} files/ \;
find files -mindepth 1 -type d -empty -delete

ls | wc 
#72 files