# Docker Registry Backed by S3 Storage

This example demonstrates how to run & configure a docker registry backed by S3 storage,  
whether it's Amazon S3 or Symphony's S3 compatible storage.

# Getting Started
* Fill in the required parameters in the desired S3 configuration, and run the docker registry.
 
 > Note: Docker registry accepts only https traffic in later versions, so you might have to configure   
 the newly created registry as a 'trusted' registry on your docker daemon.