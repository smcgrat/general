# Running Abaqus in parallel on the clusters: http://www.tchpc.tcd.ie/node/1261
# In order to run Abaqus in parallel it needs to know the compute nodes it will be running
# It does not seem to be able to integrate with the slurm queueing system natively. 
# This necessitates having a way to inform Abaqus of the compute nodes that slurm has made available to it.
# The Abaqus `mp_host_list` environmental variable allows that
# for further details please see the Abaqus documentation; https://www.simulia.com/support/v67/books/sgb67EF/default.htm?startat=ch04s01.html 
# This code snippet translates the Slurm node list variable into a format that Abaqus can hopefully use 
# by taking the slurm environment output such as lonsdale-n[001,002]
# & transmogrifying it into something that is `mp_host_list` compatible for abaqus
# Please note that this translation is naive, not very well designed and has barely been tested.
# Ensure to include the snippet in your slurm batch submission script before the part of the script that runs Abaqus
# Dependency: Python Hostlist - https://pypi.python.org/pypi/python-hostlist

list="$SLURM_JOB_NODELIST"
corecount=8 # specify the number of cores to be used by abaqus on each node

declare -a array_for_mp_host_list

multicheck=$(echo $list | grep '\[') # greping for [ char for hostlist type entries to ensure this is a multinode job

if [ -n "$multicheck" ]; then # [ present in array entry, ergo this is a multi node entry like parsons-n[111,121,123]
        allnodes=($(/home/support/apps/apps/local/64/python-hostlist-1.6/hostlist -e $list) )
        for node in "${allnodes[@]}"; do
                abaqus_compatible_node="['$node',$corecount]"
                array_for_mp_host_list=("${array_for_mp_host_list[@]}" "$abaqus_compatible_node",)
        done
else # not a multinode hostlist, so just set it to the slurm list and core count
        mp_host_list=[[$SLURM_JOB_NODELIST,$corecount]]
        exit 0
fi

# transform the array to a string and remove the spaces and trailing ,
string=$( printf "%s" "${array_for_mp_host_list[@]}" | sed 's/.\{1\}$//' )
export mp_host_list=[$string]
echo "mp_host_list=${mp_host_list}" > abaqus_v6.env # output the host list the expected environment file

echo "This is the mp_host_list: $mp_host_list"
