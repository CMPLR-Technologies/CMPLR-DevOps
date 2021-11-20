provider "aws" {
    region = "eu-central-1"
}


//Setting up VPC network
resource "aws_vpc" "master-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "master-vpc"
  }
}


//Setting up subnet
resource "aws_subnet" "master-subnet" {
  cidr_block = "${cidrsubnet(aws_vpc.master-vpc.cidr_block, 3, 1)}"    //this function is used to configure the CIDR block of the subnet within the VPC CIDR block
  //refer to using it from http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
  vpc_id = "${aws_vpc.master-vpc.id}"
  availability_zone = "eu-central-1a"
}



//Setting up secrity group to manage security rules (we won't use the default security group)
//Here we configure it to accept traffic from all ips (with ssh of course to maintain security)
//
resource "aws_security_group" "master-ingress" {
    name = "master-ingress"   
    vpc_id = "${aws_vpc.master-vpc.id}"

    //ingress is used to configure inbound traffic
    //To ssh
    ingress {
        cidr_blocks = [
        "0.0.0.0/0"
        ]
        from_port = 22  //for ssh
        to_port = 22    //for ssh
        protocol = "tcp"
    }
    //To access jenkins
    ingress {
        cidr_blocks = [
        "0.0.0.0/0"
        ]
        from_port = 8080  //for jenkins
        to_port = 8080    //for jenkins
        protocol = "tcp"
    }



    // Terraform removes the default rule and we use egress to configure for outbound rules
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"  //allow all outbound traffic from all ports
    cidr_blocks = ["0.0.0.0/0"]
    }
}

//Attaching public IP to the instance so we can access it
resource "aws_eip" "master-ip" {
  instance = "${aws_instance.master.id}"
  vpc      = true
}

//In order to route traffic from the internet to our VPC we need to set up an internet gateway.
resource "aws_internet_gateway" "master-gw" {
  vpc_id = "${aws_vpc.master-vpc.id}"
    tags = {
        Name = "master-gw"
    }
}

//Create an aws route table and attach the internet gateway created to it
resource "aws_route_table" "master-route-table" {
    vpc_id = "${aws_vpc.master-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.master-gw.id}"
    }
    tags = {
        Name = "master-route-table"
    }
}


//Create an association between the subnet and the route table we just created which will expose the subnet to the internet allowing us access.
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.master-subnet.id}"
  route_table_id = "${aws_route_table.master-route-table.id}"
}

//Finally create the instance 
resource "aws_instance" "master" {
  ami = "ami-0a49b025fffbbdac6" #this is ubuntu 20.04 for the availability zone : eu-central-1
  instance_type = "t2.micro"    #all other details are by default suitable to the application
  key_name = "master"   //this is the name you used to create the key pair in your aws account and terraform knows how to get it
  security_groups = [ "${aws_security_group.master-ingress.id}" ]


  tags = {
      Name = "master"
  }
  subnet_id = "${aws_subnet.master-subnet.id}"
}


//The null resource is to sort execution of the file provisioner as it needs to wait for booth aws_eip and aws_instance to be created
//We can not but this inside the instance and depend on the aws_eip as it (the aws_eip) already depends on the instance
resource "null_resource" "master-null" {
 depends_on = [
   aws_eip.master-ip,
   aws_instance.master
 ] 
//Run the configuration sript for the created instance : install git, docker, jenkins, terraform (so he can provision other instances)
# Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new AWS instance.
  
  #Create connection with the provisioned instance
  connection {
    type    = "ssh"
    user = "ubuntu"
    private_key = "${file("./master.pem")}"
    host = "${aws_eip.master-ip.public_ip}"
  }

  #Copy the bash script file
  provisioner "file" {
    source      = "./master.sh"
    destination = "/tmp/master.sh"
  }
  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master.sh",
      "sudo /tmp/master.sh",
    ]
  }
}
