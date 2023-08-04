package com.fusion.moviesapi;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;

import java.util.Map;

@SpringBootTest(classes = MoviesApiApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient
public class RedisTest {

    private static final GenericContainer REDIS_MASTER;
    private static final GenericContainer REDIS_REPLICA;

    @Autowired
    private WebTestClient webTestClient;

    private static final String MASTER = "master";

    private static final int REDIS_PORT = 6379;

    private static final String REDIS_PASSWORD = "admin$$$";

    static {
        Network redisNetwork = Network.newNetwork();

        REDIS_MASTER =
                new GenericContainer("docker.io/bitnami/redis:6.2")
                        .withNetwork(redisNetwork)
                        .withNetworkAliases(MASTER)
                        .withExposedPorts(REDIS_PORT)
                        .withEnv(Map.of("REDIS_REPLICATION_MODE", "master", "REDIS_PASSWORD", REDIS_PASSWORD));

        REDIS_MASTER.start();

        REDIS_REPLICA =
                new GenericContainer("docker.io/bitnami/redis:6.2")
                        .withExposedPorts(REDIS_PORT)
                        .withNetwork(redisNetwork)
                        .withNetworkAliases("redis-replica-1")
                        .withEnv(
                                Map.of(
                                        "REDIS_REPLICATION_MODE",
                                        "slave",
                                        "REDIS_MASTER_HOST",
                                        MASTER,
                                        "REDIS_MASTER_PORT_NUMBER",
                                        String.valueOf(REDIS_PORT),
                                        "REDIS_MASTER_PASSWORD",
                                        REDIS_PASSWORD,
                                        "REDIS_PASSWORD",
                                        REDIS_PASSWORD));

        REDIS_REPLICA.start();
    }

    @DynamicPropertySource
    public static void setDatasourceProperties(final DynamicPropertyRegistry registry) {
        registry.add("spring.redis.host", REDIS_MASTER::getHost);
        registry.add("redis.replica.host", REDIS_REPLICA::getHost);
        registry.add(
                "redis.replica.port", () -> REDIS_REPLICA.getMappedPort(REDIS_PORT));
        // disable ssl on local, easier for testing
        registry.add("spring.redis.ssl", () -> false);

        registry.add("spring.redis.port", () -> REDIS_MASTER.getMappedPort(REDIS_PORT));
        registry.add("spring.redis.password", () -> REDIS_PASSWORD);
    }
    protected WebTestClient getWebTestClient() {
        return webTestClient;
    }
    @Test
    public void testConnectionToRedis() {
        webTestClient.get().uri("/api/movies/year/2020").exchange().expectStatus().isOk();

    }

}