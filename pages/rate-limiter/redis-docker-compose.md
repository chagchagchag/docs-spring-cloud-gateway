## Redis docker-compose

예제로 사용할 Redis 의 docker-compose 파일입니다. 설명은 생략하겠습니다.

```yaml
version: '3.8'
services:
  redis:
    image: redis:7.0
    command: redis-server --port 6379
    hostname: redis-localhost
    labels:
      - "name=redis"
      - "mode=standalone"
    ports:
      - 26379:6379
    depends_on: 
      - redis-commander
    links:
      - redis-commander
    # networks:
    #   - redis-local
  redis-commander:
    image: rediscommander/redis-commander:latest
    hostname: redis-commander-localhost
    restart: always
    environment:
      - REDIS_HOSTS=redis-localhost
    ports:
      - 38081:8081
    # networks:
    #   - redis-local
# networks:
#   redis-local:
#     driver: bridge
```

<br/>



