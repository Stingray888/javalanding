package com.cloudrun.microservicetemplate;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;
import java.util.concurrent.TimeUnit;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class MicroserviceTemplateIT {
  // Retrieve Cloud Run service test config
  static String idToken = System.getenv("ID_TOKEN");
  static String baseURL = System.getenv("BASE_URL");

  @BeforeAll
  public static void setup() throws Exception {
    if (baseURL == null || baseURL == "") throw new Exception("Cloud Run service URL not found.");
    if (idToken == null || idToken == "") throw new Exception("Unable to acquire an ID token.");
  }

  public Response authenticatedRequest(String url) throws IOException {
    OkHttpClient ok =
        new OkHttpClient.Builder()
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

    // Instantiate HTTP request
    Request request =
        new Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer " + idToken)
            .get()
            .build();

    Response response = ok.newCall(request).execute();
    return response;
  }

  @Test
  public void returns_ok() throws IOException {
    Response response = authenticatedRequest(baseURL);
    assertEquals(response.code(), 200);
    assertEquals(response.body().string(), "Hello World!");
  }
}
