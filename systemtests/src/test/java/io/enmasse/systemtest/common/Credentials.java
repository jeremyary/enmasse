/*
 * Copyright 2018, EnMasse authors.
 * License: Apache License 2.0 (see the file LICENSE or http://apache.org/licenses/LICENSE-2.0.html).
 */
package io.enmasse.systemtest.common;

import io.enmasse.systemtest.UserCredentials;

public final class Credentials {
    private Credentials() {
    }

    public static String namespace() {
        return System.getenv().getOrDefault("SYSTEMTESTS_CREDENTIALS_NAMESPACE", "pepik");
    }

    public static String user() {
        return System.getenv().getOrDefault("SYSTEMTESTS_CREDENTIALS_USER", "pepik");
    }

    public static String password() {
        return System.getenv().getOrDefault("SYSTEMTESTS_CREDENTIALS_PASSWORD", "pepik");
    }

    public static UserCredentials userCredentials() {
        return new UserCredentials(user(), password());
    }
}
