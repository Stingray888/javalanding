package com.cloudrun.microservicetemplate.util;

import com.google.cloud.MetadataConfig;
import com.google.cloud.ServiceOptions;

/**
 * Utilities to access service metadata from the metadata server.
 * https://cloud.google.com/run/docs/reference/container-contract#metadata-server
 */
public class Metadata {

  /**
   * Fetch an ID token. This token can be appended to the `Authorization: Bearer` header for
   * authenticated requests.
   *
   * @param aud the audience claim or receiving service
   * @return an ID token
   */
  public static String getIdToken(String aud) {
    String token =
        MetadataConfig.getAttribute("instance/service-accounts/default/identity?audience=" + aud);
    return token;
  }

  /**
   * Fetch the Cloud Run service region.
   *
   * @return region in format: projects/PROJECT_NUMBER/regions/REGION
   */
  public static String getServiceRegion() {
    return MetadataConfig.getZone();
  }

  /**
   * Fetch the GCP Project ID.
   *
   * @return the project ID of the Cloud Run service
   */
  public static String getProjectId() {
    return ServiceOptions.getDefaultProjectId();
  }
}
