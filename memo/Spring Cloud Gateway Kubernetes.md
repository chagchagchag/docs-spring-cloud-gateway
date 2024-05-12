

[Spring Cloud Kubernetes](https://cloud.spring.io/spring-cloud-kubernetes/spring-cloud-kubernetes.html)



[Spring Cloud Kubernetes with Spring Boot 3](https://piotrminkowski.com/2023/06/08/spring-cloud-kubernetes-with-spring-boot-3/)

[Sample Spring Microservices Kubernetes](https://github.com/piomin/sample-spring-microservices-kubernetes)

[Best Practices for Java Apps on Kubernetes](https://piotrminkowski.com/2023/02/13/best-practices-for-java-apps-on-kubernetes/)



[skaffold 란, Kubernetes 로컬 개발 환경](https://peterica.tistory.com/245)



Spring Cloud kubernetes

- [cloud.spring.io - Spring Cloud Kubernetes](https://cloud.spring.io/spring-cloud-kubernetes/index.html)
  - [Why do you need Spring Cloud Kubernetes?](https://cloud.spring.io/spring-cloud-kubernetes/spring-cloud-kubernetes.html)

- [docs.spring.io - Spring Cloud Kubernetes](https://docs.spring.io/spring-cloud-kubernetes/reference/index.html)
  - [Starters](https://docs.spring.io/spring-cloud-kubernetes/reference/getting-started.html)
    - Starters are convenient dependency descriptors you can include in your application. Include a starter to get the dependencies and Spring Boot auto-configuration for a feature set. Starters that begin with `spring-cloud-starter-kubernetes-fabric8` provide implementations using the [Fabric8 Kubernetes Java Client](https://github.com/fabric8io/kubernetes-client). Starters that begin with `spring-cloud-starter-kubernetes-client` provide implementations using the [Kubernetes Java Client](https://github.com/kubernetes-client/java).
    - Kubernetes 에서 지원하는 Java Client 와 Fabric8 에서 지원하는 Java Client 가 따로 존재하는 듯 해보인다. 즉 구현체로 Kubernetes 에서 지원하는 Java Client, Fabric8 에서 지원하는 Java Client 가 존재하는 것으로 보임.

  - [Spring Cloud Kubernetes Discovery Server](https://docs.spring.io/spring-cloud-kubernetes/reference/spring-cloud-kubernetes-discoveryserver.html)
    - 




<br/>



> **클라이언트 라이브러리로 Kubernetes 애플리케이션 개발하기**
>
> - 참고 : https://aigishoo.tistory.com/19
>
> API Machinery SIG (special interest group) 에서 지원하는 두 개의 쿠버네티스 API 클라이언트 라이브러리가 있습니다. 
>
> - 고랭 클라이언트 : https://github.com/kubernetes/client-go
> - 파이썬 : https://github.com/kubernetes-client/python
>
> 그 외 아래와 같은 사용자 라이브러리도 있습니다.
>
> - Fabric8 자바 클라이언트 : https://github.com/fabric8io/kubernetes-client

<br/>



Fabric 8

- [spring.fabric8.io - Fabric8 Spring](https://spring.fabric8.io/)
- [github.com/fabric8io/spring-cloud-kubernetes](https://github.com/fabric8io/spring-cloud-kubernetes)
- [github.com/fabric8io/spring-cloud-kubernetes - KubernetesDiscoveryClient](https://github.com/fabric8io/spring-cloud-kubernetes/blob/master/spring-cloud-kubernetes-discovery/src/main/java/io/fabric8/spring/cloud/discovery/KubernetesDiscoveryClient.java)
- [Difference between Fabric8 and Official Kubernetes Java Client](https://itnext.io/difference-between-fabric8-and-official-kubernetes-java-client-3e0a994fd4af)
- [jason-heo.github.io - fabric8 kubernetes API 사용법 예제](https://jason-heo.github.io/programming/2021/05/29/fabric8-k8s-api-example.html)

<br/>



Fabric 8 test

- [jason-heo.github.io - fabric8 kubernetes test 사용법 (mocking kubernetes API Server)](https://jason-heo.github.io/programming/2021/09/27/fabric8-mock-server.html)

- [How to write tests with Fabric8 Kubernetes Client](https://developers.redhat.com/articles/2023/01/24/how-write-tests-fabric8-kubernetes-client)

- [Mock Kubernetes API server in Java using Fabric8 Kubernetes Mock Server](https://itnext.io/mock-kubernetes-api-server-in-java-using-fabric8-kubernetes-mock-server-81a75cf6c47c)

- [Fabric8: Mock Kubernetes Server doesn't actually create a resource without 'expect' set](https://stackoverflow.com/questions/74506037/fabric8-mock-kubernetes-server-doesnt-actually-create-a-resource-without-expe)

<br/>



[network.pivotal.io - Spring Cloud Gateway for Kubernetes](https://network.pivotal.io/products/spring-cloud-gateway-for-kubernetes)

[spring.io/blog - Spring Cloud Gateway for Kubernetes](https://spring.io/blog/2021/05/04/spring-cloud-gateway-for-kubernetes)







