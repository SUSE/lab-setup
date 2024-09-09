# Contribution guide

## Code lifecycle management

### Gitflow

This git repository follows the Gitflow pattern, so make sure to follow the convention:

- clone the repository (if not already done)
- make sure you are up-to-date with git pull command
- create a branch `feature/my-change-title` from `develop`
- commit your changes on this feature branch and send them with the git push command
- once the changes are good enough for a review/discussion, create a Pull Request (PR) targetting `develop`
- make sure the checks are all green
- once the PR is validated it will be merged to `develop` (with a squash commit) and the feature branch deleted

Maintainers will regularly create a Pull Request (merge commit) from `develop` (latest quality) to `main` (production/stable).

### CI/CD

Continuous Integration and Continuous Delivery are automated through CI/CD pipelines running as GitHub actions.

The source of the pipeline-as-code are in the `.github/workflows` folder:

- [`ci.yml`](.github/workflows/ci.yml)
- [`pkg.yml`](.github/workflows/pkg.yml)

## Code convention

For bash/shell script files, follow the conventions from [Google Style Guide](https://google.github.io/styleguide/shellguide.html).

The quality will be checked by the CI pipeline.

## Troubleshooting

### Container image creation

Here is how to build and push an image to the registry:

```bash
docker login -u $CONTAINER_REGISTRY_USER -p $CONTAINER_REGISTRY_PASSWD ghcr.io
cd src/cow-demo
docker build . -t ghcr.io/suse/cow-demo:1.0.0
docker push ghcr.io/suse/cow-demo:1.0.0
```
