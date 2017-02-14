# get a slurm environment output such as lonsdale-n[001,002]
# & transmogrify it into something that mp_host_list compatible for abaqus

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
