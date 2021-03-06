<p align="center">
  <a href="" rel="noopener">
</p>

<h3 align="center">Deploying SSH honeypot using AWS EC2</h3>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 


</div>

---

<p align="center"> Do you want to see what passwords malicious actor/bots tries on your precious server and see where is it coming from? Deploy a honeypot with these simple steps!
    <br> 
</p>

## 📝 Table of Contents
- [What is honeypot](#intro)
- [Getting Started](#getting_started)
- [Deployment](#deployment)
- [Option 1:Manual deployment](#manual)
- [Option 2:Automatic deployment](#automatic)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 What is honeypot? <a name = "intro"></a>
`In computer terminology, a honeypot is a computer security mechanism set to detect, deflect, or, in some manner, counteract attempts at unauthorized use of information systems. Generally, a honeypot consists of data (for example, in a network site) that appears to be a legitimate part of the site and contain information or resources of value to attackers. It is actually isolated, monitored, and capable of blocking or analyzing the attackers. This is similar to police sting operations, colloquially known as "baiting" a suspect.`[[1]](#honeypot_term)


<b> This tutorial will intentionally create a vulnerable EC2 server, do not deploy this on your production server!! </b>

## 🏁 Getting Started <a name = "getting_started"></a>
No coding exprience required! We will be using the Free tier AWS EC2 server to see ssh authentication attempts.

### Prerequisites
```
AWS account
Computer
Internet connection
```

## 🚀 Deployment <a name = "deployment"></a>


### Creating a free tier AWS EC2 Server

Log into AWS with your AWS account then click `Services`(Drop down menu on the top left) -> click `EC2` -> click `Launch Instances`

Select `Amazon Linux 2 AMI (HVM), SSD Volume Type` -> click `Review Instance Launch`

Click on the first drop down menu and select `Create a new key pair` -> select `Key pair type` `RSA` -> name `Key pair` name as `honeypotkey`-> Click `Download Keypair`

> Congrats! You built your EC2 server!



### Connecting to your EC2

In your instance dashboard you should see a row created. Instance state should be running in couple minutes after you completed previous step.

Right Click the row -> select `Connect` -> click `SSH client`

On the Mac and open terminal -> insert your path of downloaded key and connect to your EC2

Run this command:
```sh
chmod 400 honeypotkey.cer
```
For example:
```sh
ssh -i honeypotkey.cer ec2-user@ec2-00-000-0000-00.us-west-2.compute.amazonaws.com
```

>If you're having trouble with this step or using Windows, please take a look at this references
>[Youtube - Connect to AWS EC2 instance via ssh from windows](https://www.youtube.com/watch?v=f52IOtTqcP8),
>[Stackoverflow - How do I set up SSH access for an Amazon EC2 instance?](https://stackoverflow.com/questions/6394762/how-do-i-set-up-ssh-access-for-an-amazon-ec2-instance)

## Setting up Honeypot on your EC2


### Modifying AWS Security Group

In your AWS Website EC2 Console:

Click on the running EC2 instance -> It should highlight the row

In the bottom half of the screen, click security

`Details|**Security**|Networking|Storage| Status checks| Monitoring| Tags`

Then click on your blue highlighted security group (it should be named somethingsomthing-launch-wizard)

Click `Edit in-bound rules`

Click `Add rule`

Input `222` in the Port range  and select `anywhere` then click `save rules`

eg. image


>If you want to set up the honeypot manually, follow [Option 1](#manual)
>If you want to set up the honeypot automatically,follow [Option 2](#automatic)

## Option 1 : Getting your hands dirty / Manual <a name = "manual"></a>

### Creating the SSH Host Keys
```sh
sudo ssh-keygen -A
cd /etc/ssh
sudo chmod 400 ssh_host_*
```

### Install Compilers, Libraries

In your EC2 server: 

Run `sudo yum install gcc gcc-c++ autoconf automake zlib-devel openssl-devel make -y`



### Download OpenSSH

In your EC2 server: 

Run:
```sh
cd ~
mkdir ssh-source
cd ssh-source
wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.0p1.tar.gz
tar -xvzf openssh-8.0p1.tar.gz
cd openssh-8.0p1/
sudo cp auth-passwd.c auth-passwd.c.orig
sudo nano auth-passwd.c
```

add `#include "canohost.h"`


and


```
if (*password != '\0')
{
const char *remote_ip;
remote_ip = ssh_remote_ipaddr(ssh);
struct tm *timePtr;
time_t localTime;
char timeString[100];

localTime = time(NULL);
timePtr = localtime(&localTime);
strftime(timeString, 100, "%D %r", timePtr);

FILE *logFile;
logFile = fopen("/var/log/sshd_attempts","a+");
fprintf (logFile,"From: %s at: %s | user: %s, pass: %s\n", \
remote_ip, timeString, authctxt->user, password);
fclose (logFile);
}
```

Press `Ctrl+X`, `Y`, `Enter`

Run:
```sh
./configure
make
sudo cp sshd_config /usr/local/etc
cd /usr/local/etc
sudo cp /etc/ssh_host_* .
sudo nano sshd_config
```

Edit  `#Port 22` to `Port 22`




### Moving AWS ssh port to 222
In your EC2 instance(command prompt), run:
```sh
sudo cp /etc/ssh/sshd_config /etc/ssh_sshd_config.bak2
sudo nano /etc/ssh/sshd_config
```
Edit  `#Port 22` to `Port 222`

Press `Ctrl+X`, `Y`, `Enter`

Run `sudo systemctl restart sshd`


<b> Now when you're login to ssh you must let computer know you're connecting through port 222</b>
>example

If you used this to connect to your EC2 instance previously:
```sh
ssh -i "honeypotkey.cer ec2-user@ec2-00-000-0000-00.us-west-2.compute.amazonaws.com
```
Now you must add `-p 222` to connect:
```sh
ssh -i honeypotkey.cer ec2-user@ec2-00-000-0000-00.us-west-2.compute.amazonaws.com -p 222
```

**Congrats! you moved your ssh(port 22 by default) to 222!**


## Run the honeypot and look for result
Connect to port 222 then run this command:

`sudo /home/ec2-user/ssh-source/openssh-8.0p1/sshd -f /usr/local/etc/sshd_config`

## Option 2 : Run the shell script<a name = "automatic"></a>

Connect to your EC2 instance, on your EC2 instance, run this command:

```sh
sudo yum install git -y
git clone https://github.com/keeganhsna/honey-aws.git
cd honey-aws
./downloadOpenssh.sh
```




## ✍️ Authors <a name = "authors"></a>
- Keegan - Idea & Initial work
- https://samsclass.info/121/proj/pX9-121-AWS-honeypot.html - Inspiration

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
-  Cole, Eric; Northcutt, Stephen. "Honeypots: A Security Manager's Guide to Honeypots".[1]<a name = "honeypot_term"></a>
