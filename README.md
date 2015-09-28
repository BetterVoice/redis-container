Redis Cluster Dockerfile
========================

```sudo docker run --name redis -e REDIS_DB_NUM=16 -e REDIS_REQUIRE_AUTH=true -e REDIS_MASTER_NAME=mymaster -e REDIS_MASTER_PASSWORD=Sup3rS3cr3tPassw0rd -e REDIS_MASTER_IP=192.168.1.100 -e SENTINEL_REQUIRED=true -e SENTINEL_HOST_IP=192.168.1.100 -p 6379:6379 -p 26379:26379 -d bettervoice/redis-container:3.0.3```

```sudo docker run --name redis -e REDIS_DB_NUM=16 -e REDIS_SLAVE=true -e REDIS_REQUIRE_AUTH=true -e REDIS_MASTER_NAME=mymaster -e REDIS_MASTER_PASSWORD=Sup3rS3cr3tPassw0rd -e REDIS_MASTER_IP=192.168.1.100 -e SENTINEL_REQUIRED=true -e SENTINEL_HOST_IP=192.168.1.100 -p 6379:6379 -p 26379:26379 -d bettervoice/redis-container:3.0.3```