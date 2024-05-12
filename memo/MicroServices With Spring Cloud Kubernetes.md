## MicroServices With Spring Cloud Kubernetes

https://piotrminkowski.com/2019/12/20/microservices-with-spring-cloud-kubernetes/



스프링 클라우드와 쿠버네티스는 다양한 사용 사례에 적용할 수 있는 인기 있는 제품입니다. 그러나 마이크로서비스 아키텍처에 있어서는 경쟁 솔루션으로 묘사되기도 합니다. 두 제품 모두 서비스 검색, 분산 구성, 로드 밸런싱 또는 회로 차단과 같은 마이크로서비스 아키텍처에서 널리 사용되는 패턴을 구현하고 있습니다. 물론 두 솔루션은 치열하게 경쟁하고 있습니다.

Kubernetes는 컨테이너화된 애플리케이션을 실행, 확장 및 관리하기 위한 플랫폼입니다. 가장 중요한 쿠버네티스 구성 요소 중 하나는 etcd입니다. 가용성이 뛰어난 이 키-값 저장소는 서비스 레지스트리와 애플리케이션 구성을 포함한 모든 클러스터 데이터를 저장하는 역할을 담당합니다. 다른 어떤 도구로도 대체할 수 없습니다. 보다 고급 라우팅 및 로드 밸런싱 전략은 Istio 또는 Linkerd와 같은 타사 구성 요소로 실현할 수 있습니다. Kubernetes에서 애플리케이션을 배포하고 실행하기 위해 소스 코드에 아무것도 추가할 필요가 없습니다. 오케스트레이션과 컨규레이션은 애플리케이션 외부, 즉 플랫폼에서 실현됩니다. Spring Cloud는 좀 더 다른 접근 방식을 제시합니다. 모든 구성 요소는 애플리케이션 측에서 포함 및 구성되어야 합니다. 이는 클라우드 네이티브 개발에 사용되는 다양한 도구 및 프레임워크와 통합할 수 있는 많은 가능성을 제공합니다. 하지만 처음에 Spring Cloud는 Eureka, Ribbon, Hystrix 또는 Zuul과 같은 Netix OSS 구성 요소를 중심으로 구축되었습니다. 이를 통해 마이크로서비스 기반 아키텍처에 쉽게 포함시키고 다른 클라우드 네이티브 구성 요소와 통합할 수 있는 메커니즘을 제공했습니다. 얼마 후 이러한 접근 방식은 재고되어야 했습니다. 오늘날에는 Spring Cloud Gateway(Zuul 대체), Spring Cloud Load Balancer(Ribbon 대체), Spring Cloud Circuit Breaker(Hystrix 대체)와 같은 많은 구성 요소를 Spring Cloud에서 개발했습니다. 또한 Kubernetes와의 통합을 위한 비교적 새로운 프로젝트인 Spring Cloud Kubernetes도 있습니다.

Translated with DeepL.com (free version)



## Why Spring Cloud Kubernetes?

우리가 마이크로서비스를 OpenShift로 마이그레이션할 당시에는 Spring Cloud Kubernetes 프로젝트가 인큐베이션 단계에 있었습니다. Spring Cloud에서 OpenShift로의 마이그레이션을 위한 다른 흥미로운 선택지가 없었기 때문에 Spring Boot 애플리케이션에서 Discovery 구성 요소(Eureka 클라이언트)와 config (Spring Cloud Cong 클라이언트)를 제거하는 것 외에는 별다른 방법이 없었습니다. 물론 OpenFeign, Ribbon(Kubernetes 서비스를 통해) 또는 Sleuth와 같은 다른 Spring Cloud 구성 요소는 계속 사용할 수 있었습니다. 그렇다면 문제는 우리에게 정말 Spring Cloud Kubernetes가 필요한가 하는 것입니다. 그리고 어떤 기능이 우리에게 흥미로울까요?
먼저, Spring Cloud Kubernetes 문서 사이트에서 제공되는 새로운 프레임워크를 구축하게 된 동기를 살펴봅시다.

> 스프링 클라우드 쿠버네티스는 쿠버네티스 네이티브 서비스를 소비하는 스프링 클라우드 공통 인터페이스 구현을 제공합니다. 이 리포지토리에서 제공되는 프로젝트의 주요 목표는 Kubernetes 내부에서 실행되는 Spring Cloud와 Spring Boot 애플리케이션의 통합을 용이하게 하는 것입니다.

Translated with DeepL.com (free version)



간단히 말해서, Spring Cloud Kubernetes는 Spring Cloud 방식으로 Discovery, config 및 load balancing 을 사용할 수 있도록 Kubernetes Master API와의 통합을 제공합니다.
이 글에서는 Spring Cloud Kubernetes의 다음과 같은 유용한 기능에 대해 소개하겠습니다:

- DiscoveryClient 지원을 통해 모든 네임스페이스에서 검색 확장하기
- Spring Cloud Kubernetes Config 로 스프링 부트 속성 소스로 ConfigMap과 시크릿 사용하기 
- Spring Cloud Kubernetes pod 상태 표시기(health indicator)를 사용하여 상태 확인 구현하기



## Enable Spring Cloud Kubernetes

Spring Cloud Kubernetes에서 제공하는 더 많은 기능을 사용한다고 가정하면 Maven pom.xml에 다음과 같은 종속성을 포함해야 합니다. 여기에는 검색, 구성 및 리본 로드 밸런싱을 위한 모듈이 포함되어 있습니다.

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-kubernetes-all</artifactId> </dependency>
```

<br/>



## Source Code

샘플 애플리케이션의 소스 코드는 샘플 스프링 마이크로서비스 쿠버네티스 리포지토리(https://github.com/piomin/sample-spring-microservices-kubernetes/tree/hybrid)의 브랜치 `hybrid`에서 확인할 수 있습니다. 마스터 브랜치에서는 Kubernetes에 배포된 Spring Boot 마이크로서비스에 대한 이전 글의 예제를 찾을 수 있습니다: [Kubernetes, Spring Boot 2.0 및 Docker를 사용한 마이크로서비스에 대한 빠른 가이드.](https://piotrminkowski.com/2018/08/02/quick-guide-to-microservices-with-kubernetes-spring-boot-2-0-and-docker/)

<br/>



## Discovery across all namespaces
스프링 클라우드 쿠버네티스는 디스커버리클라이언트의 구현을 제공함으로써 쿠버네티스 검색을 스프링 부트 애플리케이션과 통합할 수 있게 해줍니다. 또한, 리본 클라이언트와의 기본 제공 통합을 활용하여 쿠버네티스 서비스를 사용하지 않고도 파드와 직접 통신할 수 있습니다.
리본 클라이언트와 내장된 통합을 활용할 수도 있습니다. Ribbon 클라이언트는 상위 수준의 HTTP 클라이언트인 OpenFeign에서 활용할 수 있습니다. 이러한 모델을 구현하려면 우리는 Mongo Database 를 백엔드 저장소로 사용하기 때문에 Disovery Client, Feign Client, Mongo Repositories 를 Enable 해야 합니다.

```java
@SpringBootApplication 
@EnableDiscoveryClient 
@EnableFeignClients 
@EnableMongoRepositories 
public class DepartmentApplication {
   public static void main(String[] args) {
      SpringApplication.run(DepartmentApplication.class, args);    	  }
}
```

세 개의 마이크로서비스가 각각 다른 네임스페이스에 배포되어 있는 시나리오를 생각해 보겠습니다. 네임스페이스로 나누는 것은 논리적인 그룹화일 뿐이며, 예를 들어 모든 마이크로서비스를 담당하는 세 개의 팀이 있고 특정 애플리케이션을 담당하는 팀에게만 네임스페이스에 대한 권한을 부여하고자 하는 경우입니다. 서로 다른 네임스페이스에 위치한 애플리케이션 간의 통신에서는 호출 URL에 네임스페이스 이름을 접두사로 포함시켜야 합니다. 또한 애플리케이션 간에 계층화될 수 있는 포트 번호도 설정해야 합니다. Spring Cloud Kubernetes discovery 는 이러한 상황에서 도움을 줍니다. Spring Cloud Kubernetes는 마스터 API와 통합되어 있기 때문에 동일한 애플리케이션을 위해 생성된 모든 파드의 IP를 가져올 수 있습니다. 다음은 시나리오를 설명하는 다이어그램입니다.

Translated with DeepL.com (free version)

![](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-discovery.png?resize=575%2C469)

<br/>



To enable discovery across all namespaces we just need use the following property.

```yaml
spring:
  cloud:
    kubernetes:
      discovery:
        all-namespaces: true
```

이제 대상 엔드포인트의 소비를 담당하는 Feign 클라이언트 인터페이스를 구현할 수 있습니다. 다음은 *department-service* 의 샘플 클라이언트로, *employee-service*와의 통신 전용입니다.

```java
@FeignClient(name = "employee")
public interface EmployeeClient {

   @GetMapping("/department/{departmentId}")
   List<Employee> findByDepartment(@PathVariable("departmentId") String departmentId);
   
}
```

단일 서비스에 대해 실행 중인 파드의 주소 목록을 검색하려면 Spring Cloud Kubernetes에서 Kubernetes API에 액세스할 수 있어야 합니다. Minikube를 사용할 때 가장 간단한 방법은 `cluster-admin` 권한으로 기본 `ClusterRoleBinding`을 생성하는 것입니다. 다음 명령을 실행하면 모든 파드가 Kubernetes API와 통신할 수 있는 충분한 권한을 갖게 됩니다.

```shell
$ kubectl create clusterrolebinding admin --clusterrole=cluster-admin --service
```

<br/>



## Configuration with Kubernetes PropertySource

스프링 클라우드 쿠버네티스 `PropertySource` 구현을 사용하면 **`Deployment`에 주입하지 않고 애플리케이션에서 `ConfigMap`과 `Secret`을 직접 사용할 수 있습니다.** 기본 동작은 **`ConfigMap` 또는 `Secret` 내부의 `metadata.name`을 기반으로 하며, 이는 애플리케이션 이름과 동일해야** 합니다(`spring.application.name` 속성에 정의된 대로). 또한 구성 주입을 위해 네임스페이스와 객체의 사용자 정의 이름을 정의할 수 있는 고급 동작을 사용할 수도 있습니다. 여러 개의 `ConfigMap` 또는 `Secret` 인스턴스를 사용할 수도 있습니다. 하지만 여기서는 기본 동작을 사용하므로 다음과 같은 `bootstrap.yml`이 있다고 가정합니다:

```yaml
spring:
  application:
    name: employee
```

We are going to define the following `ConfigMap`:

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: employee
data:
  logging.pattern.console: "%d{HH:mm:ss} ${LOG_LEVEL_PATTERN:-%5p} %m%n"
  spring.cloud.kubernetes.discovery.all-namespaces: "true"
  spring.data.mongodb.database: "admin"
  spring.data.mongodb.host: "mongodb.default"
```

Alternatively you can use an embedded YAML file in `ConfigMap`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: employee
data:
  application.yaml: |-
    logging.pattern.console: "%d{HH:mm:ss} ${LOG_LEVEL_PATTERN:-%5p} %m%n"
    spring.cloud.kubernetes.discovery.all-namespaces: true
    spring:
      data:
        mongodb:
          database: admin
          host: mongodb.default
```

Config map 에서는 다중 네임스페이스 검색을 허용하는 Mongo 위치, 로그 패턴 및 속성을 정의합니다. Mongo 자격 증명은 'Secret' 오브젝트 내에 정의해야 합니다. 규칙은 구성 맵과 동일합니다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: employee
type: Opaque
data:
  spring.data.mongodb.username: UGlvdF8xMjM=
  spring.data.mongodb.password: cGlvdHI=
```

기본적으로 API를 통한 시크릿 사용은 보안상의 이유로 활성화되어 있지 않습니다. 그러나 이미 기본 `cluster-admin` 역할을 설정했기 때문에 걱정할 필요가 없습니다. 우리가 해야 할 일은 기본적으로 비활성화되어 있는 Spring Cloud Kubernetes용 API를 통한 시크릿 소비를 활성화하는 것뿐입니다. 이를 위해서는 `bootstrap.yml`에서 다음 속성을 설정해야 합니다.

```yaml
spring:
  cloud:
    kubernetes:
      secrets:
        enableApi: true
```

<br/>



## Deploying Spring Cloud apps on Minikube

먼저 `kubectl create namespace` 명령어를 사용하여 필요한 네임스페이스를 생성해 보겠습니다. 다음은 네임스페이스 `a`, `b`, `c`, `d`를 생성하는 명령어입니다.

![microservices-with-spring-cloud-kubernetes-create-namespace](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-create-namespace.png?resize=451%2C137)

Then, let’s build the code by executing Maven `mvn clean install` command.

![microservices-with-spring-cloud-kubernetes-mvn](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-mvn.png?resize=583%2C239)

We also need to set `cluster-admin` for newly created namespaces in order to allow pods running inside these namespaces to read master API.

![microservices-with-spring-cloud-kubernetes-admin](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-admin.png?resize=696%2C108)

이제 쿠버네티스 배포 매니페스트를 살펴보겠습니다. 이것은 `ConfigMap`과 `Secret`에서 어떤 속성도 주입하지 않기 때문에 매우 간단합니다. 이 작업은 이미 Spring Cloud Kubernetes Config에 의해 수행됩니다. 다음은 *employee-service*에 대한 배포 YAML 파일입니다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: employee
  labels:
    app: employee
spec:
  replicas: 1
  selector:
    matchLabels:
      app: employee
  template:
    metadata:
      labels:
        app: employee
    spec:
      containers:
      - name: employee
        image: piomin/employee:1.1
        ports:
        - containerPort: 8080
```

마지막으로 쿠버네티스에 애플리케이션을 배포할 수 있습니다. 각 마이크로서비스에는 `ConfigMap`, `Secret`, `Deployment` 및 `Service` 오브젝트가 있습니다. YAML 매니페스트는 `/kubernetes` 디렉터리 내의 Git 리포지토리에서 사용할 수 있습니다. 아래와 같이 `kubectl apply` 명령어를 사용하여 순차적으로 적용하고 있습니다.

테스트 목적으로 `NodePort` 유형을 정의하여 샘플 애플리케이션을 노드 외부에 노출할 수 있습니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: department
  labels:
    app: department
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: department
  type: NodePort
```

<br/>



## Exposing info about a pod

서비스를 `NodePort`로 정의했다면, 미니큐브 외부에서 쉽게 접근할 수 있습니다. 대상 포트를 검색하려면 아래와 같이 `kubectl get svc`를 실행하면 됩니다. 이제 `http://192.168.99.100:31119` 주소로 호출할 수 있습니다.

![microservices-with-spring-cloud-kubernetes-svc](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-svc.png?resize=516%2C50)

스프링 클라우드 쿠버네티스를 사용하면 각 스프링 부트 애플리케이션은 파드 아이피, 파드 이름 및 네임스페이스 이름에 대한 정보를 노출합니다. 이를 입력하려면 아래와 같이 `/info` 엔드포인트를 호출해야 합니다.

![microservices-with-spring-cloud-kubernetes-info](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-info.png?resize=359%2C207)

Here’s the list of pods distributed between all namespaces after deploying all sample microservices and gateway.

![microservices-with-spring-cloud-kubernetes-pods](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-pods.png?resize=696%2C315)

And also a list of deployments.

![microservices-with-spring-cloud-kubernetes-deploy](https://piotrminkowski.files.wordpress.com/2019/12/microservices-with-spring-cloud-kubernetes-deploy.png?resize=696%2C255)



## Running gateway

아키텍처의 마지막 요소는 게이트웨이입니다. 저희는 리본 클라이언트를 통해 Kubernetes 검색과 통합된 Spring Cloud Netflix Zuul을 사용합니다. 여러 네임스페이스에 분산된 모든 샘플 마이크로서비스에 대한 Swagger 설명서를 노출하고 있습니다. 다음은 필수 종속성 목록입니다.

```xml
<dependencies>
   <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
   </dependency>
   <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-kubernetes-all</artifactId>
   </dependency>
   <dependency>
      <groupId>org.springframework.cloud</groupId>
      <artifactId>spring-cloud-starter-sleuth</artifactId>
   </dependency>
   <dependency>
      <groupId>io.springfox</groupId>
      <artifactId>springfox-swagger-ui</artifactId>
      <version>2.9.2</version>
   </dependency>
   <dependency>
      <groupId>io.springfox</groupId>
      <artifactId>springfox-swagger2</artifactId>
      <version>2.9.2</version>
   </dependency>
</dependencies>
```

경로 구성은 매우 간단합니다. Spring Cloud Kubernetes 검색 기능을 사용하기만 하면 됩니다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gateway
data:
  logging.pattern.console: "%d{HH:mm:ss} ${LOG_LEVEL_PATTERN:-%5p} %m%n"
  spring.cloud.kubernetes.discovery.all-namespaces: "true"
  zuul.routes.department.path: "/department/**"
  zuul.routes.employee.path: "/employee/**"
  zuul.routes.organization.path: "/organization/**"
```

Zuul 프록시가 'DiscoveryClient'와 자동으로 통합되는 동안 마이크로서비스에 의해 노출되는 동적 해상도 Swagger 엔드포인트를 쉽게 구성할 수 있습니다.

```java
@Configuration
public class GatewayApi {

   @Autowired
   ZuulProperties properties;

   @Primary
   @Bean
   public SwaggerResourcesProvider swaggerResourcesProvider() {
      return () -> {
         List<SwaggerResource> resources = new ArrayList<>();
         properties.getRoutes().values().stream()
               .forEach(route -> resources.add(createResource(route.getId(), "2.0")));
         return resources;
      };
   }

   private SwaggerResource createResource(String location, String version) {
      SwaggerResource swaggerResource = new SwaggerResource();
      swaggerResource.setName(location);
      swaggerResource.setLocation("/" + location + "/v2/api-docs");
      swaggerResource.setSwaggerVersion(version);
      return swaggerResource;
   }

}
```

일반적으로 게이트웨이에 액세스하려면 Kubernetes `Ingress`를 구성해야 합니다. 미니큐브를 사용하면 `NodePort` 유형의 서비스를 생성하기만 하면 됩니다. 마지막으로, 게이트웨이에 노출된 Swagger UI를 사용하여 애플리케이션 테스트를 시작할 수 있습니다. 하지만 여기서 예상치 못한 문제가 발생합니다... 모든 네임스페이스에 대한 검색이 Ribbon 클라이언트에서 작동하지 않습니다. 'DiscoveryClient'에 대해서만 작동합니다. 리본 자동 구성이 `spring.cloud.kubernetes.discovery.all-namespaces` 속성을 존중해야 한다고 생각하지만, 이 경우 해결 방법을 준비하는 것 외에는 다른 선택의 여지가 없습니다. 해결 방법은 Spring Cloud Kubernetes 내에서 제공되는 리본 클라이언트 자동 구성을 재정의하는 것입니다. 아래 그림과 같이 `DiscoveryClient`를 직접 사용하고 있습니다.

```java
public class RibbonConfiguration {

    @Autowired
    private DiscoveryClient discoveryClient;

    private String serviceId = "client";
    protected static final String VALUE_NOT_SET = "__not__set__";
    protected static final String DEFAULT_NAMESPACE = "ribbon";

    public RibbonConfiguration () {
    }

    public RibbonConfiguration (String serviceId) {
        this.serviceId = serviceId;
    }

    @Bean
    @ConditionalOnMissingBean
    public ServerList<?> ribbonServerList(IClientConfig config) {

        Server[] servers = discoveryClient.getInstances(config.getClientName()).stream()
                .map(i -> new Server(i.getHost(), i.getPort()))
                .toArray(Server[]::new);

        return new StaticServerList(servers);
    }

}
```

The Ribbon configuration class needs to be set on the main class.

```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableZuulProxy
@EnableSwagger2
@AutoConfigureAfter(RibbonAutoConfiguration.class)
@RibbonClients(defaultConfiguration = RibbonConfiguration.class)
public class GatewayApplication {

   public static void main(String[] args) {
      SpringApplication.run(GatewayApplication.class, args);
   }

}
```

Now, we can finally take advantage of multi namespace discovery and load balancing and easily test it using the Swagger UI exposed on the gateway.

이제 마침내 멀티 네임스페이스 검색 및 로드 밸런싱을 활용하고 게이트웨이에 노출된 Swagger UI를 사용하여 쉽게 테스트할 수 있게 되었습니다.

![swagger-ui](https://piotrminkowski.files.wordpress.com/2019/12/swagger-ui.png?resize=696%2C508)

<br/>



## Summary

Spring Cloud Kubernetes is currently one of the most popular Spring Cloud projects. In this context, it may be a little surprising that it is not up-to-date with the latest Spring Cloud features. For example, it still uses Ribbon instead of the new Spring Cloud Load Balancer. Anyway, it provides some useful mechanisms that simplifies Spring Boot application deployment on Kubernetes. In this article I presented the most useful features like discovery across all namespaces or configuration property sources with Kubernetes `ConfigMap` and `Secret`.



스프링 클라우드 쿠버네티스는 현재 가장 인기 있는 스프링 클라우드 프로젝트 중 하나입니다. 이러한 맥락에서 볼 때, 최신 Spring Cloud 기능이 최신이 아니라는 것은 다소 의외일 수 있습니다. 예를 들어, 새로운 스프링 클라우드 로드 밸런서 대신 여전히 리본을 사용합니다. 어쨌든, Kubernetes에서 Spring Boot 애플리케이션 배포를 간소화하는 몇 가지 유용한 메커니즘을 제공합니다. 이 글에서는 쿠버네티스 '컨피그맵'과 '시크릿'으로 모든 네임스페이스 또는 구성 속성 소스에서 검색하는 것과 같은 가장 유용한 기능을 소개했습니다.