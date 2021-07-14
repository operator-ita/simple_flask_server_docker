# How to deploy ML models using Flask + Gunicorn + Nginx + Docker

> A template for configuring Flask + Gunicorn + Nginx + Docker with a detailed explanation, that should bring you a bit closer to working…

A template for configuring Flask + Gunicorn + Nginx + Docker with a detailed explanation, that should bring you a bit closer to working with microservices, building MVPs, and so on.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

[![Ivan Panshin](https://miro.medium.com/fit/c/56/56/2*ltx30ToFgtVDxYCAIoh0Pg.png)](https://ivan-panshin.medium.com/?source=post_page-----9b32055b3d0--------------------------------)

![](https://miro.medium.com/max/1400/1*No_PfHiKia5YW1Z2dpvFcw.jpeg)

[Bo-Yi Wu](https://www.flickr.com/photos/appleboy/) via flickr

It might be tricky to develop a good Machine Learning model, but even if one manages to do that, it’s still pretty much useless until you deploy it, so that other people can access it.

There are many ways to deploy a model, and I would like to talk about a pretty simple solution that works for a basic MVP — write an API for your model with Flask, use Gunicorn for the app server, Nginx — for the web server, and wrap it up in Docker, so that it’s easier to deploy on other machines (in particular, AWS and GCP).

The **complete code** can be found in the [GitHub repo](https://github.com/ivanpanshin/flask_gunicorn_nginx_docker).

I prefer to do experiments with new configurations on servers that I rent specifically for that, instead of using my personal or work hardware. That way, if you break something badly, it’s no big deal. I recommend using for those purposes [Linode](https://www.linode.com/), since I personally use them for my experiments and their hardware works just fine. But feel free to use any other service, as long as it’s on Ubuntu 18.04 LTS.

![](https://miro.medium.com/max/60/1*YZQx2LIo0PSP0Zu9IfIW4Q.jpeg?q=20)

![](https://miro.medium.com/max/1400/1*YZQx2LIo0PSP0Zu9IfIW4Q.jpeg)

[Manuel Geissinger](https://www.pexels.com/@artunchained) via pexels

If you decide to use Linode, then this section is for you. Navigate to Linodes and click “Add a Linode”. There are several things you should fill-in. In distributions I recommend to select Ubuntu 18.04 LTS image, the region — whatever is closer to you (I use Frankfurt, DE), Linode plan — Nanode (which costs only 5$ a month, but that’s enough for our purposes), root password — your password, and then click “Create”. After some time (about a couple of minutes) you can go to “Networking”, where you can find info for accessing your server via SSH.

![](https://miro.medium.com/max/60/1*R-yGZPjQAYU5YLD9xqXByA.png?q=20)

![](https://miro.medium.com/max/1400/1*R-yGZPjQAYU5YLD9xqXByA.png)

The next thing that I recommend to do is connect to the server and create non-root user with sudo privileges. The logic behind that action is fairly simple: you don’t want messing around the server with running everything as root, since it makes it easier to break stuff.

adduser usernameusermod -aG sudo username

Finally, switch to your new user:

su — username

The whole system config is split into 2 parts: app container (Flask + Gunicorn), and web container (Nginx web server). Let’s start with the first one.

Step 0 — install Docker and Docker Compose
------------------------------------------

Docker and docker-compose installations are extremely easy. They’re done in 4 and 2 lines respectively. So, I recommend following these pages:

> [Docker installation](https://docs.docker.com/engine/install/ubuntu/)
> 
> [Make Docker run without root](https://docs.docker.com/engine/install/linux-postinstall/)
> 
> [Docker Compose installation](https://docs.docker.com/compose/install/)

Step 1 — create Flask App and WSGI entry point
----------------------------------------------

Inside your main directory create _flask\_app_ directory and place the following files there.

This is the most basis Flask app without pretty much any functionality. We don’t load any models, don’t add any GET/POST requests and stuff. That will come later. For now, we just have an app that displays “hello world” on the main page.

An extremely easy part — we just create a separate file for Gunicorn to run on port 8000.

Step 2 — create a Docker image for Flask
----------------------------------------

Now we need to create a Dockerfile that will use these files and create an image that we will be able to run later.

For those who aren’t familiar with Docker, what this script does is the following: imports Python 3.6.7 images, sets up the work directory for all files, copies the requirements file that contains Flask, Gunicorn, and everything else you need for your Flask app to run. After that, all packages from requirements are installed via RUN command, and at the end we copy all the files from flask dir to _usr/scr/flask\_app_ inside the container.

Now you only need to place this file inside the same flask\_app directory and add _requirements.txt_. In this particular case it’s very basic:

_P.S._ Remember, that if you’re ever a bit lost regarding the directories and stuff, feel free to check complete project structure at the end of the article, or just visit the GitHub repo.

Step 3 — create Nginx files
---------------------------

There are several things you need to configure in order to run Nginx. But before we continue, create nginx directory inside your main directory (at the same level as _flask\_app_). After that, the first file that we need — is _nginx.conf_ that pretty much contains all fundamental Nginx info and variables. One example of quite basic Nginx set-up:

The second file — a configuration for our particular app. There are 2 popular ways to do that. The first one is to create a configuration file in _/etc/nginx/sites-available/your\_project_, and then create a symlink to _/etc/nginx/sites-enabled/your\_project_. The second one is to just create a _project.conf_ inside your main Nginx directory. We are going with the second approach.

There are several things you should note. First of all, take a look at _listen 80._ That command specifies what port your app will run at. As default port, we choose 80. Second of all, server name. You can either specify your IP address that you got from Linode, or you can just use your docker image name. And last but not least, _proxy pass_ command that should point your Nginx configuration to the flask project. Since the flask container is called flask\_app (we’ll get to that later), we just use the name of the container, and the port that we specified inside the Flask project.

Step 4 — create a Docker image for Nginx
----------------------------------------

This particular Docker image is fairly simple. As in the case of Flask, it also contains just 5 lines and does only 2 things: imports nginx image, copies our files, and replaces them with default ones.

Step 5 — combine Dockerfiles with docker-compose
------------------------------------------------

So, now we have 2 Dockerfiles: one for Flask + Gunicorn, and another for Nginx. It’s time to make them talk to each other and run the whole system. In order to do that we need docker-compose.

The only fundamental change we need to do is create docker-compose.yml file in the main directory.

There are several important things that we should address in order to understand how it works. First of all, _docker-compose_ is split into 2 parts (2 services): _flask\_app_ and _nginx_. As you can see by the following lines, the flask\_app container executes Gunicorn that runs the Flask app and translates it to 8000 port with 1 worker. And the second container just runs Nginx on 80 port. Plus, note the _depends\_on_ section. It tells the docker-compose to first launch _flask\_app_ container, and only then — the _nginx_ one, because one depends on the other.

Actually, there is one more thing that we should add, so that it’s even easier to run this docker set-up. And that is _run\_docker.sh_ file

It simply runs the docker-compose, but first makes sure that there are no old docker processes active at this time.

Step 6 — put it all together
----------------------------

All right, keep in mind, that the current project structure should look like this:

.  
├── flask\_app   
│   ├── app.py            
│   ├── wsgi.py  
│   └── Dockerfile  
├── nginx  
│   ├── nginx.conf            
│   ├── project.conf  
│   └── Dockerfile  
├── docker-compose.yml  
└── run\_docker.sh

After you made sure everything is in place, it’s time to run docker:

bash run\_docker.sh

And see the main page in the browser by navigating to the IP that you got from Linode:

![](https://miro.medium.com/max/1380/1*PvN0bh118RsrYVLf5_zlOA.png)

Step 7 — I didn’t get anything. What should I do?
-------------------------------------------------

Well, first of all, rent a server at Linode, install docker and docker-compose, then clone the git repository, and just run _bash run\_docker.sh._ After you made sure it runs successfully, start changing stuff. Play around with Flask, or Dockerfiles, or docker-compose, until you break something. After that, try to figure out what went wrong and fix it.

Moreover, if you’re not proficient with Flask, Gunicorn, Nginx, or Docker, I highly recommend these tutorials:

> [Docker for beginners](https://docker-curriculum.com/)
> 
> [Learn Flask](https://www.tutorialspoint.com/flask/index.htm)
> 
> [Flask + Gunicorn + Nginx](https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-gunicorn-and-nginx-on-ubuntu-18-04-ru)

Step 8 — all right, I get it. What’s next?
------------------------------------------

The next thing to add is POST requests support in Flask App. That way, you can send requests to your model, and get responses. So, we need 2 things. First — a model that will handle requests. Second — POST requests support itself.

For simplicity, the model in this case just returns the i-th element of list of colors. But it really doesn’t matter what kind of model is running, just create an instance of your model above all methods (_pretty much where you have server = Flask(\_\_name\_\_)_ ), and you’re good to go.

Now, if you navigate to your IP address, you will see a message “_The model is up and running. Send a POST request”,_ since just going to the IP qualifies as a GET request. However, let’s try to send a POST request with a json file that contains index for our model. Personally, I use Postman for that, but you can use whatever you like (i.e., Curl).

![](https://miro.medium.com/max/1400/1*zSTjW6ILhvFXJx7QYg7zBA.png)

Hey, it works! Now you can add additional routes with ability to receive GET/POST requests. The reason behind the idea is that you can load several models, and send requests to a particular model based on URLs.

Step 9 — how about taking it further?
-------------------------------------

There is actually one big thing left to do. In order to deploy this docker set-up big time, it might be a good idea to deploy it in cloud. For instance, I recommend taking a look at [deploying Docker to Amazon ECS](https://medium.com/underscoretec/deploy-your-own-custom-docker-image-on-amazon-ecs-b1584e62484). One of the main advantages of such approach is that AWS will take care of cluster management infrastructure.

We have taken a look at running a model inside a Flask App with Gunicorn + Nginx + Docker. Note that if you have any questions, feel free to contact me in the comments, GitHub issues, or my e-mail address: ivan.panshin@protonmail.com


[Source](https://towardsdatascience.com/how-to-deploy-ml-models-using-flask-gunicorn-nginx-docker-9b32055b3d0)