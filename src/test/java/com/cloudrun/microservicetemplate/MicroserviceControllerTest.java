package com.cloudrun.microservicetemplate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
public class MicroserviceControllerTest {

  @Autowired private MockMvc mvc;

  @Test
  public void returns_portfolio_page() throws Exception {
    this.mvc.perform(get("/"))
        .andExpect(status().isOk())
        .andExpect(view().name("index"));
  }

  @Test
  public void health_check_returns_ok() throws Exception {
    this.mvc.perform(get("/api/health"))
        .andExpect(status().isOk());
  }

  @Test
  public void returns_method_not_allowed_for_post() throws Exception {
    this.mvc.perform(post("/"))
        .andExpect(status().isMethodNotAllowed());
  }
}
