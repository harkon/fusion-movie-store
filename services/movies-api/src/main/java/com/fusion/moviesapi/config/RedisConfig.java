package com.fusion.moviesapi.config;

import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.redisson.spring.data.connection.RedissonConnectionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.io.IOException;


@Configuration
public class RedisConfig {

    @Value("${REDIS_HOST}")
    private String redisHost;

    @Value("${REDIS_PORT}")
    private int redisPort;

    @Value("${REDIS_PASSWORD}")
    private String redisPassword;

    @Value("${ENVIRONMENT}")
    private String environment;

    @Bean
    public RedissonConnectionFactory redissonConnectionFactory(RedissonClient redisson) {
        return new RedissonConnectionFactory(redisson);
    }

    @Bean(destroyMethod = "shutdown")
    public RedissonClient redisson() throws IOException {
        Config config = new Config();
        if("LOCAL".equalsIgnoreCase(environment)) {
            config.useSingleServer()
                    .setAddress("redis://" + redisHost + ":" + redisPort)
                    .setPassword(redisPassword)
                    .setSslEnableEndpointIdentification(false);
        } else if ("AWS".equalsIgnoreCase(environment)) {
            config.useClusterServers()
                    .addNodeAddress("rediss://" + redisHost + ":" + redisPort)
                    .setPassword(redisPassword);
        }
        return Redisson.create(config);
    }

}
