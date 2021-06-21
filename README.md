# KPACK Awesome Demo


## Setup 

kpack is the kubernetest implementation of the pack, the cloud native buildpack technologie used before.

pre-requisite: [install kpack](https://github.com/pivotal/kpack/blob/main/docs/install.md) on your Kubernetes cluster


## nodejs 

```bash
$ kubectl apply -f kpack/nodejs -n kpack
```

Check the configuration is ok 

```bash
$ kubectl get Builder -n kpack node-builder
$ kubectl get Image -n kpack cnb-nodejs-image
$ kubectl get builds.kpack.io -n kpack
```

Follow the logs of the build:

```bash
$ logs -namespace kpack -image cnb-nodejs-image
```


## SpringBoot 

```bash
$ kubectl apply -f kpack/springboot -n kpack
```

Check the configuration is ok 

```bash
$ kubectl get Builder -n kpack springboot-builder
$ kubectl get Image -n kpack cnb-springboot-image
$ kubectl get builds.kpack.io -n kpack
```

Follow the logs of the build:

```bash
$ logs -namespace kpack -image cnb-nodejs-image
```

## .NET Core (ASP.NET) 

```bash
$ kubectl apply -f kpack/dotnetcore -n kpack
```

Check the configuration is ok 

```bash
$ kubectl get Builder -n kpack dotnetcore-builder
$ kubectl get Image -n kpack cnb-dotnetcore-image
$ kubectl get builds.kpack.io -n kpack
```

Follow the logs of the build:

```bash
$ logs -namespace kpack -image cnb-dotnetcore-image
```

## Vizualize the kpack in action

https://github.com/matthewmcnew/kpdemo

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2021 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
