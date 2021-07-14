# MariaDB + Phpmyadmin + Docker: Running Local Database | Hacker Noon

> I will get MariaDB and Phpmyadmin running in a docker container. I will reuse folder setup and all files from previous recipe - 02.

![image](chrome-extension://cjedbglnccaioiolemnfhjncicchinao/_next/image?url=https%3A%2F%2Fcdn.hackernoon.com%2Fdrafts%2Fo4ty3xxo.png&w=3840&q=75)

[

![Igor Fomin Hacker Noon profile picture](chrome-extension://cjedbglnccaioiolemnfhjncicchinao/_next/image?url=https%3A%2F%2Fcdn.hackernoon.com%2Fimages%2Favatars%2Fyq9sAk2IIggdbwex3O25LPzRAKq1.jpg&w=3840&q=75)





](chrome-extension://cjedbglnccaioiolemnfhjncicchinao/u/ifomin)

### [@ifomin](chrome-extension://cjedbglnccaioiolemnfhjncicchinao/u/ifomin)Igor Fomin

Full stack web developer, tech lead, project manager

I will get MariaDB and Phpmyadmin running in a docker container. I will reuse folder setup and all files from previous recipe - 02.

Source files can be found here:

[https://github.com/ikknd/docker-study](https://github.com/ikknd/docker-study?ref=hackernoon.com) in folder recipe-03

1\. Modify docker-compose.yml file
----------------------------------

Here I do several things:

*   create volume -
    
        mariadb-data
    
    . This is where all db data will be stored, even if container is restarted, data will be there.
*   environment variable
    
        MYSQL_ROOT_PASSWORD: qwerty
    
    \- sets root password for mariadb container.
*   environment variable
    
        PMA_ARBITRARY=1
    
    \- adds "server" input field to phpmyadmin login page (this way you can use this phpmyadmin with an external MySQL DB, and not just this local setup)
*   environment variable
    
        PMA_HOST=mariadb
    
    \- told phpmyadmin how to connect to mariadb
*   map ports for
    
        phpmyadmin - 8000:80
    
    \- this maps inner port 80 from inside the container, to port 8000 on my host machine
*   "
    
        depends_on
    
    " - prevents container to start before other container, on which it depends

2\. Go to /var/www/docker-study.loc/recipe-03/docker/ and execute:
------------------------------------------------------------------

I can go to:

    myapp.loc/

\- and still see phpinfo page

    myapp.loc:8000

\- see phpmyadmin, I can login using root/qwerty credentials

3\. What if I need database to be up and running with some initial DB inside, and not empty?
--------------------------------------------------------------------------------------------

This can be achieved by modifying

    mariadb

section with:

    command: "mysqld --init-file /data/application/init.sql"

and

    volumes:
        - ./init.sql:/data/application/init.sql

*       init.sql
    
    \- is an existing DB dump.
*   using volumes I copy this file to container's
    
        /data/application/init.sql
    
    location
*   using "
    
        mysqld --init-file
    
    " command - I tell mysql to start and import init.sql

4\. After I have DB running, how to export/import DB?
-----------------------------------------------------

To see list of containers and learn container id or name of mariadb container:

To import:

    docker exec -i docker_mariadb_1 mysql -uroot -pqwerty DB_NAME < your_local_db_dump.sql

To export:

    docker exec -i docker_mariadb_1 mysqldump -uroot -pqwerty DB_NAME > your_local_db_dump.sql

#### Tags

[Join Hacker Noon](https://app.hackernoon.com/signup)

Create your free account to unlock your custom reading experience.


[Source](https://hackernoon.com/mariadb-phpmyadmin-docker-running-local-database-ok9q36ji)