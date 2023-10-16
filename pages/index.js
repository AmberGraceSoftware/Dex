import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import clsx from "clsx";
import React from "react";
import styles from "./index.module.css";

function Header() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero", styles.heroBanner)}>
      <div className="container">
        <img
          src={siteConfig.baseUrl + "logo.svg"}
          className="bigLogo"
          alt="Dex"
        />
        <br/>
        <br/>
        <h1>{siteConfig.tagline}</h1>
        <div className="callToAction">
          <div className="cta-button" >
            <Link
              className="button button--primary button--lg"
              to="/docs/intro"
            >
              Get Started →
            </Link>
          </div>
          <div className="cta-button" >
            <Link
              className="button button--secondary button--lg"
              to="/api/Dex"
            >
              API Reference →
            </Link>
          </div>
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
        <p className="library-tagline">
          Dex is a UI library which enables Roblox developers to easily bring
          their UI designs to life.
        </p>
      </main>
    </Layout>
  );
}