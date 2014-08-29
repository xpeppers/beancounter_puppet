# Beancounter puppet

Vagrant VM defition with Puppet provisioner
It setup a beancounter server with all dependencies

## Development

### Requirements

1. [VirtualBox](http://www.virtualbox.org)
2. [Vagrant](http://www.vagrantup.com)

### Using the development VM

    vagrant up
    vagrant ssh

## Deployment

### Requirements

1. [Packer](http://www.packer.io)
2. [AWS CLI](http://aws.amazon.com/cli)

Deploy key in:

    ~/.ssh/deploy

Create a secret.json file in project root:

    {
        "aws_access_key": "your access key",
        "aws_secret_key": "your secret key"
    }

### Deploying on AWS

    aws configure
    sh deploy.sh
