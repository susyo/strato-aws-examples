import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.services.ec2.AmazonEC2;
import com.amazonaws.services.ec2.AmazonEC2Client;
import com.amazonaws.services.ec2.model.RunInstancesRequest;
import com.amazonaws.services.ec2.model.RunInstancesResult;

public class EC2Example {

    // Fill in AMI id from Symphony
    private static final String AMI_IDENTIFIER="<ami identifier>";

    // Fill in symphony region IP
    private static final String SYMPHONY_CLUSTER_ADDRESS="<cluster ip>";
    private static AmazonEC2 ec2;

    public static void main(String[] args) {

        AWSCredentials credentials;
        try {
            credentials = new ProfileCredentialsProvider().getCredentials();
        } catch (Exception e) {
            throw new AmazonClientException(
                    "Cannot load the credentials from the credential profiles file. " +
                            "Please make sure that your credentials file is at the correct " +
                            "location (~/.aws/credentials), and is in valid format.",
                    e);
        }

        ec2 = new AmazonEC2Client(credentials);
        ec2.setEndpoint(String.format("http://%s/api/v2/ec2/",SYMPHONY_CLUSTER_ADDRESS));

        RunInstancesRequest runInstancesRequest = new RunInstancesRequest(AMI_IDENTIFIER,1,1);

        RunInstancesResult result = ec2.runInstances(runInstancesRequest);

        System.out.println(result.toString());
    }

}
