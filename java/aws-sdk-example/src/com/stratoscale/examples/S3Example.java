package com.stratoscale.examples;

import java.io.File;
import java.io.IOException;

import com.amazonaws.*;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.PutObjectRequest;

public class S3Example {

    // Fill in a Symphony region IP
    private static final String SYMPHONY_CLUSTER_ADDRESS = "<cluster ip>";

    // Fill in Access Key & Secret
    private static final String AWS_ACCESS_KEY = "<access key>";
    private static final String AWS_SECRET_KEY = "<secret key>";

    // Fill in wanted bucket, object and key parameters
    private static final String BUCKET_NAME = "<pre-created bucket name>";
    private static final String KEY_NAME = "<name of object>";
    private static final String UPLOAD_FILE_FULL_PATH = "<path to file>";

    private static final String SIGNER_TYPE="S3SignerType";

    public static void main(String[] args) throws IOException {
        
	// Create AWS credentials using Symphony Acccess Key and Secret
        BasicAWSCredentials credentials = new BasicAWSCredentials(AWS_ACCESS_KEY, AWS_SECRET_KEY);

	// Set S3 Client Endpoint to Symphony
        AwsClientBuilder.EndpointConfiguration symphonyEndpoint = new AwsClientBuilder.EndpointConfiguration(
                String.format("%s://%s:1060", Protocol.HTTPS, SYMPHONY_CLUSTER_ADDRESS),"");

	// Set signer type and http scheme
        ClientConfiguration conf = new ClientConfiguration()
                .withSignerOverride(SIGNER_TYPE)
                .withProtocol(Protocol.HTTPS);

        AmazonS3 S3Client = AmazonS3ClientBuilder.standard()
                .withEndpointConfiguration(symphonyEndpoint)
                .withCredentials(new AWSStaticCredentialsProvider(credentials))
                .withClientConfiguration(conf)
                .withPathStyleAccessEnabled(true)
                .build();

        try {
            System.out.println("Uploading a new object to S3 from a file\n");
            File file = new File(UPLOAD_FILE_FULL_PATH);
            S3Client.putObject(new PutObjectRequest(
                    BUCKET_NAME, KEY_NAME, file));

        } catch (AmazonServiceException ase) {
            System.out.println("Caught an AmazonServiceException, which " +
                    "means your request made it " +
                    "to Symphony S3, but was rejected with an error response" +
                    " for some reason.");
            System.out.println("Error Message:    " + ase.getMessage());
            System.out.println("HTTP Status Code: " + ase.getStatusCode());
            System.out.println("AWS Error Code:   " + ase.getErrorCode());
            System.out.println("Error Type:       " + ase.getErrorType());
            System.out.println("Request ID:       " + ase.getRequestId());
        } catch (AmazonClientException ace) {
            System.out.println("Caught an AmazonClientException, which " +
                    "means the client encountered " +
                    "an internal error while trying to " +
                    "communicate with S3, " +
                    "such as not being able to access the network.");
            System.out.println("Error Message: " + ace.getMessage());
        }
    }

}
