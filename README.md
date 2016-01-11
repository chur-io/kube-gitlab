#kube-git
## Simple boilerplate that build a website in gitlab and deploy to kubernetes.

### It achieves the following for CI/CD:
- build Docker images
- run `grunt` tasks for client-side build
- host and serve files with nginx
- push Docker image to a private repo
- create Kubernetes replication controller and service
- rolling update Kubernetes replication controller
- delete replication controller if container is failing
- only run gitlab builds with `git tag`


The main artifacts are
- `.gitlab-ci.yml` - setup CI jobs and builds in gitlab
- `build\common.sh` - bash script functions to be called by `.gitlab-ci.yml`
- `dockerfile` - dockerfile config
- `rc.yaml` - Kubernetes replication controller config
- `service.yaml` - Kubernetes service config








