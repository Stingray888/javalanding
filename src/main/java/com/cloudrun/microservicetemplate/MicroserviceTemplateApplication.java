package com.cloudrun.microservicetemplate;

import javax.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Microservice template for Cloud Run. */
@SpringBootApplication
public class MicroserviceTemplateApplication {
  private static final Logger logger =
      LoggerFactory.getLogger(MicroserviceTemplateApplication.class);

  public static void main(String[] args) {
    SpringApplication.run(MicroserviceTemplateApplication.class, args);
  }

  /** Register shutdown hook to listen for termination signal. */
  @PreDestroy
  public void tearDown() {
    // Clean up resources on shutdown
    logger.info(MicroserviceTemplateApplication.class.getSimpleName() + ": received SIGTERM.");
    // Flush async logs if needed - current Logback config does not buffer logs
  }
}
