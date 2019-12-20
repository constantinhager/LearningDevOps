# Containerizing your Application with Docker

- [Containerizing your Application with Docker](#containerizing-your-application-with-docker)
  - [Installing Docker](#installing-docker)
    - [An overview of Dockers elements](#an-overview-of-dockers-elements)
  - [Creating a Docker file](#creating-a-docker-file)
    - [Writing a Dockerfile](#writing-a-dockerfile)
    - [Dockerfile instructions overview](#dockerfile-instructions-overview)
  - [Building and running a container on a local machine](#building-and-running-a-container-on-a-local-machine)
    - [Building a Docker image](#building-a-docker-image)
    - [Creating a new container of an image](#creating-a-new-container-of-an-image)
    - [Testing a container locally](#testing-a-container-locally)
  - [Pushing an image to Docker Hub](#pushing-an-image-to-docker-hub)
  - [Deploying a container in ACI with a CI / CD pipeline](#deploying-a-container-in-aci-with-a-ci--cd-pipeline)
    - [The Terraform code for ACI](#the-terraform-code-for-aci)

Docker is a Container engine. It isolates an application from its host system so that the application
becomes portable and code tested on a developer's workstation can be deployed to production with fewer concerns
about execution runtime dependencies.

A container is not a VM. The Container only contains the libraries, binaries and code dependencies needed.

The main difference between a VM and a container is that the VM runs on a Hypervisor and is OS independent,
while a Container depends on the OS on which he is running and uses the resources (CPU, RAM and network).

## Installing Docker

Docker is a cross platform tool and is also natively present in Azure and AWS.

For running Docker we need the following elements:

- The Docker client: This allows you to perform various operations on the command line.
- The Docker daemon: This is Dockers engine
- Docker Hub: This is a public registry of Docker images.

To install Docker you first need to create a Docker Hub account.

If you want to install Docker on Windows you need the following prerequisites:

- Windows 10 64 bit with at least 4 GB of RAM
- Virtualization has to be enabled for the system. If you use Docker for Windows you need Hyper-V installed.

You can download the Docker for Windows from the following URL [Download Docker](https://hub.docker.com/editions/community/docker-ce-desktop-windows)

In the wizard do not check "Use Windows containers instead of Linux containers".

After the installation a window will pop up to ask you for your Docker Hub credentials. Type them in.

To install Docker on other platforms use this link [Download Docker for other platforms](https://docs.docker.com/install/)

To check if Docker is installed correctly you run the following command in a command prompt:

```bash
docker --help
```

### An overview of Dockers elements

The docker image is the basic element of Docker and consists of a text document called a dockerfile.
This file explains how the Docker container should look like. You define a base image and the binaries
you want to containerize.

A container is an instance that is executed from a Docker image. You can easily scale out your application
by building multiple instances of the same docker image.

A volume is storage space that is physically located on the host OS (outside of the container) and it
can be shared across multiple containers if required. This is a persistent storage. Everything that is needed
for the application to work should be stored here (files or databases).

## Creating a Docker file

This file contains step-by-step instructions for building a Docker image.

### Writing a Dockerfile

The first statement that you will find in a Docker file is the FROM statement. This tells the Docker image
which base image is needed. Every Docker images is built from another Docker image. This base image can be saved
either in Docker Hub or in another registry.
If you want the latest version from a Docker you use the word latest (FROM httpd:latest).

The next statement is the COPY statement. Docker copies local files to a folder inside of the image.

### Dockerfile instructions overview

- FROM: This instruction is uses to define the base image for our image

- COPY and ADD: These are used to copy one or more local files into an image. The ADD instruction supports
  an extra two functionalities, to refer to a URL and to extract compressed files

- RUN and CMD: This instruction takes a command as a parameter that will be executed during the construction
  of the image. The RUN instruction creates a layer so that it can be cached and versioned. The CMD instruction
  defines a default command to be executed during the call to run the image. The CMD instruction can be overwritten at
  runtime with an extra parameter provided.

For example if you want to run apt-get update inside of the container:

```docker
RUN apt-get udpate
```

If you use CMD inside of a container:

```docker
CMD "echo docker"
```

- ENV: use this if you want to create environment variables. These environment variables will persist throughout the life
  of the container:

  ```docker
  ENV envtest=test
  ```

- WORKDIR: This defines the execution directory of the container:

  ```docker
  WORKDIR /usr/local/apache2
  ```

There are also other examples of Dockerfile instructions like EXPOSE, ENTRYPOINT and VOLUME which can be found in
the official documentation [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)

## Building and running a container on a local machine

The execution of Docker is performed by these different operations:

- Build the Docker image from a Dockerfile
- Run a new container from that image that was created earlier
- Test the container

### Building a Docker image

To build a Docker image use the following command line:

```cmd
docker build -t demobook:v1 .
```

The -t argument tells us the name of the container. In the above example the image is named demobook and the tag is v1.
The . is telling the docker command to search dockerfiles in the current directory.

If we want to check if the image is created successfully use the following command:

```cmd
docker images
```

### Creating a new container of an image

To create a new container from our image we use the docker run command.

```cmd
docker run -d --name demoapp -p 8080:80 demobook:v1
```

Explore the arguments of docker run:

d: run the container in the background.
name: the name of the container
p: the desired port to reach the application. 8080 is the port where our application is available outside of the container.
   80 is the port inside of the container. So port 80 will be exposed outside via 8080.

The last parameter is the name of the image and the tag.

The container started and returns the ID of the container. To display the list of all containers running on the local machine
use the following command:

```cmd
docker ps
```

### Testing a container locally

To test the application we open a web browser and execute http://localhost:8080. You should see the webpage that was created earlier.

## Pushing an image to Docker Hub

Why do we want to build a docker image? We want to create a small footprint and want to share this container with other people.
To do that we only need them to install Docker and run the container. To download that container to another client you need to store
that image somewhere. That is called a docker image registry.

If you want to create a public image you can push it to Docker Hub. If you do not want that you can create your own image registry.

To push a Docker image to the Docker Hub, perform the following steps:

- Sign in to Docker Hub:

  ```cmd
  docker login -u <your docker hub login>
  ```

  Docker will ask you for your password. If the login was successful the message "Login Succeeded" will show up.

- Retrieving the image ID:

  ```cmd
  docker images
  ```

  This will list all your images. There is a column called "IMAGE ID". Copy this ID

- Tag the image for Docker Hub:

  ```cmd
  docker tag <image ID> <docker hub login>/demobook:v1
  ```

- Push the image in the Docker Hub:

  ```cmd
  docker push docker.io/<docker hub login>/demobook:v1
  ```

  Open a browser and navigate to https://hub.docker.com. Sign in with your user account. You should see
  your image that you uploaded earlier.

  You can also make this image private. You have to be authenticated to download that image.

## Deploying a container in ACI with a CI / CD pipeline

In this scenario we will use Terraform to create an Azure Container instance (ACI).
We will then Create the CI / CD pipeline for that

### The Terraform code for ACI

see [Terraform Code](terraform-aci/main.tf)