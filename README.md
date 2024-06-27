# Deploying Python Application in Docker Container By using Terraform

I created a complete vpc infrastructure by using Terraform. You can find the HCL script in main.tf file.
Here is the resource map of the VPC Infrastructure.

![image](https://github.com/venkey12319/Python-App-Deploy-In-Docker/assets/167093427/f10d7dd2-d76d-423e-8fd1-67b1b6329668)

Now let's go and deploy our Python application in a Docker container.

Step 1: Login in Mobaxterm by using the jump server public IP address with the given key pair.

Step 2: Install Docker by using these commands:
         "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce"

Followed commands to install commands: 

"To start & enable Docker	"sudo systemctl start docker
sudo systemctl enable docker"
To Add Your User to the Docker Group	sudo usermod -aG docker $USER
To new group membership without logging out	newgrp docker
To verify docker installation: docker	--version"

Step 3: Login private instance with a keypair
  vim venkat_key2.pem
  copy your pem file key and save it

To permit that file: chmod 400 venkat_key2.pem
To log into a private instance "ssh -i venkat_key2.pem ubuntu@10.0.2.10

Step 4: Log in to your docker hub.
To login "docker login -u venkateshaws -p dckr_pat_5MwqUYcfV***********"

Step 5: Create new directory with required files:

"mkdir venkat-python-app
cd venkat-python-app
vim Dockerfile (I used the multi-stage file to reduce the size of docker image.)
vim app.py 
vim requirements.txt"

**You can find my documents in the same repo**

Step 6: Build docker images & container

To build a docker image: "docker build -t venkateshaws/love:latest

To push the docker image to the Docker Hub: docker push venkateshaws/love:latest

To Pull image from Docker Hub: docker pull venkateshaws/love:latest (optional)

To run Docker container: docker run -d --name venkat-python-app -p 8000:8000 venkateshaws/love:latest

To verify the docker container: docker ps or docker ps -a

To debug: docker logs my-container"

Step 7: Register a private instance in Target Group
       Go to the target group and make sure your instance is in a Healthy state

Step 8: I used port 8000 for my application as I used the same port in the ALB as well.

Step 9: To verify application deployment copy the DNS name of the Load balancer

     this is mine you can consider as a reference: "Docker-ALB-1933861877.us-east-1.elb.amazonaws.com"

  Output:

  ![image](https://github.com/venkey12319/Python-App-Deploy-In-Docker/assets/167093427/b86a3c23-3cb5-438e-94b3-36759d449366)

  

     
     
















