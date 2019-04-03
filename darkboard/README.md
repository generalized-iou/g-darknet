# Setup

You can run this project with docker and docker compose or on a bare linux installation

## Docker Compose Setup

You will need to install:

- [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)

```
# uninstall any old versions
sudo apt-get remove docker docker-engine docker.io containerd runc
# install dependencies
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
# install key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# verify key
# must match: 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
sudo apt-key fingerprint 0EBFCD88
# add repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
# install Docker community edition
sudo apt-get install docker-ce
```

- [NVIDIA Docker](https://github.com/NVIDIA/nvidia-docker#quickstart)

```
# If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
sudo apt-get purge -y nvidia-docker

# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$(. /etc/os-release;echo $ID$VERSION_ID)/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update

# Install nvidia-docker2 and reload the Docker daemon configuration
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd
```

- [Docker Compose](https://docs.docker.com/compose/install/#install-compose)

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

- Permissions

Add yourself to the docker group

```
sudo usermod -a -G docker $USER
```

## Run on Docker

You may need to start or restart docker if it is not already running:

```
sudo service docker restart
```

Make sure you export your user info so docker can build an image with the right permissions:

```
export UID=$(id -u)
export UNAME=$(whoami)
export GID=$(id -g)
```


If you use a fast local disk for loading images, mount it in `docker-compose.yaml` in the nvidia container config

format is `[host path]:[container path]`, e.g.:
```
    - /scr/ntsoi/darknet/datasets:/cvgl2/u/ntsoi/src/nn/darknet/datasets/
```

Then:

```
cd darkboard # if not already in this directory
cd docker
docker-compose up
```

Open http://HOSTNAME:4200/ and explore Darkboard

### Web Only

To run only the webserver (no validation calculations), for example, if you want to run validation on another host:

```
cd darkboard # if not already in this directory
cd docker
docker-compose up web
```

### Validation Only

To run only the valiation task (no webserver), to update the mAP chart values. Note that this requires nvidia-docker:

```
cd darkboard # if not already in this directory
cd docker
docker-compose up nvidia
```

## Linux Setup

Test on Ubuntu 16.04

 - Install `rbenv` and `ruby-build`

 - Install ruby with ruby build via: `rbenv install`

 - Install bundler `gem install bundler -v '1.17.3'`

 - Bundle `bundle`

 - update node

    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs

 - install yarn

    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt install yarn

 - install `ng`

    yarn global add @angular/cli

## Run on Linux

Migrate up the database:

    bundle exec rails db:migrate RAILS_ENV=development

In this directory, serve the API with:

    bundle exec rails s

In another shell, start the angular server:

    cd client
    yarn install
    yarn start

Now open http://localhost:4200 in your browser.

## Background data processing

To pre-process charts for display you'll need to run `rake charts:update`

I have found that running a tmux instance with this watch command is the most effective way to keep charts up to date:

    watch -c "flock -n /tmp/update_charts.lockfile /bin/zsh -l -c 'export HOME=$HOME; cd $HOME/src/nn/darknet/darkboard; source $HOME/.zshrc; bundle exec rake charts:update > $HOME/src/nn/darknet/batch/out/update_charts.out'"

I run darkboard from local disk and rsync log files from the network, if you want to avoid this rsync or set the source and destination, use the environment variables in the rake task:

```
    sync_from = ENV['SYNC_FROM'] || '/cvgl2/u/ntsoi/src/nn/darknet/backup'
    sync_to = ENV['SYNC_TO'] || '/scr/ntsoi/darknet/'
    unless ENV['NOSYNC']
```
