# HUAWEI SWR Policy Action

This Action allows you to create Docker images and push into a SWR repository. Also, it checks if the repository exist, otherwise, it creates it.

## Parameters

| Parameter           | Type     | Default                                | Description                                                                                                              |
| ------------------- | -------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `access_key_id`     | `string` |                                        | Your HUAWEI access key id                                                                                                   |
| `secret_access_key` | `string` |                                        | Your HUAWEI secret access key                                                                                               |
| `swr_registry`      | `string` |                                        | Your SWR HUAWEI                                                                                                          |
| `repo`              | `string` |                                        | Name of your SWR repository                                                                                              |
| `region`            | `string` |                                        | Your HUAWEI region                                                                                                          |
| `tags`              | `string` | `latest`                               | Comma-separated string of SWR image tags (ex latest,1.0.0,)                                                              |
| `dockerfile`        | `string` | `Dockerfile`                           | Name of Dockerfile to use                                                                                                |
| `extra_build_args`  | `string` | `""`                                   | Extra flags to pass to docker build (see docs.docker.com/engine/reference/commandline/build)                             |
| `path`              | `string` | `.`                                    | Path to Dockerfile, defaults to the working directory                                                                    |
| `prebuild_script`   | `string` |                                        | Relative path from top-level to script to run before Docker build                                                        |
| `behavior`          | `string` | `build`                                | What is the expected behavior, build a new image or upload a previously built one. Valid options are `build` or `upload` |
| `huawei_user`       | `string` |                                        | HUAWEI user is necesary for create API token                                                                             |
| `huawei_password`   | `string` |                                        | HUAWEI password  is necesary for create API token                                                                        |
| `huawei_domain`     | `string` |                                        | HUAWEI Domain is necesary for create API token                                                                           |
| `enpoint_token`     | `string` | `iam.myhuaweicloud.com`                | Address of the server bearing the REST service. The endpoint varies between services in different regions                |
| `enpoint_swr`       | `string` | `swr-api.la-south-2.myhuaweicloud.com` | Address of the server SWR bearing the REST service. The endpoint varies between services in different regions            |
| `swr_namespace`     | `string` | `smu-chile`                            | SWR Organization name                                                                                                    |
| `swr_repos`         | `string` |                                        | Image repository name                                                                                                    |

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
        swr_registry: ${{ secrets.SWR_REGISTRY }}
        region: la-south-2
        repo: ${{ github.repository }}
        tags: dev-${{ github.run_number }}
        behavior: upload
        image_name: ${{ env.IMAGE_NAME }}
        huawei_user: ${{ secrets.HUAWEI_USER }}
        huawei_password: ${{ secrets.HUAWEI_PASSWORD }}
        huawei_domain: ${{ secrets.HUAWEI_DOMAIN }}
        enpoint_token: iam.myhuaweicloud.com
        enpoint_swr: swr-api.la-south-2.myhuaweicloud.com
        swr_namespace: smu-chile
        swr_repos: docker/repo
        dockerfile: Dockerfile
```

## Reference

* <https://github.com/smu-chile/aws-ecr-policy-action>
* <https://support.huaweicloud.com/intl/en-us/api-swr/swr_02_0101.html>  

## License

The MIT License (MIT)
