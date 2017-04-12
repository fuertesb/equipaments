
sudo mkdir -p /var/equipaments/bbdd/data
sudo mkdir -p /var/equipaments/bbdd/scripts
sudo chown -R docker /var/equipaments/
sudo chmod -R g+w /var/equipaments/

	
curl https://github.com/gencat/equipaments/blob/master/bbdd/scripts/equipaments.sql > /var/equipaments/bbdd/scripts/equipaments.sql
curl https://raw.githubusercontent.com/gencat/equipaments/master/bbdd/data/Equipaments.csv > /var/equipaments/bbdd/data/Equipaments.csv

# Download mysql 5.7 (canigo)
docker run -d --name mysql \
	-p 3306:3306 \
	-v /var/equipaments/bbdd/data:/tmp/data \
	-v /var/equipaments/bbdd/scripts:/docker-entrypoint-initdb.d \
	-e MYSQL_DATABASE=equipaments \
    -e MYSQL_USER=canigo \
    -e MYSQL_PASSWORD=canigo2015 \
    -e MYSQL_ROOT_PASSWORD=mysql \
	gencatcloud/mysql:5.7