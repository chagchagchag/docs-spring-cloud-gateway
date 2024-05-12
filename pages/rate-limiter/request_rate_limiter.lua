local tokens_key = KEYS[1]
local timestamp_key = KEYS[2]
--redis.log(redis.LOG_WARNING, "tokens_key " .. tokens_key)
-- https://github.com/spring-cloud/spring-cloud-gateway/blob/main/spring-cloud-gateway-server/src/main/resources/META-INF/scripts/request_rate_limiter.lua
 
local rate = tonumber(ARGV[1])
local capacity = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local requested = tonumber(ARGV[4])
 
local fill_time = capacity/rate
local ttl = math.floor(fill_time*2)
 
-- arg1 : replenishRate ==> 초당 버킷 회복량
-- arg2 : burstCapacity ==> 버킷에 담을 수 있는 최대 양
-- arg3 : Instant.now().getEpochScond() : 초단위로 구분된 Epoch Time
-- arg4 : requestedTokens ==> 요청 시에 소모할 토큰의 갯수
-- fill_time = capacity (버킷에 담을 수 있는 최대 양) / rate (초당 버킷 회복량)
--    ==> "버킷을 모두 채우는 데에 몇 초를 쓰는지"
-- ttl : fill_time * 2

--redis.log(redis.LOG_WARNING, "rate " .. ARGV[1])
--redis.log(redis.LOG_WARNING, "capacity " .. ARGV[2])
--redis.log(redis.LOG_WARNING, "now " .. ARGV[3])
--redis.log(redis.LOG_WARNING, "requested " .. ARGV[4])
--redis.log(redis.LOG_WARNING, "filltime " .. fill_time)
--redis.log(redis.LOG_WARNING, "ttl " .. ttl)

/*
  last_tokens 
  : token_key 에 대해 저장된 값을 꺼내서 저장하는 임시데이터
  : new_tokens 를 만들기 위해 사용하는 변수이다. 
  : 계산된 new_tokens 값은 tokens_key 에 대한 값으로 저장되며 
    lua script 가 호출될 때 마다 tokens_key 에 대한 값으로 다시 읽어들이며 
    읽어들인 시점에서는 last_tokens 변수에 이 값을 저장한다.
   k ~ capacity
*/
local last_tokens = tonumber(redis.call("get", tokens_key))
if last_tokens == nil then
  last_tokens = capacity
end
--redis.log(redis.LOG_WARNING, "last_tokens " .. last_tokens)
 
/*
  last_refreshed 
  : timestamp_key 에 대해 저장된 값을 꺼내서 저장하는 임시데이터 
  : 가장 최근에 업데이트 된 시점에 대한 timestamp 값 
  0 ~ 가장 최근 시점에 변경시점의 timestamp
*/
local last_refreshed = tonumber(redis.call("get", timestamp_key))
if last_refreshed == nil then
  last_refreshed = 0
end
--redis.log(redis.LOG_WARNING, "last_refreshed " .. last_refreshed)

-- delta : (이전 인출 이후로 )몇 초 지났는지
local delta = math.max(0, now-last_refreshed)

/*
  delta * rate 
  : delta * 초당 버킷 회복량
  : 즉, delta 동안 회복된 총 버킷 회복량 

  last_tokens + (delta * rate) 
  : 가장 최근의 토큰 양 + delta 동안 회복된 총 버킷 양
*/ 
-- filled_tokens : 버킷(양동이)에 남은 토큰의 양
local filled_tokens = math.min(capacity, last_tokens+(delta*rate))

/*
  filled_tokens >= requested 
  : 버킷(양동이)에 남은 토큰의 양이 충분한지
*/
local allowed = filled_tokens >= requested -- requested 는 요청 시에 소모할 토큰의 갯수

-- filled_tokens 의 값을 new_tokens 에 저장한다. (filled_tokens 의 값은 다른 곳에서 다시 쓰여야해서)
local new_tokens = filled_tokens 

/*
-- 버킷(양동이)에 남은 토큰의 양에서 requested 를 차감한 값을 new_tokens 에 저장
*/
-- new_tokens 
-- : 버킷에 남은 토큰의 양 - request 토큰 양
-- : 최종적으로 버킷에 남은 토큰의 양
local allowed_num = 0
if allowed then
  new_tokens = filled_tokens - requested
  allowed_num = 1
end
 
--redis.log(redis.LOG_WARNING, "delta " .. delta)
--redis.log(redis.LOG_WARNING, "filled_tokens " .. filled_tokens)
--redis.log(redis.LOG_WARNING, "allowed_num " .. allowed_num)
--redis.log(redis.LOG_WARNING, "new_tokens " .. new_tokens)
 
if ttl > 0 then
  redis.call("setex", tokens_key, ttl, new_tokens) -- new_tokens : 버킷의 남은 토큰의 양
  redis.call("setex", timestamp_key, ttl, now) -- get(timestamp_key) : 가장 최신의 조회 시각
end
 
-- return { allowed_num, new_tokens, capacity, filled_tokens, requested, new_tokens }
/*
  allowed_num
  : 버킷에 남은 토큰의 양이 충분하지 않아서 allowed == false 일 경우에는 0
  : 버킷에 남은 토큰의 양이 충분해서 allowed == true 일 경우에는 1

  new_tokens
  : 버킷에 남은 토큰의 최종 양
*/
return { allowed_num, new_tokens }

/* 참고
 : SETEX 는 Redis 2.6.12 이후로 Deprecated 된 명령어이다.
*/