# HUAWEI SWR Policy Action

This Action allows you to create Docker images and push into a SWR repository. Also, it checks if the repository exist, otherwise, it creates it.

## Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `access_key_id` | `string` | | Your AWS access key id |
| `secret_access_key` | `string` | | Your AWS secret access key |
| `swr_registry` | `string` | | Your SWR HUAWEI |
| `repo` | `string` | | Name of your SWR repository |
| `region` | `string` | | Your AWS region |
| `tags` | `string` | `latest` | Comma-separated string of SWR image tags (ex latest,1.0.0,) |
| `dockerfile` | `string` | `Dockerfile` | Name of Dockerfile to use |
| `extra_build_args` | `string` | `""` | Extra flags to pass to docker build (see docs.docker.com/engine/reference/commandline/build) |
| `path` | `string` | `.` | Path to Dockerfile, defaults to the working directory |
| `prebuild_script` | `string` | | Relative path from top-level to script to run before Docker build |
| `behavior` | `string` | `build` | What is the expected behavior, build a new image or upload a previously built one. Valid options are `build` or `upload`|
| `image_name` | `string` | `""` | Name of the prebuilt image. Is mandatory if behavior is set to `upload`|
## Usage
```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
    - uses: smu-chile/gh-action-huawei-swr-policy@master
      with:
        access_key_id: ${{ secrets.HUAWEI_ACCESS_KEY_ID }}
        secret_access_key: ${{ secrets.HUAWEI_SECRET_ACCESS_KEY }}
        account_id: ${{ secrets.HUAWEI_ACCOUNT_ID }}
        repo: docker/repo
        region: la-south-2
        tags: latest,${{ github.sha }}
        create_repo: false
```

## Reference
* https://github.com/smu-chile/aws-ecr-policy-action

## License
The MIT License (MIT)
