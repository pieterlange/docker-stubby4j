### Kubernetes native HTTP stub service
HTTP stub service for kubernetes, automatically fetching updated stub configuration from git.

### Usage
Create a git repo containing your HTTP stubs as per https://github.com/azagniotov/stubby4j#endpoint-configuration-howto. See the `stub-examples` directory for examples.

Create ssh credentials as per https://github.com/kubernetes/git-sync/blob/master/docs/ssh.md and initialize the kubernetes secret named `stubby-ssh`.

Deploy the stub service: `kubectl create -f deployment.yaml`

You may wish to route requests to your stub service through `Ingress`, setting this up is left as exercise to the reader.
