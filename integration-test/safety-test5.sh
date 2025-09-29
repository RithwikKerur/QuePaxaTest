leaderTimeout=$1
serverMode=$2
leaderMode=$3
pipeline=$4
batchTime=$5
batchSize=$6
arrivalRate=$7
closeLoopWindow=$8
requestPropagationTime=$9
asynchronousSimulationTime=${10}

# create a new local configuration
rm -r configuration/local
mkdir -p configuration/local
python3 configuration/config-generate.py 5 5 128.105.146.0 128.105.145.238 128.110.216.211 128.110.216.210 198.22.255.17 128.105.146.0 128.105.145.238 128.110.216.211 128.110.216.210 198.22.255.17 > configuration/local/configuration.yml

raxos_path="replica/bin/replica"
ctl_path="client/bin/client"
output_path="logs/${leaderTimeout}/${serverMode}/${leaderMode}/${pipeline}/${batchTime}/${batchSize}/${arrivalRate}/${closeLoopWindow}/${requestPropagationTime}/${asynchronousSimulationTime}/"

rm -r "${output_path}" ; mkdir -p "${output_path}"

echo "Removed old log files"

pkill replica; 
pkill client; 

echo "Killed previously running instances"

nohup ./${raxos_path} --name 5 --isAsync --asyncTimeOut ${asynchronousSimulationTime} --debugOn --debugLevel 200 --batchSize "${batchSize}" --batchTime  "${batchTime}" --leaderTimeout "${leaderTimeout}" --pipelineLength "${pipeline}" --leaderMode "${leaderMode}" --serverMode "${serverMode}" --requestPropagationTime "${requestPropagationTime}" --logFilePath "${output_path}" >${output_path}5.log &

echo "Started 5 servers"

sleep 3

sleep 12

echo "Starting client[s]"

nohup ./${ctl_path} --name 25 --debugOn --debugLevel 100 --requestType request --arrivalRate "${arrivalRate}"  --batchSize "${batchSize}" --batchTime "${batchTime}" --window "${closeLoopWindow}" --logFilePath "${output_path}"  >${output_path}25.log &

sleep 100

echo "Completed Client[s]"

echo "Sent status to print log and print steps per slot"

sleep 40

pkill replica; 
pkill client;

rm -r configuration/local


echo "Killed previously running instances"

echo "Finish test"
