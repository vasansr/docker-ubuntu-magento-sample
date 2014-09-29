#docker-ubuntu-magento-sample
Dedicated container for magento with sample data.

### About

This container is based on ubuntu:trusty, adds apache and magento using
apt-get, installs magento and adds the sample data.

### Building the image

Sample data is not part of this source, you will need to download it
yourself before you attempt to build an image using this. It expects the
following to be in the root directory of the image build context:

* magento.tar.gz
* magento-sample-data.tar.gz

### Run-time Dependencies

At runtime, this container expects a linked container with a (possibley empty) mysql
running. One such mysql container can be launched using vasansr/ubuntu-mysql.

When run for the first time, the container will attempt to initialize the database
with the sample data.

### Running Example

First time, initialize the database with sample data

```shell
docker run -ti --name magento-run \
    --link mysql-run:db \
    --publish 80:80 \
    --env "MYSQL_USER=root" --env "MYSQL_PASSWORD=password" --env "MYSQL_DATABASE=magento" \
    vasansr/ubuntu-magento-sample
```

Connect to already initialized database with sample data

```shell
docker run -ti --name magento-run \
    --link mysql-run:db \
    --publish 80:80 \
    vasansr/ubuntu-magento-sample
```

Explanation:

* --name : Give the container a convenient name
* --link : Link to a running mysql database container
  * mysql-run : this is the name you gave the mysql container when starting it up
  * db : required, this container expects the mysql container to be aliased as 'db'
* --env : User and password are used to connect, DATABASE is created and initialized with sample data.
* --publish : expose port 80 to the world via the docker proxy
