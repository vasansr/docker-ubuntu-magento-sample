#!/bin/bash

wget --continue http://www.magentocommerce.com/downloads/assets/1.9.0.0/magento-sample-data-1.9.0.0.tar.gz
wget --continue http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz

tar zxf magento-1.9.0.1.tar.gz
tar zxf magento-sample-data-1.9.0.0.tar.gz

cd magento/skin
cp -R ../../magento-sample-data-1.9.0.0/skin/* .
cd ../media
cp -R ../../magento-sample-data-1.9.0.0/media/* .


