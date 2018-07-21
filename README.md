# Cloud LAMP

<img src="https://cloud.google.com/_static/images/cloud/icons/favicons/onecloud/apple-icon.png" width="96"> <img src="https://www.silhouette-illust.com/wp-content/uploads/2016/06/3423-300x300.jpg" width="96">

This project aims to provide a modern cloud-based implementation of the [LAMP](https://en.wikipedia.org/wiki/LAMP) stack (Linux, Apache, MySQL and PHP). In particular, it implements the following improvements over a traditional monolithic LAMP deployment:

  - Containerize the frontend and app layers in order to leverage consistent environments via immutable infrastructure.
  - Leverage a managed cloud-based container orchestration service in order to eliminate operations overhead and provide seamless elastic, on-demand scalability.
  - Leverage managed and distributed cloud database and storage backends, in order to eliminate operations overhead, increase resilience and availablity, and provide elastic, on-demand scalabliity.
  - Fully automate the infrastructure deployment leveraging Infrastructure-as-Code technology.

## Components

Following on the design principles/goals stated above, below are the implementation details for each components in each solution

### Common
| Component | Implementation detail | Current version |
| ------ | ------ | ------ |
| Infrastructure deployment | Terraform | GCP, Kubernetes providers
| Container orchestration | Google Kubernetes Engine | v1.8.8
| Database backend | Google Cloud SQL | MySQL 5.6
| Storage backend (NFS option) | NFS | NFS on GCE VM

### Drupal
| Component | Implementation detail | Current version |
| ------ | ------ | ------ |
| Frontend + App  | Drupal docker container | Bitnami v8.3.7r0

### Wordpress
| Component | Implementation detail | Current version |
| ------ | ------ | ------ |
| Frontend + App  | Wordpress docker container | Wordpress v4.9.7

## Usage
### Pre-requisites
#### tl;dr
If you've got `gcloud` working, and a few variables set, you should be golden.

#### Create a GCP project and enable billing
We recommended that you create a separate GCP project for this deployment. It is possible to use an existing project but that may cause unknown issues due to unexpected existing conditions.

You can create a new project from the Google Cloud console following [these instructions](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

You can enable billing on your project in the Google Cloud console following [these instructions](https://cloud.google.com/billing/docs/how-to/modify-project).

#### Clone the repo, configure and deploy
Clone the deployment:
```sh
git clone http://gitlab.com/cloudlamp/cloudlamp
```
Change directory to the desired version, for example:
```sh
cd cloudlamp/wordpress
```
Deploy!
```sh
./preflight.sh
terraform apply
```
##### Access Wordpress
Once deployment is completed (usually after a few minutes), deployment results similar to these are displayed:
```sh
lb_ip = <some IP>
```
The service is available at the "lb_ip" in the output above. Alternatively, you can check this IP in the "Services" tab of Kubernetes Enginer in the Google Cloud Console.

## Contributing

PRs and issue reports are very welcome!
