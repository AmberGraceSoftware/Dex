import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import clsx from "clsx";
import React from "react";
import "./home.css";
import styles from "./index.module.css";

function Header() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero", styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">
          <img
            src={siteConfig.baseUrl + "logo.svg"}
            className="bigLogo"
            alt="Moonwave"
          />
        </h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            Get Started →
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig, tagline } = useDocusaurusContext();
  return (
    <Layout title={siteConfig.title} description={tagline}>
      <Header />
      <main>
        <p className={styles.tagline}>
          Dec is a UI library which enables Roblox developers to easily bring
          their UI designs to life.
        </p>
      </main>
    </Layout>
  );
}