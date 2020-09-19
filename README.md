# NeoBlocks node
The NeoBlocks node is a modified version of [the official NEO node](https://github.com/neo-project/neo-node/) allowing event logs to be requested for each invocation transaction. The event logs contain details about a contract execution including notifications and contract storage manipulations. The NeoBlocks agent requires a NeoBlocks node.

## Get the sources
```
git clone https://github.com/NeoBlocks/neoblocks-node.git
cd neoblocks-node
git submodule update --init
```
## Build the Docker image
```
docker build -t neoblocks/neoblocks-node:2.12.1 .
docker tag neoblocks/neoblocks-node:2.12.1 neoblocks/neoblocks-node
```
## Create a Docker network bridge
```
docker network create -d bridge neoblocks
```
## Create a directory to store the chain
```
NEOBLOCKS=/usr/local/neoblocks
mkdir -p "${NEOBLOCKS}/Chain_00746E41"
mkdir -p "${NEOBLOCKS}/EventLogs_00746E41"
```
## Start the container
```
docker run -it -d \
 --network=neoblocks \
 --restart=unless-stopped \
 --log-opt max-size=16m \
 --name neoblocks-node \
 -p 10332-10334:10332-10334 \
 -v ${NEOBLOCKS}/Chain_00746E41:/app/Chain_00746E41 \
 -v ${NEOBLOCKS}/EventLogs_00746E41:/app/EventLogs_00746E41 \
 neoblocks/neoblocks-node
```
## Connect with the node and get the block height
```
curl -s 'http://127.0.0.1:10332/' \
 -H 'Content-Type: text/plain' \
 -H 'Accept: application/json' \
 --data-binary '{"jsonrpc":"2.0","id":1,"method":"getblockcount","params":[]}' | jq
```
## Example to get event logs from a transaction with execution
```
curl -s 'http://127.0.0.1:10332/' \
 -H 'Content-Type: text/plain' \
 -H 'Accept: application/json' \
 --data-binary '{"jsonrpc":"2.0","id":1,"method":"geteventlog","params":["0x69468ae7bd0df58a48155cb6a19f51b7671e5faed92e2523279e90ba574ad579"]}' | jq
```
