
### Example

First time, initialize the database

```shell
docker run -ti --name magento-run \
    --link mysql-run:db \
    --publish 80:80 \
    --env "MYSQL_USER=root" --env "MYSQL_PASSWORD=password" --env "MYSQL_DATABASE=magento" \
    vasansr/ubuntu-magento-sample
```

Connect to already initialized database

```shell
docker run -ti --name magento-run \
    --link mysql-run:db \
    --publish 80:80 \
    vasansr/ubuntu-magento-sample
```
