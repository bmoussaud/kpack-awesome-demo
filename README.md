# KPACK Awesome Demo

![Schema](image1.jpg)

## Setup 

kpack is the Kubernetes implementation of the pack, the cloud native buildpack technologie used before.

pre-requisite: [install kpack](https://github.com/pivotal/kpack/blob/main/docs/install.md) on your Kubernetes cluster or run `make kpack`

## Shared resources

edit [kpack/shared/kpack_values.yaml](kpack/shared/kpack_values.yaml) corresponding with your environment registry (url / username) and run:

```bash
AWESOMEDEMO_registry_password=password-to-get-access-image-registry make shared
```

## Configure NodeJS project

Source: https://github.com/bmoussaud/cnb-nodejs

```bash
make kpack-nodejs
# or apply the resources in kpack/nodejs 
```

Check the configuration is ok 

```bash
make check-nodejs
```

Follow the logs of the build:

```bash
kp build logs cnb-nodejs-image -n kpack-awesomedemo
```


## SpringBoot project

Source: https://github.com/bmoussaud/cnb-springboot

```bash
make kpack-springboot
# or apply the resources in kpack/springboot 
```

Check the configuration is ok 

```bash
make check_springboot

or

kubectl get Builder springboot-builder-11.0.10 -n kpack-awesomedemo
kubectl get Builder springboot-builder-11.0.10 -o yaml -n kpack-awesomedemo | bat -l yaml
kubectl get Image -n kpack-awesomedemo cnb-springboot-image 
kubectl get builds.kpack.io -n kpack-awesomedemo
```

Follow the logs of the build:

```bash
kp build logs cnb-springboot-image -n kpack-awesomedemo
```

## .NET Core (ASP.NET) Project

```bash
make kpack-dotnetcore 
# or apply the resources in kpack/dotnetcore 
```

Check the configuration is ok 

```bash
kubectl get Builder -n kpack dotnetcore-builder
kubectl get Image -n kpack cnb-dotnetcore-image
kubectl get builds.kpack.io -n kpack
```

Follow the logs of the build:

```bash
kp build logs  cnb-dotnetcore-image -n kpack-awesomedemo
```

## Deploy the applications

````
make deploy-app-nodejs or kubectl apply -k app/nodejs
make deploy-app-springboot  or kubectl apply -k app/springboot
make deploy-app-dotnetcore or kubectl apply -k app/dotnetcore
````


## Vizualize the kpack in action

https://github.com/matthewmcnew/kpdemo


## GitOps

Ref: 
* https://fluxcd.io/docs/guides/image-update/
* https://particule.io/blog/flux-auto-image-update/

Install [fluxCD] with [Flux CLI](https://fluxcd.io/docs/cmd/) on the K8S `aws-tools` cluster managed by the `kpack-awesome-demo` repository managed by the `${GITHUB_OWNER}`

```bash
export GITHUB_TOKEN=xxxxx
export GITHUB_OWNER=bmoussaud
flux bootstrap github --components-extra=image-reflector-controller,image-automation-controller --owner=${GITHUB_OWNER} --repository=kpack-awesome-demo --branch=main --path=./clusters/aws-tools --personal --read-write-key 

kubectl create secret generic https-github-credentials  -n flux-system  --from-literal=username=${GITHUB_OWNER} --from-literal=password=${GITHUB_TOKEN}
```

Force Flux to reconcile:

```bash
flux reconcile kustomization flux-system --with-source
```

Chech Image configuration (Ready = True)

```bash
➜ flux get image repository                                                                                                               
NAME                       	READY	MESSAGE                      	LAST SCAN                	SUSPENDED
dotnetcore-image-repository	True 	successful scan, found 3 tags	2022-02-01T16:32:05+01:00	False
nodejs-image-repository    	True 	successful scan, found 6 tags	2022-02-01T16:32:10+01:00	False
springboot-image-repository	True 	successful scan, found 7 tags	2022-02-01T16:32:14+01:00	False

➜ flux get image policy                                                                                                                   
NAME                    	READY	MESSAGE                                                                                          	LATEST IMAGE
dotnetcore-harbor-policy	True 	Latest image tag for 'harbor.mytanzu.xyz/library/cnb-dotnet-core' resolved to: b1.20220201.131546	harbor.mytanzu.xyz/library/cnb-dotnet-core:b1.20220201.131546
nodejs-harbor-policy    	True 	Latest image tag for 'harbor.mytanzu.xyz/library/cnb-nodejs' resolved to: b1.20220201.130841     	harbor.mytanzu.xyz/library/cnb-nodejs:b1.20220201.130841
springboot-harbor-policy	True 	Latest image tag for 'harbor.mytanzu.xyz/library/cnb-springboot' resolved to: b1.20220201.131429 	harbor.mytanzu.xyz/library/cnb-springboot:b1.20220201.131429
```

## Demo

* Display the resources

````
kp clusterstore list
kp clusterstack list
kp builder list
kp image list  or kubectl get images.kpack.io -A
kp build list or kubectl get builds.kpack.io -A
````

````
kp image status cnb-springboot-image
kp build status cnb-springboot-image
kp build logs   cnb-springboot-image
````

* Modify the springboot project configuration: https://github.com/bmoussaud/cnb-springboot/blob/master/src/main/resources/application.yml
* Show the build is running on commit
  * open kpack navigator ui to show 
  * `watch kubectl get pod -n kpack-awesomedemo`
  * `kp build logs cnb-springboot-image`
* Show the harbor repository with the new image https://harbor.mytanzu.xyz/harbor/projects/1/repositories/cnb-springboot
  * show the details and environment variable `kpack.builder.author`
* Show the `ImageUpdater` from Flux has updated the yaml file with the new tag: https://github.com/bmoussaud/kpack-awesome-demo/blob/main/clusters/aws-tools/springboot-images.yaml or `git pull`from the cloned repository
* Show the application has been updated
  * `watch kubectl get pod -n cnb-springboot`
  * ui `http://springboot-kpackdemo.mytanzu.xyz/`
* Modify the image to switch to java 11.0.12
  * Show the diff between the 2 versions
    * `kp builder status springboot-builder-11.0.10`  
    * `kp builder status springboot-builder-11.0.12`  
  * replace `11.0.10` with `11.0.12`
    * `kubectl edit image -n kpack-awesomedemo cnb-springboot-image` or  `kp image patch cnb-springboot-image -n kpack-awesomedemo --builder springboot-builder-11.0.12 `
* Demo CVE-2021-44228 (Log4j RCE exploit)
  * https://github.com/alexandreroman/cve-2021-44228-workaround-buildpack
  * Display the pods logs : `k logs -n cnb-springboot app-xxxxx -f`
  * Show the code : https://github.com/bmoussaud/cnb-springboot/blob/master/src/main/java/org/moussaud/demos/cnb/springboot/Application.java#L96
  * Open the application `http://springboot-kpackdemo.mytanzu.xyz/log?message=demo`
  
  * The pod output is
  ````
  2022-02-03 09:07:19.992 ERROR 1 --- [nio-8080-exec-7] o.m.d.c.s.LoggingController              : Running OpenJDK Runtime Environment (build 11.0.12+7-LTS) from BellSoft
  2022-02-03 09:07:19.993 ERROR 1 --- [nio-8080-exec-7] o.m.d.c.s.LoggingController              : message is demo
  ````
  * `kp builder status springboot-builder-11.0.12-cve -n kpack-awesomedemo` and show the `cve-2021-44228-workaround-buildpack` is there
  * `kp image patch cnb-springboot-image --builder springboot-builder-11.0.12-cve -n kpack-awesomedemo`  
  * Dumps build logs : `kp build logs   cnb-springboot-image | grep cve`
  * Open the application `http://springboot-kpackdemo.mytanzu.xyz/log?message=demo`
  * Display the pods logs : `k logs -n cnb-springboot app-xxxxx -f`
  * The pod output is
  ````
  2022-02-03 09:19:47.348 ERROR 1 --- [io-8080-exec-10] o.m.d.c.s.LoggingController              : Running ${java:runtime}
  2022-02-03 09:19:47.348 ERROR 1 --- [io-8080-exec-10] o.m.d.c.s.LoggingController              : message is demo
  ````



  
## Reset Demo

````
kp image patch cnb-springboot-image --builder springboot-builder-11.0.10
````

## Delete Demo

````
flux uninstall --namespace=flux-system
make undeploy-apps
kubectl delete ns kpack-awesomedemo 
````

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2021 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
