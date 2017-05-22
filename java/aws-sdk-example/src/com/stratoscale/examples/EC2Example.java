package com.stratoscale.examples;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.ec2.AmazonEC2;
import com.amazonaws.services.ec2.AmazonEC2ClientBuilder;
import com.amazonaws.services.ec2.model.RunInstancesRequest;
import com.amazonaws.services.ec2.model.RunInstancesResult;

public class EC2Example {

    // Fill in AMI ID from Symphony
    private static final String AMI_IDENTIFIER = "<ami identifier>";

    // Fill in Symphony Region IP
    private static final String SYMPHONY_CLUSTER_ADDRESS = "<symphony ip>";

    // Fill in access key and secret provided by Symphony
    private static final String AWS_ACCESS_KEY = "<access key>";
    private static final String AWS_SECRET_KEY = "<secret key>";

    public static void main(String[] args) throws Exception {

        // Creating Amazon credentials from key and secret
        BasicAWSCredentials credentials = new BasicAWSCredentials(AWS_ACCESS_KEY, AWS_SECRET_KEY);
        AwsClientBuilder.EndpointConfiguration symphonyEndpoint = new AwsClientBuilder.EndpointConfiguration(
                String.format("http://%s/api/v2/ec2/", SYMPHONY_CLUSTER_ADDRESS),"Symphony");

        // Creating an EC2 client with the Symphony region endpoint, and credentials.
        AmazonEC2 ec2 = AmazonEC2ClientBuilder.standard()
                .withEndpointConfiguration(symphonyEndpoint)
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .build();

        RunInstancesRequest runInstancesRequest = new RunInstancesRequest(AMI_IDENTIFIER, 1, 1);
        RunInstancesResult result = ec2.runInstances(runInstancesRequest);

        System.out.println(result.toString());
    }
}