![Pterodactyl GraalVM](https://user-images.githubusercontent.com/18230443/209179431-6adf6e6c-09fd-4501-b420-90c5b1dd09e1.jpg)
![build graalvm](https://github.com/tommasobenatti/pterodactyl-graalvm/actions/workflows/docker-image.yml/badge.svg)
![license mit](https://img.shields.io/badge/license-MIT-green)

**GraalVM** is a high-performance JDK that provides significant improvements in application performance and efficiency.  
It is ideal for **microservices**, **high-load applications**, and **Minecraft servers**.  
➡️ [Official GraalVM website](https://www.graalvm.org/)

---

## 🔧 Build Types

- **JDK (Oracle GraalVM JDK)**  
  Based on **Oracle JDK**, distributed under [GraalVM Free Terms and Conditions](https://www.oracle.com/downloads/licenses/graal-free-license.html).  
  Includes additional features for **Native Image** (AOT).

- **CE (Community Edition)**  
  Based on **OpenJDK**, licensed under **GPLv2 + Classpath Exception**.  
  Fully open-source and ideal for production Minecraft servers running with **JIT**.

- **EE (Enterprise Edition)**  
  Not available in these builds. Provides enterprise-level optimizations (mainly for Native Image, not relevant for JIT Minecraft servers).

---

## 📦 Docker Tags

| Java | JDK (Oracle GraalVM)                             | CE (Community Edition)                              | EE (Enterprise Edition) |
|------|--------------------------------------------------|-----------------------------------------------------|--------------------------|
| 8    | ❌                                               | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-8`   | ❌                      |
| 11   | ❌                                               | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-11`  | ❌                      |
| 17   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-17` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-17` | ❌                      |
| 19   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-19` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-19` | ❌                      |
| 20   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-20` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-20` | ❌                      |
| 21   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-21` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-21` | ❌                      |
| 22   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-22` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-22` | ❌                      |
| 23   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-23` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-23` | ❌                      |
| 24   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-24` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-24` | ❌                      |
| 25   | `ghcr.io/tommasobenatti/pterodactyl-graalvm:JDK-25` | `ghcr.io/tommasobenatti/pterodactyl-graalvm:CE-25` | ❌                      |

---

## 🎮 Recommended Java per Minecraft Version

| Minecraft Version | Minimum Java | Recommended Java | Suggested Docker Tag |
|-------------------|--------------|------------------|-----------------------|
| **1.8 – 1.16**   | Java 8       | Java 11 / 17     | `CE-11` or `CE-17`    |
| **1.17**         | Java 16      | Java 17          | `CE-17`               |
| **1.18 – 1.20.4**| Java 17      | Java 17 / 21     | `CE-17` or `CE-21`    |
| **1.20.5 – 1.21.x** | Java 21   | Java 21          | `CE-21`               |
| **Future (1.22+)**| TBD (likely 21+) | Java 23 / 25 | `CE-23` or `CE-25`    |

---

## ⚡ Quick Guide: Enable the Fast Compiler (Graal JIT)

To run with the Graal just-in-time compiler, add the following flags:

```bash
-XX:+UnlockExperimentalVMOptions -XX:+UseGraalJIT