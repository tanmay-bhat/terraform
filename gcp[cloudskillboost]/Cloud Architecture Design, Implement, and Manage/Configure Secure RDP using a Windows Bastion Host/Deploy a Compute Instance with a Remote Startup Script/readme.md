
### Challenge

- Your company has decided to deploy new application services in the cloud and your assignment is developing a secure framework for managing the Windows services that will be deployed. You will need to create a new VPC network environment for the secure production Windows servers.

- Production servers must initially be completely isolated from external networks and cannot be directly accessed from, or be able to connect directly to, the internet. In order to configure and manage your first server in this environment, you will also need to deploy a bastion host, or jump box, that can be accessed from the internet using the Microsoft Remote Desktop Protocol (RDP). The bastion host should only be accessible via RDP from the internet, and should only be able to communicate with the other compute instances inside the VPC network using RDP.

- Your company also has a monitoring system running from the default VPC network, so all compute instances must have a second network interface with an internal only connection to the default VPC network.

- Deploy the secure Windows machine that is not configured for external communication inside a new VPC subnet, then deploy the Microsoft Internet Information Server on that secure machine.


### Tasks:

- Create a new VPC network with a single subnet.

- Create a firewall rule that allows external RDP traffic to the bastion host system.

- Deploy two Windows servers that are connected to both the VPC network and the default network.

- Create a virtual machine that points to the startup script.

- Configure a firewall rule to allow HTTP access to the virtual machine.


Lab Link : https://www.cloudskillsboost.google/focuses/1737?parent=catalog